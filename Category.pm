package Category;

use CGI;
use Page;
use JSON;
use strict;

sub new {
	my $class = shift;
	my $self = { };
	my $sourceDir = shift;
	$self->{root} = shift;

	my $json = JSON->new->allow_nonref;
	
	my @pages = ();
	foreach my $pageFile (glob("$sourceDir/*.html")) {
		push(@pages, Page->new($pageFile, $self->{root}, 1));
	}
	@{ $self->{pages} } = @pages;

	my $contents = do {
		local $/;
		open my $fh, $sourceDir . "/category.json" or die "Can't open category.json: $!";
		<$fh>;
	};
	my $categoryJSON = $json->decode($contents);

	$self->{name} = $categoryJSON->{name};

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