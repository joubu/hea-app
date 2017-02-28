use Modern::Perl;
use DBI;
my $database = 'REPLACE_ME';
my $user = 'REPLACE_ME';
my $password = 'REPLACE_ME';

my $dbh = DBI->connect('dbi:mysql:' . $database, $user, $password, {
    RaiseError => 1
});
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set NAMES 'utf8'");

my $libraries = $dbh->selectall_arrayref(q|SELECT * FROM library;|, { Slice => {} });
my $volumetries = $dbh->selectall_arrayref(q|SELECT * FROM volumetry;|, { Slice => {} });
my $sysprefs = $dbh->selectall_arrayref(q|SELECT * FROM systempreference;|, { Slice => {} });

$dbh->do(q|DROP TABLE volumetry|);
$dbh->do(q|DROP TABLE systempreference|);
$dbh->do(q|DROP TABLE library|);

$dbh->do(q|
    CREATE TABLE installation (
        id int(11) NOT NULL AUTO_INCREMENT,
        koha_id VARCHAR(32) NOT NULL,
        name VARCHAR(255) NULL DEFAULT NULL,
        url VARCHAR(255) NULL DEFAULT NULL,
        country VARCHAR(255) NOT NULL DEFAULT '',
        geolocation VARCHAR(64) NOT NULL DEFAULT '',
        library_type VARCHAR(255) NOT NULL DEFAULT '',
        creation_time TIMESTAMP NULL DEFAULT NULL,
        modification_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`koha_id`),
        UNIQUE KEY id (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
|);
$dbh->do(q|
CREATE TABLE library (
    library_id INT(11) NOT NULL AUTO_INCREMENT,
    koha_id VARCHAR(32) NOT NULL,
    name VARCHAR(255) NULL DEFAULT NULL,
    url VARCHAR(255) NULL DEFAULT NULL,
    country VARCHAR(255) NOT NULL DEFAULT '',
    geolocation VARCHAR(64) NOT NULL DEFAULT '',
    PRIMARY KEY (library_id),
    CONSTRAINT library_installation FOREIGN KEY (koha_id) REFERENCES installation(koha_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
|);
$dbh->do(q|
CREATE TABLE volumetry (
    koha_id VARCHAR(32) NOT NULL,
    name VARCHAR(255) NOT NULL,
    value INTEGER NOT NULL DEFAULT 0,
    inserted TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT vol_install FOREIGN KEY (koha_id) REFERENCES installation(koha_id)  ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
|);
$dbh->do(q|
CREATE TABLE systempreference (
    koha_id VARCHAR(32) NOT NULL,
    name VARCHAR(255) NOT NULL,
    value TEXT NULL,
    CONSTRAINT syspref_install FOREIGN KEY (koha_id) REFERENCES installation(koha_id)  ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
|);

for my $library ( @$libraries ) {
    $dbh->do(q|
        INSERT INTO installation(koha_id, name, url, country, library_type, creation_time, modification_time) VALUES (?, ?, ?, ?, ?, ?, ?)
    |, undef, $library->{library_id}, $library->{name}, $library->{url}, $library->{country}, $library->{library_type}, $library->{creation_time}, $library->{modification_time} );
    $dbh->do(q|
        INSERT INTO library(koha_id, name, url, country ) VALUES (?, ?, ?, ?)
    |, undef, $library->{library_id}, $library->{name}, $library->{url}, $library->{country} );
}

my $sth = $dbh->prepare(q|
    INSERT INTO volumetry(koha_id, name, value, inserted) VALUES (?, ?, ?, ?)
|);
for my $vol ( @$volumetries ) {
    $sth->execute( $vol->{library_id}, $vol->{name}, $vol->{value}, $vol->{inserted} );
}

$sth = $dbh->prepare(q|
    INSERT INTO systempreference(koha_id, name, value) VALUES (?, ?, ?)
|);
for my $syspref ( @$sysprefs ) {
    $sth->execute( $syspref->{library_id}, $syspref->{name}, $syspref->{value} );
}
