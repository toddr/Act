package Act::Handler::User::Export;
use strict;

use Apache2::Const qw(NOT_FOUND);
use Text::xSV;

use Act::Config;
use Act::User;

my @UROWS = qw(
    user_id login email salutation first_name last_name nick_name pseudonymous country town pm_group
    has_talk has_paid
);
my @PROWS = qw( tshirt_size nb_family datetime);
my @TROWS = qw( company address vat );

sub handler
{
    # only for orgas
    unless ($Request{user}->is_users_admin) {
        $Request{status} = NOT_FOUND;
        return;
    }
    # get user information
    my $users = Act::User->get_items(conf_id => $Request{conference});

    # generate CSV report
    my $csv = Text::xSV->new( header => [ @UROWS, 'rights', @PROWS , ($Request{user}->is_treasurer ? @TROWS : ())] );
    $Request{r}->send_http_header('text/csv; charset=UTF-8');
    $Request{r}->print($csv->format_header());

    for my $u (@$users) {

        # get participation data
        my $p = $u->participation;

        # print in CSV format
        $Request{r}->print($csv->format_row(
            map($u->$_,   @UROWS),
            join( ':', sort keys %{ $u->rights } ),
            map($p->{$_}, @PROWS),
            ($Request{user}->is_treasurer ? map($u->$_, @TROWS) : ()),
        ));
    }
}

1;
__END__

=head1 NAME

Act::Handler::User::Export - export users to CSV

=head1 DESCRIPTION

See F<DEVDOC> for a complete discussion on handlers.

=cut
