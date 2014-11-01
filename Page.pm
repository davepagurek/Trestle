package Page;

use CGI;
use JSON;
use Time::Piece;
use strict;

sub new {
	my $class = shift;
	my $self = { };
	my $source = shift;
	my $url = $source;
	$url =~ s/^content\/(.*).html$/$1/;
	$self->{source} = $source;
	$self->{url} = $url;
	$self->{root} = shift;
	my $onlyMeta = shift;
	my $cgi = CGI->new();
	my $json = JSON->new->allow_nonref;
	if (-e $source) {
		open my $page, "<", $source or die "Can't open $source: $!";
		my $meta = 0;
		my $metaSource = "";
		my $content = "";
		my $isCode = 0;
		while (<$page>) {
			chomp;
			my $line = $_;
			if (!$isCode) {
				$line =~ s/^\s+|\s+$//g;
			}

			if ($line eq "<!--") {
				$meta = 1;
				next;
			}

			#ignore blank lines
			if (!$line) {
				next;

			} elsif ($meta) {

				#Four hash signs indicates the end of the meta section
				if ($line eq "-->") {
					$meta = 0;
					my $metaJSON = $json->decode($metaSource);
					foreach my $key (keys %$metaJSON) {
						$self->{$key} = $metaJSON->{$key};
					}
					if ($self->{date}) {
						$self->{date} = Time::Piece->strptime($self->{date}, "%Y-%m-%d");
					}

					if ($onlyMeta) {
						last;
					}

				#Add meta values if they exist
				} else {
					$metaSource .= $line;
				}
			} else {

				#If it's in a code tag, don't format innards
				if ($line =~ /(.*<(?:code|pre).*>)(.*)/) {
					$isCode = 1;
					$content .= $1;
					if ($2) {
						$content .= $cgi->escapeHTML($2);
					}
				} elsif ($isCode) {
					if ($line =~ /(.*)(<\/(?:code|pre).*)/) {
						$isCode = 0;
						$content .= $cgi->escapeHTML($1) . $2 . "\n";
					} else {
						$content .= $cgi->escapeHTML($line) . "\n";
					}

				#If it's in a heading or p tag, don't wrap in a p tag
				} elsif ($line =~ /(?:^<(?:h(?:[0-9]+)|ul|li|table|th|tr|td|p).*>)|(?:<\/(?:h(?:[0-9]+)|ul|li|table|th|tr|td|p)>$)/i) {
					$content .= $line . "\n";
				} else {
					$content .= "<p>" . $line . "</p>\n";
				}
			}
		}
		close $page or die "can't read close '$page': $!";
		if (!$onlyMeta) {
			$self->{content} = $content;
		}
	}

	bless $self, $class;
	return $self;
}

sub content {
	my ($self) = @_;
	return $self->{content};
}

sub meta {
	my ($self, $value) = @_;
	if (exists $self->{$value}) {
		return $self->{$value};
	} else {
		return 0;
	}
}

1;