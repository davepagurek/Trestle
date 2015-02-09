package Pahgawks;

use strict;

use lib "../..";
use HTML::Template;

sub new {
    my $class = shift;
    my $self = {
        dir => "themes/Pahgawks"
    };

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

sub content {
    my ($self, $page) = @_;

    return $self->render("themes/Pahgawks/template/content.tmpl", {
        title => $page->meta("title"),
        category => $page->meta("category"),
        content => $page->content,
        date => $page->meta("date"),
        awards => $page->meta("awards"),
        isAbout => $page->meta("category") eq "about",
        isBlog => $page->meta("category") eq "blog",
        isPortfolio => !($page->meta("category") eq "about" || $page->meta("category") eq "blog" || $page->meta("category") eq "error"),
        root => $page->meta("root"),
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
            url => $page->meta("url")
        });
    }

    return $self->render("themes/Pahgawks/template/dir.tmpl", {
        title => $category->info("name"),
        name => $category->info("name"),
        root => $category->info("root"),
        years => $years,
        isAbout => $category->info("name") eq "about",
        isBlog => $category->info("name") eq "blog",
        isPortfolio => !($category->info("name") eq "about" || $category->info("name") eq "blog" || $category->info("name") eq "error"),
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
                url => $page->meta("url")
            });

            $pageNum++;
            if ($pageNum==4) {
                last;
            }

        }
    }

    return $self->render("themes/Pahgawks/template/archives.tmpl", {
        title => "Portfolio",
        root => @categories[0]->info("root"),
        isPortfolio => 1,
        categories => $filteredCats
    });

}

sub error {
    my ($self, $error, $root) = @_;

    return $self->render("themes/Pahgawks/template/error.tmpl", {
        title => "Page Not Found",
        isAbout => 0,
        isBlog => 0,
        isPortfolio => 0,
        root => $root,
        error => $error
    });

    my $source = "";

    #$source .= $self->header("error", "Page Not Found", $root);

    $source .= "<div class='section'>
    <div class='wrapper'>
    <h1>Page Not Found</h1>
    <img class='aligncenter' src='$root/content/images/2014/12/404.jpg' />
    <p>Sadly, the page you were looking for is not actually here. If you think a link on the site is broken or something, <a href='mailto:dave\@davepagurek.com'>send me an email</a> and I'll try to fix it. Otherwise, you can probably find what you were looking for somewhere in one of these categories:</p>

    <p>
    <a href='" . $root . "/programming' class='cat'>Programming</a>
    <a href='" . $root . "/film' class='cat'>Animation</a>
    <a href='" . $root . "/music' class='cat'>Music</a>
    <a href='" . $root . "/art' class='cat'>Art</a>
    <a href='" . $root . "/blog' class='cat'>Blog</a>
    <a href='" . $root . "/archives' class='cat'>Everything</a>
    </p>
    </div>
    </div>

    </div>";

    #$source .= $self->footer();

    return $source;
}

sub main {
    my ($self, $page) = @_;

    return $self->render("themes/Pahgawks/template/content.tmpl", {
        title => $page->meta("title"),
        content => $page->content,
        isAbout => 1,
        isBlog => 0,
        isPortfolio => 0,
        root => $page->meta("root"),
    });
}

1;
