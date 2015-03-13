package Test::Covers;

use 5.006;
use strict;
use warnings FATAL => 'all';
our $VERSION = '0.01';

use Carp qw< croak confess >;

our $DEFAULT = $ENV{COVERAGE_DEFAULT} // 0;
our $ENABLE = $ENV{COVERAGE_ENABLED} // 0;

sub import {
    my ($package, @test_mods) = @_;
    my $coverage_loaded = _devel_cover_loaded();

    # Don't mess with devel cover if it is not loaded and it isn't enabled.
    return
        if !$ENABLE
        && !$coverage_loaded;

    my @directives = $DEFAULT
                   ? ()
                   : ( qw/ -ignore  .* /,
                       map { ("-select", $_) } @test_mods
                   );

    # Don't mess with devel cover if it is loaded and you have no directives.
    return if ( $coverage_loaded && !@directives );

    eval 'use Devel::Cover @directives; 1' or die;

    return;
}

sub _devel_cover_loaded {
    return ! ! $INC{'Devel/Cover.pm'};
}

__PACKAGE__;

__END__

=head1 NAME

Test::Covers - Identify which modules a test covers

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

Configure devel cover to track only listed modules.

Label your test code:

    use Test::Covers 'My::Foo';
    use Test::More;

    ok( My::Foo->true );



Run test code without coverage normally:

    prove my-test.t

Enable coverage analysis:

    prove -MDevel::Cover my-test.t

    -- or --

    COVERAGE_ENABLED=1 prove my-test.t

Disable Test::Covers reconfiguration of Devel::Cover:

    COVERAGE_DEFAULT=1 prove my-test.t


=head1 DESCRIPTION

This module provides a convenient way to tie a test to one or more particular modules.

Really, this module is a simple configuration wrapper around L<Devel::Cover>.

It provides two simplified interfaces, one for specifying coverage and one for enabling coverage analysis.

=head2 SPECIFYING COVERAGE

    use Test:::Covers @ARGS;

When you use L<Test::Covers> you are telling L<Devel::Cover> to ignore everything, and then selectively reenabling coverage for the items in the C<@ARGS> list.

    use Test:::Covers qw/ Foo Bar /;

This tells Devel::Cover:

    use Devel::Cover qw/ignore .* -select Foo -select Bar /;

This means that any argument that would work with L<Devel::Cover> C<select>, such as a regexp or a string, can be used with L<Test::Covers>.

If you want L<Test::Covers> to skip the L<Devel::Cover> configuration step, you can set the C<COVERAGE_DEFAULT> environment variable to a true value.

=head2 ENABLING COVERAGE ANALISYS

L<Test::Covers> will load L<Devel::Cover> if the C<COVERAGE_ENABLED> environment variable to a true value.

No matter how L<Devel::Cover> is loaded, L<Test::Covers> will attempt to configure it (unless directed not to).


=head1 AUTHOR

Mark Swayne, C<< <daotoad at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-covers at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Covers>.  I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Covers

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Covers>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Covers>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Covers>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Covers/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to Marchex for allowing me to release personal and work related code as
open source.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Mark Swayne.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

