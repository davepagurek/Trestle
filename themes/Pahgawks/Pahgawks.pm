package Pahgawks;

use strict;

use lib "../..";
use Page;

sub new {
    my $class = shift;
    my $self = { };

    bless $self, $class;
    return $self;
}

sub footer {
    my $self = shift;

    my $source = "<div class='section' id='footer'>
    <div class='wrapper'>
    <p>My name is Dave and I'm an animator, musician, programmer, designer and artist.</p>
    <p>Want to get in touch? Find/contact me elsewhere:</p>
    <p>
    <a href='mailto:dave\@davepagurek.com' class='button'>dave\@davepagurek.com</a>
    <a href='https://github.com/pahgawk/' class='button external' target='_blank'>GitHub</a>
    <a href='http://codepen.io/davepvm/' class='button external' target='_blank'>CodePen</a>
    <a href='http://pahgawk.newgrounds.com/' class='button external' target='_blank'>Newgrounds</a>
    <a href='http://www.youtube.com/pahgawk' class='button external' target='_blank'>YouTube</a>
    <a href='http://pahgawks.bandcamp.com/' class='button external' target='_blank'>Bandcamp</a>
    <a href='http://soundcloud.com/davidpvm' class='button external' target='_blank'>Soundcloud</a>
    </p>
    </div>
    </div>
    </body>
    </html>\n";

    return $source;
}

sub header {
    my ($self, $category, $title, $root) = @_;

    $category = lc($category);

    my $source = "<html>
    <head>
    <title>" .
    (($category eq "about")?$title:"$title - Dave Pagurek") .
    "</title>
    <link href='http://fonts.googleapis.com/css?family=Bitter:400' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,300' rel='stylesheet' type='text/css'>
    <meta http-equiv='X-UA-Compatible' content='IE=Edge'/>
    <meta name='theme-color' content='#e74c3c' />
    <meta name='viewport' content='width=device-width' />
    <link href='" . $root . "/themes/Pahgawks/Pahgawks.css' rel='stylesheet' type='text/css'>
    </head>
    <body>
    <div id='title'><h1><a href='http://www.davepagurek.com'>Dave Pagurek</a></h1></div>
    <div class='section' id='menu'>
    <a id='menuLabel' onclick=\"(document.getElementById('menu').className=='section')?document.getElementById('menu').className='section open':document.getElementById('menu').className='section';\">Menu</a>
    <div class='wrapper'>
    <a href='http://www.davepagurek.com' class='title'>Dave Pagurek</a>
    <div id='links'>
    <a href='" . $root . "'" . ($category eq "about" ? " class='selected'" : "") . ">About</a>
    <a href='" . $root . "/blog'" . ($category eq "blog" ? " class='selected'" : "") . ">Blog</a>
    <a href='" . $root . "/archives'" . (!($category eq "about" || $category eq "blog" || $category eq "error") ? " class='selected'" : "") . ">Portfolio</a>
    </div>
    </div>
    </div>";

    return $source;
}

sub content {
    my ($self, $page) = @_;
    my $source = "";

    $source .= $self->header($page->meta("category"), $page->meta("title"), $page->meta("root"));
    if ($page->meta("youtube")) {
        $source .= "<div class='section' id='video'>
        <div class='wrapper'>
        <iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/" . $page->meta("youtube") . "?rel=0' frameborder='0' allowfullscreen></iframe>
        </div>
        </div>\n";
    } elsif ($page->meta("browser") || $page->meta("android") || $page->meta("embed") || $page->meta("video") || $page->meta("buttons") || $page->meta("art")) {
        $source .= "<div class='section odd'>
        <div class='wrapper centered'>";

        if ($page->meta("browser")) {
            $source .= "<div class='browser big'>
            <div class='winbutton'></div>
            <div class='winbutton'></div>
            <div class='winbutton'></div>
            <div class='navbar'>" . $page->meta("browser")->{url} . "</div>
            <a href='" . $page->meta("browser")->{url} . "'>
            <img src='" . $page->meta("browser")->{image} . "' />
            </a>
            </div>";
        }
        if ($page->meta("android")) {
            $source .= "<div class='android big'>
            <div class='volume'></div>
            <div class='power'></div>
            <a href='" . $page->meta("android")->{url} . "'>
            <img src='" . $page->meta("android")->{image} . "' />
            </a>
            </div>";
        }
        if ($page->meta("art")) {
            $source .= "<a href='" . $page->meta("art") . "'><img src='" . $page->meta("art") . "' class='art' /></a>";
        }
        if ($page->meta("embed")) {
            $source .= $page->meta("embed");
        }
        if ($page->meta("video")) {
            $source .= $page->meta("video");
        }
        if ($page->meta("buttons")) {
            $source .= "<p>";
            foreach my $button (@{ $page->meta("buttons") }) {
                $source .= "<a class='button' href='" . $button->{url} . "'>" . $button->{text} . "</a>";
            }
            $source .= "</p>";
        }

        $source .= "</div>
        </div>\n";
    }
    $source .= "<div class='section' id='content'>
    <div class='wrapper'>\n";

    $source .= "<h1>" . $page->meta("title") . "</h1>\n";
    $source .= "<div id='date'>" . $page->meta("date")->{mday} . " " . $page->meta("date")->{fullmonth} . ", " . $page->meta("date")->{year} . "</div>\n";

    if ($page->meta("awards")) {
        $source .= "<div class='awards_full'>\n<table>\n";
        foreach my $award (@{ $page->meta("awards") }) {
            $source .= "<tr>
            <th><div class='" . $award->{award} . "' title='" . $award->{description} . "''></div></th>
            <td> " . $award->{description} . "</td>
            </tr>\n";
        }
        $source .= "</table>\n</div>\n";
    }

    $source .= $page->content;
    $source .= "</div>
    </div>";
    $source .= $self->footer();
    return $source;
}

sub dir {
    my ($self, $category) = @_;
    my $source = "";

    $source .= $self->header($category->info("name"), $category->info("name"), $category->info("root"));
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
    $source .= $self->footer();


    return $source;
}

sub archives {
    my ($self, $root, @cats) = @_;
    my $source = "";

    my @categories = sort { $a->info("rank") <=> $b->info("rank") } @cats;

    $source .= $self->header("archives", "Archives", $root);
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


    $source .= $self->footer();


    return $source;
}

sub error {
    my ($self, $error, $root) = @_;

    my $source = "";

    $source .= $self->header("error", "Page Not Found", $root);

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

    $source .= $self->footer();

    return $source;
}

sub main {
    my ($self, $page) = @_;
    my $source = "";

    $source .= $self->header("about", $page->meta("title"), $page->meta("root"));

    $source .= $page->content;

    $source .= $self->footer();
    return $source;
}

1;
