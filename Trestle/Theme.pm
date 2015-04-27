package Trestle::Theme;

use HTML::Template;

sub new {
    my $class = shift;
    my $siteName = shift;
    my $self = {};
    $self->{siteName} = $siteName;

    bless $self, $class;
    return $self;
}

sub removeUndef {
    my ($self, $values) = @_;
    if (ref($values) eq "HASH") {
        for my $key (keys %$values) {
            if (!(defined $values->{$key})) {
                delete $values->{$key};
            } elsif (ref($values->{$key}) =~ /(HASH)|(ARRAY)/) {
                $values->{$key} = $self->removeUndef($values->{$key});
            }
        }
    } else {
        for (my $i=0; $i< scalar @$values; $i++) {
            if (!(defined $values->[$i])) {
                splice(@$values, $i, 1);
            } elsif (ref($values->[$i]) =~ /(HASH)|(ARRAY)/) {
                $values->[$i] = $self->removeUndef($values->[$i]);
            }

        }
    }
    return $values;
}

sub render {
    my ($self, $templateFile, $values) = @_;
    my $template = HTML::Template->new(
        filename => $templateFile,
        die_on_bad_params =>  0
    );

    $values = $self->removeUndef($values);
    $values->{siteName} = $self->{siteName} if $self->{siteName};

    for my $key (keys %$values) {
        if (defined $values->{$key}) {
            if (ref($values->{$key}) eq "HASH") {
                $template->param($key => [ $values->{$key} ]);
            } else {
                $template->param($key => $values->{$key});
            }
        }
    }

    return $template->output;

}

1;
