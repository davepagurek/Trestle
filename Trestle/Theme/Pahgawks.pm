package Trestle::Theme::Pahgawks;

use strict;

use lib "../..";
use Trestle::Theme;

sub new {
    my $class = shift;
    my $self = {
        dir => "Trestle/Theme/Pahgawks",
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
        category => $page->meta("category"),
        content => $page->content,
        date => $page->meta("date"),
        awards => $page->meta("awards"),
        isAbout => $page->meta("category") eq "about",
        isBlog => $page->meta("category") eq "blog",
        isPortfolio => !($page->meta("category") eq "about" || $page->meta("category") eq "blog" || $page->meta("category") eq "error"),
        root => $page->root,
        youtube => $page->meta("youtube"),
        header => ($page->meta("browser") || $page->meta("android") || (!$page->meta("youtube") && ($page->meta("embed") || $page->meta("video"))) || $page->meta("buttons") || $page->meta("art"))?1:0,
        art => $page->meta("art"),
        embed => $page->meta("youtube")?undef:$page->meta("embed"),
        video => $page->meta("youtube")?undef:$page->meta("video"),
        buttons => $page->meta("buttons"),
        browser => $page->meta("browser"),
        android => $page->meta("android"),
    });

}

sub dir {
    my ($self, $category) = @_;

    my $years = [];

    my $oldYear = 0;
    my $yearNum = 0;
    foreach my $page (@{ $category->info("pages") }) {
        if ($oldYear != $page->meta("date")->{year}) {
            push(@$years, {
                year => $page->meta("date")->{year},
                pages => []
            });

            $oldYear = $page->meta("date")->{year};
            $yearNum++;
        }

        my $languages = "";
        my $j = 0;
        if ($page->meta("languages")) {
            foreach my $language (@{ $page->meta("languages") }) {
                $languages .= $language;
                if (scalar @{ $page->meta("languages") } == 2 && $j == 0) {
                    $languages .= " and ";
                } elsif ($j == scalar @{ $page->meta("languages") }-2) {
                    $languages .= ", and ";
                } elsif ($j<scalar @{ $page->meta("languages") }-1) {
                    $languages .= ", ";
                }
                $j++;
            }
        }

        push(@{ $years->[$yearNum-1]->{"pages"} }, {
            title => $page->meta("title"),
            date => $page->template("date"),
            awards => $page->template("awards"),
            languages => $languages,
            excerpt => $page->meta("excerpt"),
            thumbnail => $page->meta("thumbnail"),
            url => $page->url
        });
    }

    return $self->{theme}->render("$self->{dir}/template/dir.tmpl", {
        themeDir => $self->{dir},
        title => $category->info("name"),
        name => $category->info("name"),
        root => $category->info("root"),
        years => $years,
        isAbout => lc($category->info("name")) eq "about",
        isBlog => lc($category->info("name")) eq "blog",
        isPortfolio => !(lc($category->info("name")) eq "about" || lc($category->info("name")) eq "blog"),
    });
}

sub archives {
    my ($self, $root, @cats) = @_;
    my $source = "";

    my @categories = sort { $a->info("rank") <=> $b->info("rank") } @cats;
    my $filteredCats = [];

    my $catNum = 0;
    foreach my $category (@categories) {
        push (@$filteredCats, {
            name => $category->info("name"),
            dir => $category->info("dir"),
            pages => []
        });
        $catNum++;

        my $pageNum = 0;
        foreach my $page (@{ $category->info("pages") }) {
            my $languages = "";
            my $j = 0;
            if ($page->meta("languages")) {
                foreach my $language (@{ $page->meta("languages") }) {
                    $languages .= $language;
                    if (scalar @{ $page->meta("languages") } == 2 && $j == 0) {
                        $languages .= " and ";
                    } elsif ($j == scalar @{ $page->meta("languages") }-2) {
                        $languages .= ", and ";
                    } elsif ($j<scalar @{ $page->meta("languages") }-1) {
                        $languages .= ", ";
                    }
                    $j++;
                }
            }

            push(@{ $filteredCats->[$catNum-1]->{"pages"} }, {
                title => $page->meta("title"),
                date => $page->template("date"),
                awards => $page->template("awards"),
                languages => $languages,
                excerpt => $page->meta("excerpt"),
                thumbnail => $page->meta("thumbnail"),
                url => $page->url
            });

            $pageNum++;
            if ($pageNum==4) {
                last;
            }

        }
    }

    return $self->{theme}->render("$self->{dir}/template/archives.tmpl", {
        themeDir => $self->{dir},
        title => "Portfolio",
        root => @categories[0]->info("root"),
        isPortfolio => 1,
        categories => $filteredCats
    });

}

sub error {
    my ($self, $error, $root) = @_;

    return $self->{theme}->render("$self->{dir}/template/error.tmpl", {
        themeDir => $self->{dir},
        title => "Page Not Found",
        isAbout => 0,
        isBlog => 0,
        isPortfolio => 0,
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
        isAbout => 1,
        isBlog => 0,
        isPortfolio => 0,
        root => $page->root,
    });
}

1;
