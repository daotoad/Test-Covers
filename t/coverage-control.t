#!/usr/bin/perl

use strict;
use warnings;
no warnings 'redefine';
no warnings 'once';
use Carp qw<cluck>;

use Test::More;
use Test::Covers 'AT::Model::NumberPool';

require Test::Covers;

my @DIRECTIVES;
my $LOADED;
local *Devel::Cover::import = sub {
  shift;
  push @DIRECTIVES, @_;
};

local %INC = %INC;

local @INC = @INC;
unshift @INC, \&_prevent_devel_cover_loading;

{   my $msg = 'Devel::Cover not configured if not loaded and not ENABLED.';

    unload_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 0;
    $Test::Covers::DEFAULT = 0;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( !@directives, $msg );
    ok( !$loaded, 'Did not try to load Devel::Cover' );
}

{   my $msg = 'Verify Devel::Cover reconfigured when not ENABLED and loaded.';

    load_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 0;
    $Test::Covers::DEFAULT = 0;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( ! ! @directives, $msg );
    ok( !$loaded, 'did not load Devel::Cover' );
}

{   my $msg = 'Verify Devel::Cover reconfigured when ENABLED and not loaded.';

    unload_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 1;
    $Test::Covers::DEFAULT = 0;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( ! ! @directives, $msg );
    ok( $loaded, 'loaded Devel::Cover' );
}

{   my $msg = 'Verify Devel::Cover reconfigured when ENABLED and loaded.';

    load_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 1;
    $Test::Covers::DEFAULT = 0;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( ! ! @directives, $msg );
    ok( !$loaded, 'did not reload Devel::Cover' );
}


{   my $msg = 'Devel::Cover not configured if DEFAULT mode and not ENABLED and not loaded.';

    unload_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 0;
    $Test::Covers::DEFAULT = 1;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( !@directives, $msg );
    ok( !$loaded, 'loaded Devel::Cover' );
}

{   my $msg = 'Devel::Cover not configured if DEFAULT mode and not ENABLED and loaded.';

    load_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 0;
    $Test::Covers::DEFAULT = 1;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( !@directives, $msg );
    ok( !$loaded, 'Did not try to load Devel::Cover' );
}


{   my $msg = 'Devel::Cover not configured if DEFAULT mode and ENABLED.';

    unload_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 1;
    $Test::Covers::DEFAULT = 1;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( !@directives, $msg );
    ok( $loaded, 'loaded Devel::Cover' );
}

{   my $msg = 'Devel::Cover not configured if DEFAULT mode and loaded.';

    load_modules( 'Devel::Cover' );

    $Test::Covers::ENABLE  = 1;
    $Test::Covers::DEFAULT = 1;

    Test::Covers->import( "Foo" );

    my ($loaded, @directives) = read_instruments();

    ok( !@directives, $msg );
    ok( !$loaded, 'Did not try to load Devel::Cover' );
}


done_testing();

sub unload_modules {
    delete $INC{$_}
        for map _mod_to_file($_), @_;
}

sub load_modules {
    $INC{$_} = 1
        for map _mod_to_file($_), @_;
}

sub read_instruments {
    my $loaded = $LOADED;
    my @directives = @DIRECTIVES;

    $LOADED = undef;
    @DIRECTIVES = ();

    return $loaded, @directives;
}

sub _prevent_devel_cover_loading {
    if ($_[1] eq 'Devel/Cover.pm') {

        $INC{'Devel/Cover.pm'}=1; # Mark Devel::Cover as loaded
        $LOADED++;                # Update instrumentation
        my $line = 1;
        return ( \*BOGUS, sub {   # Pretend to load Devel::Cover
            if ($line) {
              $_='1;',$line=0;
              return 1;
            } else {
              $_='';
              return 0;
            }
        });
    } else {
        return;
    }
}

sub _mod_to_file {
    my $mod = $_[0];

    $mod  =~ s/::/\//g;
    $mod .= '.pm';

    return $mod;
}
