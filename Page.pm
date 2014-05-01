package Page;

use CGI;

sub new {
	my $class = shift;
	my $source = shift;
	my $self = { };
	my $cgi = new CGI;
	$self{source} = $source;
	if (-e $source) {
		open my $page, "<", $source or die "Can't open $source: $!";
		my $meta = 1;
		my $content = "";
		my $isCode = 0;
		while (<$page>) {
			chomp;
			$line = $_;
			if (!$isCode) {
				$line =~ s/^\s+|\s+$//g;
			}

			#ignore blank lines
			if (!$line) {
				next;

			} elsif ($meta) {

				#Four hash signs indicates the end of the meta section
				if ($line eq "####") {
					$meta = 0;

				#Add meta values if they exist
				} elsif ($line =~ /(\w+): *(.+)/) {
					$self{$1} = $2;
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
		$self{content} = $content;
	}

	bless $self, $class;
	return $self;
}

sub content {
	my ($self) = @_;
	return $self{content};
}

sub meta {
	my ($self, $value) = @_;
	if (exists $self{$value}) {
		return $self{$value};
	} else {
		return 0;
	}
}

1;