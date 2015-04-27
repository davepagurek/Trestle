package Trestle::Theme::Default;

use strict;

use lib "../..";
use Trestle::Theme;

sub new {
    my $class = shift;
    my $self = {
        dir => "Trestle/Theme/Default",
        theme => Trestle::Theme->new()
    };

    bless $self, $class;
    return $self;
}

sub content {
    my ($self, $page) = @_;

    return $self->{theme}->render("$self->{dir}/template/content.tmpl", {
        themeDir => $self->{dir},
        title => $page->meta("title"),
        content => $page->content,
        date => $page->meta("date"),
        root => $page->meta("root"),
    });

}

sub dir {
    my ($self, $category) = @_;

    my $pages = [];

    foreach my $page (@{ $category->info("pages") }) {
        push(@{ $pages }, {
            title => $page->meta("title"),
            date => $page->template("date"),
            excerpt => $page->meta("excerpt"),
            url => $page->meta("url")
        });
    }

    return $self->{theme}->render("$self->{dir}/template/dir.tmpl", {
        themeDir => $self->{dir},
        title => $category->info("name"),
        name => $category->info("name"),
        root => $category->info("root"),
        pages => $pages,
    });
}

sub archives {
    my ($self, $root, @cats) = @_;
    my $source = "";

    my @categories = sort { $a->info("name") <=> $b->info("name") } @cats;
    my $filteredCats = [];

    my $catNum = 0;
    foreach my $category (@categories) {
        push (@$filteredCats, {
            name => $category->info("name"),
            dir => $category->info("dir"),
            pages => []
        });
        $catNum++;

        foreach my $page (@{ $category->info("pages") }) {
            push(@{ $filteredCats->[$catNum-1]->{"pages"} }, {
                title => $page->meta("title"),
                date => $page->template("date"),
                excerpt => $page->meta("excerpt"),
                url => $page->meta("url")
            });
        }
    }

    return $self->{theme}->render("$self->{dir}/template/archives.tmpl", {
        themeDir => $self->{dir},
        title => "Archives",
        root => @categories[0]->info("root"),
        categories => $filteredCats
    });

}

sub error {
    my ($self, $error, $root) = @_;

    return $self->{theme}->render("$self->{dir}/template/error.tmpl", {
        themeDir => $self->{dir},
        title => "Page Not Found",
        root => $root,
        error => $error
    });
}

sub main {
    my ($self, $page) = @_;

    return $self->{theme}->render("$self->{dir}/template/content.tmpl", {
        themeDir => $self->{dir},
        title => $page->meta("title"),
        content => $page->content,
        root => $page->meta("root"),
    });
}

1;
