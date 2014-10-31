#!C:/xampp/perl/bin/perl.exe
use CGI;
use Page;
use strict;

my %config = do 'config.pl';
my $query = CGI->new();
my $pageName = $query->param("page") || "film/the-weight";
my $source = "content/" . $pageName . ".html";
my $sourceDir = "content/" . $pageName;
my $sourceCache = "cache/" . $pageName . "_cache.html";

print $query->header("text/html");

#Show cached page if it exists
my $remake = 0;
if (-e $sourceCache) {
	open my $cached, "<", $sourceCache or die "Can't open $source: $!";
	my $input = <$cached>;
	my $created = 0;
	if ($input =~ /<\!-- ([0-9]+) -->/) {
		$created = $1;
	}
	if (time-$created <= $config{cacheLife}*60*60) {
		while (<$cached>) {
			print $_;
		}
	} else {
		$remake = 1;
	}
	close $cached or die "can't close '$cached': $!";
} else {
	$remake = 1;
}

if ($remake) {

	#make cache subdirectory if it doesn't exist
	my $dir = "";
	$dir = $1 if $pageName =~ /^(.*)\/[\w-]/;
	my $cacheDir = "cache/" . $dir;
	if (!-d $cacheDir) {
		mkdir $cacheDir or die "Unable to create $cacheDir";
	}

	print "<!-- " . time . " -->\n";
	my $content = "";

	if (-e $source) {
		my $page = Page->new($source, $config{root});
		$content .= $config{theme}->content($page);

		for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
			$content = $config{plugins}[$i]->content($content, $page);
		}

	} elsif (-d $sourceDir) {
		
		$content .= $config{theme}->dir($sourceDir, $config{root});
	}

	open my $cached, ">", $sourceCache or die "Can't open $sourceCache: $!";
	print $cached $content;
	close $cached or die "can't close '$cached': $!";

	print $content;
}
