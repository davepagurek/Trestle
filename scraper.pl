use strict;
use LWP::Simple;
use JSON;
use Unicode::Normalize;
use HTML::Entities;
use open ':std', ':encoding(UTF-8)';

my $data = get 'http://www.davepagurek.com/archives/?wptheme=ConversionShit';
my $content = "";
my $filename = "";
my $category = "";
my $meta = "";
my $isMeta = 0;
my $json = JSON->new->allow_nonref;
foreach my $line (split /\n/, $data) {
	#GODDAMMIT WORDPRESS AND YOUR SPECIAL CHARACTERS
	$line =~ s/&#8217;/'/g;
	$line =~ s/&#8230;/\.\.\./g;
	$line =~ s/&#038;/&/g;
	$line =~ s/[\r\n]/\n/g;
	if ($line =~ /^-->/) {
		my $metaJSON = $json->decode($meta);
		$category = $metaJSON->{category};
		$filename = NFKD($metaJSON->{title});
		$filename =~ s/\p{NonspacingMark}//g;
		$filename =~ s/[^A-Za-z0-9 ]//g;
		$filename =~ s/\s+/-/g;
		$filename = lc($filename);
		$isMeta = 0;
	}

	if ($line =~ /####/) {
		if (!-d "content") {
			mkdir "content" or die "Unable to create content: $!";
		}
		if (!-d "content/$category") {
			mkdir "content/$category" or die "Unable to create content/$category: $!";
		}
		open my $f, ">", "content/$category/$filename.html"  or die "Can't open content/$category/$filename.html: $!";
		print $f $content;
		close $f or die "can't close content/$category/$filename.html: $!";
		print "content/$category/$filename.html\n";
		$content = "";
		$category = "";
		$filename = "";
		$meta = "";
		$isMeta = 0;
	} else {
		$content .= $line;
		if ($isMeta) {
			$meta .= $line;
		}
		if ($line =~ /<!--/) {
			$isMeta = 1;
		}
	}
}