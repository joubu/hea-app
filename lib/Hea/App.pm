package Hea::App;

use Modern::Perl;
use Dancer ':syntax';
use Hea::Data;
use Template;
use JSON qw( to_json );
use I18N::LangTags::Detect;

get '/' => sub {
    my @languages     = I18N::LangTags::Detect::detect();
    my $installations_quantity = Hea::Data::get_installations_quantity;
    my $libraries_quantity     = Hea::Data::get_libraries_quantity;

    my $biblio_stats       = Hea::Data::volumetry_stats('biblio');
    my $authority_stats    = Hea::Data::volumetry_stats('auth_header');
    my $item_stats         = Hea::Data::volumetry_stats('items');
    my $patron_stats       = Hea::Data::volumetry_stats('borrowers');
    my $issue_stats        = Hea::Data::volumetry_stats('old_issues');
    my $reserve_stats      = Hea::Data::volumetry_stats('old_reserves');
    my $order_stats        = Hea::Data::volumetry_stats('aqorders');
    my $subscription_stats = Hea::Data::volumetry_stats('subscription');

    my $biblio_volumetry       = to_json Hea::Data::volumetry_range('biblio');
    my $authority_volumetry    = to_json Hea::Data::volumetry_range('auth_header');
    my $item_volumetry         = to_json Hea::Data::volumetry_range('items');
    my $patron_volumetry       = to_json Hea::Data::volumetry_range('borrowers');
    my $issue_volumetry        = to_json Hea::Data::volumetry_range('old_issues');
    my $reserve_volumetry      = to_json Hea::Data::volumetry_range('old_reserves');
    my $order_volumetry        = to_json Hea::Data::volumetry_range('aqorders');
    my $subscription_volumetry = to_json Hea::Data::volumetry_range('subscription');
    my $country_volumetry      = to_json Hea::Data::number_of_libraries_by_country;
    my $type_volumetry         = to_json Hea::Data::installations_by_type;

    template 'index' => {
        installations_quantity => $installations_quantity,
        libraries_quantity     => $libraries_quantity,
        biblio_stats           => $biblio_stats,
        authority_stats        => $authority_stats,
        item_stats             => $item_stats,
        patron_stats           => $patron_stats,
        issue_stats            => $issue_stats,
        reserve_stats          => $reserve_stats,
        order_stats            => $order_stats,
        subscription_stats     => $subscription_stats,
        biblio_volumetry       => $biblio_volumetry,
        authority_volumetry    => $authority_volumetry,
        item_volumetry         => $item_volumetry,
        patron_volumetry       => $patron_volumetry,
        issue_volumetry        => $issue_volumetry,
        reserve_volumetry      => $reserve_volumetry,
        order_volumetry        => $order_volumetry,
        subscription_volumetry => $subscription_volumetry,
        country_volumetry      => $country_volumetry,
        type_volumetry         => $type_volumetry,
        v                      => 'home',
        languages              => \@languages,
    };
};

get '/libraries' => sub {
    my $libs = Hea::Data::libraries_name_and_url();

    template 'libraries' => {
        libraries => $libs,
        v => 'libraries',
    };
};

get '/libraries/:public_id' => sub {
    my $public_id = param('public_id');
    my $installation = Hea::Data::get_installation( $public_id );
    my $libraries = Hea::Data::get_libraries( { public_id => $public_id } );

    template 'library' => {
        installation => $installation,
        libraries => $libraries,
        v => 'library',
    };
};

get '/libraries-by-country' => sub {
    my $libraries = Hea::Data::libraries_by_country();

    my $per_country;
    for my $library ( @$libraries ) {
        push @{ $per_country->{$library->{country}} }, $library;
    }
    template 'libraries-by-country' => {
        libraries => $per_country,
        v => 'libraries-by-country',
    };
};

get '/libraries-on-a-map' => sub {
    my $libraries = Hea::Data::get_libraries();

    template 'libraries-on-a-map' => {
        libraries => $libraries,
        v => 'libraries-on-a-map',
    };
};

get '/systempreferences' => sub {
    my $systempreferences = Hea::Data::syspref_repartition;
    my @prefs;
    while ( my ( $pref_name, $values ) = each %$systempreferences ) {
        if ( $pref_name eq 'version' ) {
            $values = [ sort { $b->{name} <=> $a->{name} } @$values ];
        }
        push @prefs, { syspref_name => $pref_name, values => to_json $values };
    }
    @prefs = sort { $a->{syspref_name} cmp $b->{syspref_name} } @prefs;

    template 'systempreferences' => {
        systempreferences => \@prefs,
        v => 'systempreferences',
    };
};

true;
