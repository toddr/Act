package Act::Handler::Track::Edit;
use strict;

use Apache2::Const qw(NOT_FOUND FORBIDDEN);
use Act::Config;
use Act::Form;
use Act::Template::HTML;
use Act::Track;
use Act::Util;

# form
my $form = Act::Form->new(
  required => [qw( title )],
  optional => [qw( description delete )],
);

sub handler {

    unless ($Request{user}->is_talks_admin) {
        $Request{status} = NOT_FOUND;
        return;
    }
    my $template = Act::Template::HTML->new();
    my $fields;

    # get the track
    my $track;
    $track = Act::Track->new(
        track_id  => $Request{args}{track_id},
        conf_id   => $Request{conference},
    ) if exists $Request{args}{track_id};

    # cannot edit non-existent track
    if (exists $Request{args}{track_id} and not defined $track) {
        $Request{status} = NOT_FOUND;
        return;
    }

    # automatically compute the return URL
    my $referer = $Request{r}->header_in('Referer');
    $Request{args}{return_url} ||= $referer
        if $referer =~ m{/(?:tracks)};

    if ($Request{args}{submit}) {
        # form has been submitted
        my @errors;

        # validate form fields
        my $ok = $form->validate($Request{args});
        $fields = $form->{fields};

        if ($ok) {
            if (defined $track) { 
                if ($fields->{delete} ) {
                    # delete existing track
                    $track->delete;
                    # redirect to track list
                    return Act::Util::redirect(make_uri('tracks'));
                }
                else {
                    # update existing track
                    $track->update( %$fields );
                }
            }
            # insert new track
            else {
                $track = Act::Track->create(
                    %$fields,
                    conf_id   => $Request{conference},
                );
                # redirect to track list
                return Act::Util::redirect(make_uri('tracks'));
            }

            # return to the referring URL if needed
            return Act::Util::redirect( $Request{args}{return_url} )
                if $Request{args}{return_url};
        }
        else {
            # map errors
            $form->{invalid}{title} && push @errors, 'ERR_TITLE';
        }
        $template->variables(
            return_url => $Request{args}{return_url},
            errors     => \@errors,
        );
    }

    # display the track submission form
    $template->variables(defined $track ? %$track : %$fields);
    $template->process('track/edit');
}

1;

=head1 NAME

Act::Handler::Track::Edit - Create or edit a track

=head1 DESCRIPTION

See F<DEVDOC> for a complete discussion on handlers.

=cut
