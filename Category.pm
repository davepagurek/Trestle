package Category;

use CGI;
use Page;
use JSON;
use strict;

sub new {
	my $class = shift;
	my $self = { };
	my $sourceDir = shift;
	if ($sourceDir =~ /^content\/(.+)$/) {
		$self->{dir} = $1;
	}
	$self->{root} = shift;

	my $json = JSON->new->allow_nonref;
	
	my @pages = ();
	foreach my $pageFile (glob("$sourceDir/*.html")) {
		push(@pages, Page->new($pageFile, $self->{root}, 1));
	}
	@{ $self->{pages} } = sort { $b->meta("date") <=> $a->meta("date") } @pages;

	my $contents = do {
		local $/;
		open my $fh, $sourceDir . "/category.json" or die "Can't open category.json from $sourceDir: $!";
		<$fh>;
	};
	my $categoryJSON = $json->decode($contents);

	foreach my $key (keys %$categoryJSON) {
		$self->{$key} = $categoryJSON->{$key};
	}

	bless $self, $class;
	return $self;
}

sub info {
	my ($self, $value) = @_;
	if (exists $self->{$value}) {
		return $self->{$value};
	} else {
		return 0;
	}
}

1;