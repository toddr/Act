package Act::Handler::Login;

use strict;
use Apache2::Const qw(DONE);
use Act::Config;
use Act::Template::HTML;
use Act::Util;

sub handler
{
    my $r = $Request{r};

    # disable client-side caching
    $r->no_cache(1);

    # destination URI
    my $uri;
    if ($r->prev && $r->prev->uri) {
        $uri = $r->prev->uri;
        if ($uri !~ /\?/ && $r->prev->args) {
            $uri .= '?' . $r->prev->args;
        }
    }
    else {
        $uri = Act::Util::make_uri('');
    }

    # process the login form template
    my $template = Act::Template::HTML->new();
    $template->variables(
        error       => ($r->subprocess_env->{REDIRECT_AuthCookieReason} eq 'bad_credentials'),
        destination => $uri,
        action      => join('/', '', $Request{conference}, 'LOGIN'),
        domain      => join('.', (split /\./, $r->server->server_hostname)[-2, -1]),
    );
    $template->process('login');
    $Request{status} = DONE;
}
1;
__END__

=head1 NAME

Act::Handler::Login - display the login form

=head1 DESCRIPTION

This is automatically called by Act::Auth when access to
the requested page requires authentication.

=cut
