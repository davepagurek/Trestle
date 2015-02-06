package Pahgawks;

use strict;

use lib "../..";
use HTML::Template;
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
    my $template = HTML::Template->new(
        filename => "themes/Pahgawks/template/content.tmpl",
        die_on_bad_params => 0
    );

    $template->param(
        title => $page->template("title"),
        category => $page->template("category"),
        content => $page->content,
        date => $page->template("date"),
        awards => $page->template("awards"),
        isAbout => $page->template("category") eq "about",
        isBlog => $page->template("category") eq "blog",
        isPortfolio => !($page->template("category") eq "about" || $page->template("category") eq "blog" || $page->template("category") eq "error"),
        root => $page->template("root"),
        youtube => $page->template("youtube"),
        header => ($page->template("browser") || $page->template("android") || $page->template("embed") || $page->template("video") || $page->template("buttons") || $page->template("art")),
        art => $page->template("art"),
        embed => $page->template("embed"),
        video => $page->template("video"),
        buttons => $page->template("buttons"),
        browser => $page->template("browser"),
        android => $page->template("android"),
    );

    return $template->output;

}

sub dir {
    my ($self, $category) = @_;
    my $source = "";

    #$source .= $self->header($category->info("name"), $category->info("name"), $category->info("root"));
    $source .= "<div class='section top' id='content'>
    <div class='wrapper'>
    <h1 class='cat'>" . $category->info("name") . "</h1>
    <p>
    <a href='" . $category->info("root") . "/programming' class='cat'>Programming</a>
    <a href='" . $category->info("root") . "/film' class='cat'>Animation</a>
    <a href='" . $category->info("root") . "/music' class='cat'>Music</a>
    <a href='" . $category->info("root") . "/art' class='cat'>Art</a>
    <a href='" . $category->info("root") . "/blog' class='cat'>Blog</a>
    <a href='" . $category->info("root") . "/archives' class='cat'>Everything</a>
    </p>";

    my $oldYear = 0;
    my $yearNum = 0;
    foreach my $page (@{ $category->info("pages") }) {
        if ($oldYear != $page->meta("date")->{year}) {
            $oldYear = $page->meta("date")->{year};
            $yearNum++;
            $source .= "</div>
            </div>
            <div class='section archive" . ($yearNum%2==0?"":" odd") . "' id='content'>
            <div class='wrapper icons'>
            <h2>" . $page->meta("date")->{year} . "</h2>";
        }

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
    }

    $source .= "</div>
    </div>";
    #$source .= $self->footer();


    return $source;
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
