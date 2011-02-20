# ABSTRACT: Plack middleware to minify HTML on-the-fly

package Plack::Middleware::HTMLMinify;

use strict;
use warnings;

=head1 NAME

Plack::Middleware::HTMLMinify

=head1 VERSION
Version 0.1
=cut

our $VERSION = '0.1';

=head1 DESCRIPTION

This module will use L<HTML::Packer> to minify HTML code on-the-fly
automatically.  Currently it will check if Content-Type is C<text/html>.

=head1 SYNOPSIS

    use Plack::Builder;
    builder {
	enable 'HTMLMinify', opt => {remove_newlines => 1};
    }

=cut

use parent 'Plack::Middleware';

use HTML::Packer;
use Plack::Util;

use Plack::Util::Accessor qw/opt packer/;

sub call {
    my ($self, $env) = @_;

    my $res = $self->app->($env);
    Plack::Util::response_cb($res, sub {
	my $res = shift;

	my $h = Plack::Util::headers($res->[1]);
	return unless $h->get('Content-Type') =~ qr{text/html};

	$self->packer->minify(\$res->[2][0], $self->opt);
	return;
    });
}

sub prepare_app {
    my $self = shift;
    my $packer = HTML::Packer->init;
    $self->packer($packer);
    $self->opt({remove_newlines => 1}) unless defined $self->opt;
}

=head1 AUTHOR

Gea-Suan Lin, C<< <gslin at gslin.org> >>

=cut

1;
