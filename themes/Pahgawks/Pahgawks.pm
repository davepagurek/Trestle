package Pahgawks;

use strict;

use lib "../..";
use Page;

sub new {
    my $class = shift;
    my $self = {
        dir => "themes/Pahgawks"
    };

    bless $self, $class;
    return $self;
}


sub content {
    my ($self, $page) = @_;

    return $page->render("themes/Pahgawks/template/content.tmpl", {
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
        header => ($page->meta("browser") || $page->meta("android") || $page->meta("embed") || $page->meta("video") || $page->meta("buttons") || $page->meta("art"))?1:0,
        art => $page->meta("art"),
        embed => $page->meta("embed"),
        video => $page->meta("video"),
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

    return $category->render("themes/Pahgawks/template/dir.tmpl", {
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

    #$source .= $self->header("archives", "Archives", $root);
    $source .= "<div class='section top' id='content'>
    <div class='wrapper'>
    <h1 class='cat'>Everything</h1>
    <p>
    <a href='" . $root . "/programming' class='cat'>Programming</a>
    <a href='" . $root . "/film' class='cat'>Animation</a>
    <a href='" . $root . "/music' class='cat'>Music</a>
    <a href='" . $root . "/art' class='cat'>Art</a>
    <a href='" . $root . "/blog' class='cat'>Blog</a>
    <a href='" . $root . "/archives' class='cat'>Everything</a>
    </p>
    </div>
    </div>";

    my $section = 1;
    foreach my $category (@categories) {
        $source .= "<div class='section archive" . ($section%2==0?"":" odd") . "' id='content'>
        <div class='wrapper icons'>
        <h2>" . $category->info("name") . "</h2>";

        my $pageNum = 0;
        foreach my $page (@{ $category->info("pages") }) {

            $source .= "<div class='animation'><div class='icon' style='background-image:url(" . $page->meta("thumbnail") . ")'><a href=" . $page->meta("url") . "></a></div><div class='info'><a class='title' href='" . $page->meta("url") . "''>" . $page->meta("title") . "</a>";

            if ($page->meta("awards")) {
                $source .= "<div class='awards'>\n";
                foreach my $award (@{ $page->meta("awards") }) {
                    $source .= "<div class='" . $award->{award} . "' title='" . $award->{description} . "''></div>";
                }
                $source .= "</div>\n";
            }

            if ($page->meta("languages")) {
                $source .= "<div class='languages'>Made with ";
                my $j = 0;
                foreach my $language (@{ $page->meta("languages") }) {
                    $source .= $language;
                    if (scalar @{ $page->meta("languages") } == 2 && $j == 0) {
                        $source .= " and ";
                    } elsif ($j == scalar @{ $page->meta("languages") }-2) {
                        $source .= ", and ";
                    } elsif ($j<scalar @{ $page->meta("languages") }-1) {
                        $source .= ", ";
                    }
                    $j++;
                }
                $source .= "</div>";
            }

            $source .= "<p>" . $page->meta("excerpt") . "</p>";
            $source .= "<div class='date'>" . $page->meta("date")->{mday} . " " . $page->meta("date")->{fullmonth} . ", " . $page->meta("date")->{year} . "</div>
            </div>
            </div>";

            $pageNum++;
            if ($pageNum >= 4) {
                last;
            }
        }
        $source .= "<div class='centered large'>
        <a href='" . $category->info("dir") . "' class='button'>View " . $category->info("name") . "</a>
        </div>
        </div></div>\n";

        $section++;
    }


    #$source .= $self->footer();


    return $source;
}

sub error {
    my ($self, $error, $root) = @_;

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
    my $source = "";

    #$source .= $self->header("about", $page->meta("title"), $page->meta("root"));

    $source .= $page->content;

    #$source .= $self->footer();
    return $source;
}

1;
