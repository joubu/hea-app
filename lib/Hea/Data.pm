package Hea::Data;

use Modern::Perl;
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '0.2';

# retrieve the number of installations
sub get_installations_quantity {
    database->quick_count( 'installation', {} );
}
# retrieve the number of libraries
sub get_libraries_quantity {
    return database->selectrow_hashref(q|
        SELECT SUM(counted) as sum, MAX(counted) as max, MIN(counted) as min, AVG(counted) as avg
        FROM (
            SELECT COUNT(*) AS counted
            FROM library
            GROUP BY koha_id
        ) AS counts
    |);
}

# retrieves the sum of biblios in all libraries
sub volumetry_stats {
    my ( $type ) = @_;
    return unless $type;
    my $sth   = database->prepare(q|
        SELECT COALESCE(sum(value), 0) as sum, COALESCE(AVG(value), 0) as avg, COALESCE(MAX(value), 0) as max, COALESCE(MIN(value), 0) as min, stddev_pop(value) as std
        FROM volumetry
        WHERE name=?
    |);
    $sth->execute($type);
    my $tmp = $sth->fetchrow_hashref;
    $tmp->{med}=volumetry_median($type);
    return $tmp;
}

sub volumetry_median {
    my ( $type ) = @_;
    return unless $type;
    my $sth   = database->prepare(q|
        SELECT AVG(value) as med
        FROM
        (
            SELECT @counter:=@counter+1 as row_id, v1.value
            FROM volumetry v1, (select @counter:=0) v2
            WHERE v1.name=?
            ORDER BY v1.value
        ) o1
        JOIN
        (
            SELECT count(*) as total_rows
            FROM volumetry
            WHERE name=?
        ) o2
        WHERE o1.row_id in (FLOOR((o2.total_rows + 1)/2), FLOOR((o2.total_rows + 2)/2))
    |);
    $sth->execute($type, $type);
    my $tmp = $sth->fetchrow_hashref;
    return $tmp->{med};
}

sub syspref_repartition {
    my $sth = database->prepare(q|
        SELECT name, value, count(*) as count
        FROM systempreference
        GROUP BY name, value
        ORDER BY value
    |);
    $sth->execute;
    my $data = $sth->fetchall_arrayref( {} );
    my $pref_repartition;
    for my $d ( @$data ) {
        push @{$pref_repartition->{$d->{name}}}, { name => $d->{value}, value => $d->{count} };
    }
    return $pref_repartition;
}

sub volumetry_range {
    my ( $type ) = @_;
    return unless $type;
    my $sth = database->prepare(q|
        SELECT *
        FROM volumetry
        WHERE name = ?
    |);
    $sth->execute($type);
    my $data = $sth->fetchall_arrayref( {} );

    my $range;
    if ( $type eq 'borrowers' || $type eq 'subscription' || $type eq 'aqorders' || $type eq 'old_reserves' ) {
         $range = { 1 => 1500, 2 => 5000, 3 => 15000 };
    } else {
        $range = { 1 => 15000, 2 => 50000, 3 => 150000 };
    }

    my $vol;
    foreach my $entry (@$data) {
        my $num = $entry->{value} || 0;
        if ( $num < $range->{1} ) {
            $vol->{1}++;
        } elsif ( $num > $range->{1} and $num <= $range->{2} ) {
            $vol->{2}++;
        } elsif ( $num > $range->{2} and $num <= $range->{3} ) {
            $vol->{3}++;
        } elsif ( $num > $range->{3} ) {
            $vol->{4}++;
        }
    }

    return [
        {name => "0-$range->{1}", value => $vol->{1} || 0},
        {name => "$range->{1}-$range->{2}", value => $vol->{2} || 0},
        {name => "$range->{2}-$range->{3}", value => $vol->{3} || 0},
        {name => "$range->{3}+", value => $vol->{4} || 0},
    ];
}

sub number_of_libraries_by_country {
    my $query = "
        SELECT country as name, COALESCE(COUNT(*), 0) AS value
        FROM library
        WHERE country <> ''
        GROUP BY country
    ";

    return database->selectall_arrayref($query, { Slice => {} } );
}

sub get_installation {
    my ( $public_id ) = @_;
    return database->selectrow_hashref(q|
        SELECT id, name, url, country, geolocation, library_type
        FROM installation
        WHERE id = ?
    |, {}, $public_id);
}

sub get_libraries {
    my ( $params ) = @_;
    return if exists $params->{public_id} and not $params->{public_id};
    return database->selectall_arrayref(q|
        SELECT i.id, l.name, l.url, l.country, l.geolocation
        FROM library l
        LEFT JOIN installation i ON i.koha_id = l.koha_id
    | . ( $params->{public_id} ? q| WHERE i.id = ? | : '' ) . q|
        ORDER BY l.name
    |, { Slice => {} }, $params->{public_id} || ());
}

sub libraries_by_country {
    my $query = q|
        SELECT i.id, l.name, l.url, l.country, l.geolocation
        FROM library l
        LEFT JOIN installation i ON i.koha_id = l.koha_id
        WHERE   l.country <> ''
            AND l.name <> ''
        ORDER BY l.country
    |;

    return database->selectall_arrayref($query, { Slice => {} });
}

sub installations_by_type {
    my $query = "
        SELECT library_type as name, COALESCE(COUNT(*), 0) AS value
        FROM installation
        WHERE library_type <> ''
        GROUP BY library_type
    ";

    return database->selectall_arrayref($query, { Slice => {} } );
}

sub libraries_name_and_url {
    my $query = q|
        SELECT i.id, l.name, l.url, l.country, l.geolocation
        FROM library l
        LEFT JOIN installation i ON i.koha_id = l.koha_id
        WHERE l.name <> ''
        ORDER BY l.name
    |;
    return database->selectall_arrayref( $query, { Slice => {} } );
}



1;
