#!C:/xampp2/perl/bin/perl.exe
use CGI;
use Page;

my %config = do 'config.pl';
my $query = new CGI;
my $pageName = $query->param("page") || "webapps";
my $source = "content/" . $pageName . ".txt";
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

	my $content = "<!-- " . time . " -->\n";

	if (-e $source) {
		my $page = new Page($source, $config{root});
		$content .= $config{theme}->content($page);

		for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
			$content = $config{plugins}[$i]->content($content, $page);
		}

	} elsif (-d $sourceDir) {
		
		$content .= $config{theme}->dir($sourceDir);
	}

	open my $cached, ">", $sourceCache or die "Can't open $sourceCache: $!";
	print $cached $content;
	close $cached or die "can't close '$cached': $!";

	print $content;
}
