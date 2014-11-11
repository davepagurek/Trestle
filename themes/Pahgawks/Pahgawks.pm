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

sub content {
	my ($self, $page) = @_;
	my $source = "";

	$source .= "<html>
	<head>
	<title>" .
		$page->meta("title") . 
		"</title>
		<link href='http://fonts.googleapis.com/css?family=Bitter:400' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,300' rel='stylesheet' type='text/css'>
		<link href='" . $page->meta("root") . "/themes/Pahgawks/Pahgawks.css' rel='stylesheet' type='text/css'>
		</head>
		<body>
		<div id='title'><h1><a href='http://www.pahgawks.com'>Dave Pagurek</a></h1></div>
		<div class='section' id='menu'>
		  <a id='menuLabel' onclick=\"(document.getElementById('menu').className=='section')?document.getElementById('menu').className='section open':document.getElementById('menu').className='section';\">Menu</a>
		  <div class='wrapper'>
		    <a href='http://www.pahgawks.com' class='title'>Dave Pagurek</a>
		      <div id='links'>
		      <a href='http://www.pahgawks.com'>About</a>
		      <a href='http://www.pahgawks.com/blog'>Blog</a>
		      <a href='http://www.pahgawks.com/archives' class='selected'>Portfolio</a>
		    </div>
		  </div>
		</div>";
	if ($page->meta("youtube")) {
		$source .= "<div class='section' id='video'>
				<div class='wrapper'>
					<iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/" . $page->meta("youtube") . "?rel=0' frameborder='0' allowfullscreen></iframe>
				</div>
			</div>\n";
	}
	if ($page->meta("browser") || $page->meta("embed") || $page->meta("buttons") || $page->meta("art")) {
		$source .= "<div class='section odd'>
			<div class='wrapper centered'>";
		
		if ($page->meta("browser")) {
			$source .= "<div class='browser big'>
				<div class='winbutton'></div>
				<div class='winbutton'></div>
				<div class='winbutton'></div>
				<div class='navbar'>" . $page->meta("browser")->{url} . "</div>
				<a href='" . $page->meta("browser")->{url} . "''>
					<img src='" . $page->meta("browser")->{image} . "'' />
				</a>
				</div>";
		}
		if ($page->meta("art")) {
			$source .= "<a href='" . $page->meta("art") . "'><img src='" . $page->meta("art") . "' class='art' /></a>";
		}
		if ($page->meta("embed")) {
			$source .= $page->meta("embed");
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
	$source .= "<div id='date'>" . $page->meta("date")->mday . " " . $page->meta("date")->fullmonth . ", " . $page->meta("date")->year . "</div>\n";

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
		</div>
		<div class='section' id='footer'>
		  <div class='wrapper'>
		    <p>My name is Dave and I'm an animator, musician, programmer, designer and artist.</p>
		    <p>Want to get in touch? Find/contact me elsewhere:</p>
		    <p><a href='mailto:dave\@pahgawks.com' class='button'>dave\@pahgawks.com</a> <a href='http://davepvm.tumblr.com/' class='button external' target='_blank'>Tumblr</a> <a href='http://pahgawk.deviantart.com/' class='button external' target='_blank'>DeviantART</a> <a href='http://pahgawk.newgrounds.com/' class='button external' target='_blank'>Newgrounds</a> <a href='http://www.youtube.com/pahgawk' class='button external' target='_blank'>YouTube</a> <a href='http://www.twitter.com/davepvm' class='button external' target='_blank'>Twitter</a> <a href='http://pahgawks.bandcamp.com/' class='button external' target='_blank'>Bandcamp</a> <a href='http://soundcloud.com/davidpvm' class='button external' target='_blank'>Soundcloud</a> <a href='https://github.com/pahgawk/' class='button external' target='_blank'>GitHub</a>
		      </p>
		    </div>
		</div>
		</body>
		</html>\n";
	return $source;
}

sub dir {
	my ($self, $category) = @_;
	my $source = "";

	$source .= "<html>
	<head>
	<title>" .
		$category->info("name") . 
		"</title>
		<link href='http://fonts.googleapis.com/css?family=Bitter:400' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,300' rel='stylesheet' type='text/css'>
		<link href='" . $category->info("root") . "/themes/Pahgawks/Pahgawks.css' rel='stylesheet' type='text/css'>
		</head>
		<body>
		<div id='title'><h1><a href='http://www.pahgawks.com'>Dave Pagurek</a></h1></div>
		<div class='section' id='menu'>
		  <a id='menuLabel' onclick=\"(document.getElementById('menu').className=='section')?document.getElementById('menu').className='section open':document.getElementById('menu').className='section';\">Menu</a>
		  <div class='wrapper'>
		    <a href='http://www.pahgawks.com' class='title'>Dave Pagurek</a>
		      <div id='links'>
		      <a href='http://www.pahgawks.com'>About</a>
		      <a href='http://www.pahgawks.com/blog'>Blog</a>
		      <a href='http://www.pahgawks.com/archives' class='selected'>Portfolio</a>
		    </div>
		  </div>
		</div>
		<div class='section top' id='content'>
		<div class='wrapper'>
		<h1 class='cat'>" . $category->info("name") . "</h1>
		<p>
		<a href='http://www.davepagurek.com/film' class='cat'>Animation</a>
		<a href='http://www.davepagurek.com/programming' class='cat'>Programming</a>
		<a href='http://www.davepagurek.com/art' class='cat'>Art</a>
		<a href='http://www.davepagurek.com/music' class='cat'>Music</a>
		<a href='http://www.davepagurek.com/blog' class='cat'>Blog</a>
		<a href='http://www.davepagurek.com/archives' class='cat'>Everything</a>
		</p>";

	my $oldYear = 0;
	my $yearNum = 0;
	foreach my $page (@{ $category->info("pages") }) {
		if ($oldYear != $page->meta("date")->year) {
			$oldYear = $page->meta("date")->year;
			$yearNum++;
			$source .= "</div>
				</div>
				<div class='section archive" . ($yearNum%2==0?"":" odd") . "' id='content'>
				<div class='wrapper icons'>
				<h2>" . $page->meta("date")->year . "</h2>";
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
		$source .= "<div class='date'>" . $page->meta("date")->mday . " " . $page->meta("date")->fullmonth . ", " . $page->meta("date")->year . "</div>
			</div>
			</div>";
	}

	$source .= "</div>
		</div>
		<div class='section' id='footer'>
		  <div class='wrapper'>
		    <p>My name is Dave and I'm an animator, musician, programmer, designer and artist.</p>
		    <p>Want to get in touch? Find/contact me elsewhere:</p>
		    <p><a href='mailto:dave\@pahgawks.com' class='button'>dave\@pahgawks.com</a> <a href='http://davepvm.tumblr.com/' class='button external' target='_blank'>Tumblr</a> <a href='http://pahgawk.deviantart.com/' class='button external' target='_blank'>DeviantART</a> <a href='http://pahgawk.newgrounds.com/' class='button external' target='_blank'>Newgrounds</a> <a href='http://www.youtube.com/pahgawk' class='button external' target='_blank'>YouTube</a> <a href='http://www.twitter.com/davepvm' class='button external' target='_blank'>Twitter</a> <a href='http://pahgawks.bandcamp.com/' class='button external' target='_blank'>Bandcamp</a> <a href='http://soundcloud.com/davidpvm' class='button external' target='_blank'>Soundcloud</a> <a href='https://github.com/pahgawk/' class='button external' target='_blank'>GitHub</a>
		      </p>
		    </div>
		</div>
		</body>
		</html>\n";


	return $source;
}

sub error {
	my ($self, $error, $root) = @_;

	my $source = "";

	$source .= "<html>
	<head>
	<title>
		Page Not Found
		</title>
		<link href='http://fonts.googleapis.com/css?family=Bitter:400' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,300' rel='stylesheet' type='text/css'>
		<link href='" . $root . "/themes/Pahgawks/Pahgawks.css' rel='stylesheet' type='text/css'>
		</head>
		<body>
		<div id='title'><h1><a href='http://www.pahgawks.com'>Dave Pagurek</a></h1></div>
		<div class='section' id='menu'>
		  <a id='menuLabel' onclick=\"(document.getElementById('menu').className=='section')?document.getElementById('menu').className='section open':document.getElementById('menu').className='section';\">Menu</a>
		  <div class='wrapper'>
		    <a href='http://www.pahgawks.com' class='title'>Dave Pagurek</a>
		      <div id='links'>
		      <a href='http://www.pahgawks.com'>About</a>
		      <a href='http://www.pahgawks.com/blog'>Blog</a>
		      <a href='http://www.pahgawks.com/archives' class='selected'>Portfolio</a>
		    </div>
		  </div>
		</div>
		
		<div class='section'>
			<div class='wrapper'>
				<h1>Page Not Found</h1>
				<img class='aligncenter' src='http://www.davepagurek.com/wp-content/uploads/2012/02/404.jpg' />
				<p>Sadly, the page you were looking for is not actually here. If you think a link on the site is broken or something, <a href='mailto:dave\@davepagurek.com'>send me an email</a> and I'll try to fix it. Otherwise, you can probably find what you were looking for somewhere in one of these categories:</p>

				<a href='http://www.davepagurek.com/film' class='cat'>Animation</a>
				<a href='http://www.davepagurek.com/games' class='cat'>Games</a>
				<a href='http://www.davepagurek.com/category/art' class='cat'>Visual Art</a>
				<a href='http://www.davepagurek.com/music' class='cat'>Music</a>
				<a href='http://www.davepagurek.com/webapps' class='cat'>Web and App Programming</a>
				<a href='http://www.davepagurek.com/blog' class='cat'>Blog</a>
				<a href='http://www.davepagurek.com/archives' class='cat'><strong>Everything</strong></a>
				</div>
			</div>

		</div>
		<div class='section' id='footer'>
		  <div class='wrapper'>
		    <p>My name is Dave and I'm an animator, musician, programmer, designer and artist.</p>
		    <p>Want to get in touch? Find/contact me elsewhere:</p>
		    <p><a href='mailto:dave\@pahgawks.com' class='button'>dave\@pahgawks.com</a> <a href='http://davepvm.tumblr.com/' class='button external' target='_blank'>Tumblr</a> <a href='http://pahgawk.deviantart.com/' class='button external' target='_blank'>DeviantART</a> <a href='http://pahgawk.newgrounds.com/' class='button external' target='_blank'>Newgrounds</a> <a href='http://www.youtube.com/pahgawk' class='button external' target='_blank'>YouTube</a> <a href='http://www.twitter.com/davepvm' class='button external' target='_blank'>Twitter</a> <a href='http://pahgawks.bandcamp.com/' class='button external' target='_blank'>Bandcamp</a> <a href='http://soundcloud.com/davidpvm' class='button external' target='_blank'>Soundcloud</a> <a href='https://github.com/pahgawk/' class='button external' target='_blank'>GitHub</a>
		      </p>
		    </div>
		</div>
		</body>
		</html>\n";

	return $source;
}

1;