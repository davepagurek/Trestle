package Pahgawks;

use strict;

use lib "../..";
use Page;
use Time::Piece;

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
			#my @buttons = $page->meta("buttons");
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
	my $date = Time::Piece->strptime($page->meta("date"), "%Y-%m-%d");
	$source .= "<div id='date'>" . $date->mday . " " . $date->fullmonth . ", " . $date->year . "</div>\n";

	if ($page->meta("awards")) {
		my @awards = split(",", $page->meta("awards"));
		$source .= "<div class='awards_full'>\n<table>\n";
		for (my $j = 0; $j<scalar @awards; $j+=2) {
			$source .= "<tr>
				<th><div class='" . $awards[$j] . "' title='" . $awards[$j+1] . "''></div></th>
				<td> " . $awards[$j+1] . "</td>
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
	my ($self, $sourceDir, $root) = @_;
	my @pages = ();
	my $source = "";
	foreach my $pageFile (glob("$sourceDir/*")) {
		push(@pages, Page->new($pageFile, $root));
	}
	
	my $title = "Test";

	# $source .= "<html>
	# <head>
	# <title>" .
	# 	$title . 
	# 	"</title>
	# 	<link href='http://fonts.googleapis.com/css?family=Bitter:400' rel='stylesheet' type='text/css'>
	# 	<link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,300' rel='stylesheet' type='text/css'>
	# 	<link href='" . $root . "/themes/Pahgawks/Pahgawks.css' rel='stylesheet' type='text/css'>
	# 	</head>
	# 	<body>
	# 	<div id='title'><h1><a href='http://www.pahgawks.com'>Dave Pagurek</a></h1></div>
	# 	<div class='section' id='menu'>
	# 	  <a id='menuLabel' onclick=\"(document.getElementById('menu').className=='section')?document.getElementById('menu').className='section open':document.getElementById('menu').className='section';\">Menu</a>
	# 	  <div class='wrapper'>
	# 	    <a href='http://www.pahgawks.com' class='title'>Dave Pagurek</a>
	# 	      <div id='links'>
	# 	      <a href='http://www.pahgawks.com'>About</a>
	# 	      <a href='http://www.pahgawks.com/blog'>Blog</a>
	# 	      <a href='http://www.pahgawks.com/archives' class='selected'>Portfolio</a>
	# 	    </div>
	# 	  </div>
	# 	</div>";
	foreach my $page (@pages) {
		#$source .= "<div>" . $page->meta("title") . "</div>";
		$source .= $page->meta("source") . "\n";
	}
	
	# push(@pages, "a");
	# push(@pages, "b");
	# push(@pages, "c");
	# foreach my $page (@pages) {
	# 	$source .= $page . "\n";
	# }


	# $source .= "</div>
	# 	</div>
	# 	<div class='section' id='footer'>
	# 	  <div class='wrapper'>
	# 	    <p>My name is Dave and I'm an animator, musician, programmer, designer and artist.</p>
	# 	    <p>Want to get in touch? Find/contact me elsewhere:</p>
	# 	    <p><a href='mailto:dave\@pahgawks.com' class='button'>dave\@pahgawks.com</a> <a href='http://davepvm.tumblr.com/' class='button external' target='_blank'>Tumblr</a> <a href='http://pahgawk.deviantart.com/' class='button external' target='_blank'>DeviantART</a> <a href='http://pahgawk.newgrounds.com/' class='button external' target='_blank'>Newgrounds</a> <a href='http://www.youtube.com/pahgawk' class='button external' target='_blank'>YouTube</a> <a href='http://www.twitter.com/davepvm' class='button external' target='_blank'>Twitter</a> <a href='http://pahgawks.bandcamp.com/' class='button external' target='_blank'>Bandcamp</a> <a href='http://soundcloud.com/davidpvm' class='button external' target='_blank'>Soundcloud</a> <a href='https://github.com/pahgawk/' class='button external' target='_blank'>GitHub</a>
	# 	      </p>
	# 	    </div>
	# 	</div>
	# 	</body>
	# 	</html>\n";


	return $source;
}

1;