package Act::Handler::Talk::List;
use strict;
use Apache::Constants qw(NOT_FOUND);
use Act::Config;
use Act::Template::HTML;
use Act::Talk;

sub handler
{
    # retrieve talks and speaker info
    my $talks = Act::Talk->get_talks(conf_id => $Request{conference});
    $_->{user} = Act::User->new(user_id => $_->user_id) for @$talks;

    # accept / unaccept talks
    if ($Request{user} && $Request{user}->is_orga && $Request{args}{ok}) {
        for my $t (@$talks) {
            if ($t->accepted && !$Request{args}{$t->talk_id}) {
                $t->update(accepted => 0 );
                $t->{accepted} = undef;
            }
            elsif (!$t->accepted && $Request{args}{$t->talk_id}) {
                $t->update(accepted => 1 );
            }
        }
    }

    # compute some global information
    my ($accepted, $lightnings, $duration ) = ( 0, 0, 0 );
    $_->accepted && do { $accepted++; $_->lightning ? $lightnings++ : ( $duration += $_->duration) } for @$talks;

    # process the template
    my $template = Act::Template::HTML->new();
    $template->variables(
        talks => [ sort {
            $a->lightning <=> $b->lightning
            || lc $a->{user}->last_name  cmp lc $b->{user}->last_name
            || lc $a->{user}->first_name cmp lc $b->{user}->first_name
            || $a->talk_id <=> $b->talk_id
        } @$talks ],
        talks_total    => scalar @$talks,
        talks_accepted => $accepted,
        talks_duration => $duration,
        talks_lightning => $lightnings,
    ); 
    $template->process('talk/list');
}

1;
__END__

=head1 NAME

Act::Handler::User::List - show all talks

=head1 DESCRIPTION

See F<DEVDOC> for a complete discussion on handlers.

=cut
