package Category;

use CGI;
use Page;
use JSON;
use strict;

sub new {
    my $self = { };

    my $class = shift;
    my $sourceDir = shift;
    $self->{root} = shift;

    #Grab the directory name from the file path
    if ($sourceDir =~ /^content\/+(.+)$/) {
        $self->{dir} = $1;
    }

    my $json = JSON->new->allow_nonref;

    #Make a new page for every html file in the directory
    my @pages = ();
    foreach my $pageFile (glob("$sourceDir/*.html")) {
        $pageFile =~ s/\/+/\//g;
        push(@pages, Page->new($pageFile, $self->{root}, 1));
    }

    #Sort the pages in reverse chronological order by release date
    @{ $self->{pages} } = sort { $b->meta("date")->{full} <=> $a->meta("date")->{full} } @pages;

    #Read the category.json file for the category into a values to get the full name and other metadata
    my $contents = do {
        local $/;
        open my $fh, $sourceDir . "/category.json" or die "Can't open category.json from $sourceDir: $!";
        <$fh>;
    };
    my $categoryJSON = $json->decode($contents);

    foreach my $key (keys %$categoryJSON) {
        $self->{$key} = $categoryJSON->{$key};
    }

    bless $self, $class;
    return $self;
}

sub info {
    my ($self, $value) = @_;
    if (exists $self->{$value}) {
        return $self->{$value};
    } else {
        return undef;
    }
}



1;
