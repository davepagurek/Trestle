package YouTube;

use lib "../..";

sub new {
	my $class = shift;
	my $self = {};

	$self->{pages} = 1;

	bless $self, $class;
	return $self;
}

sub content {
	my ($self, $content, $page) = @_;

	#replace youtube links with an embedded player
	$content =~ s/<p>(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/ ]{11})<\/p>/<p><iframe class='youtube embed' width='560' height='315' src='http:\/\/www.youtube.com\/embed\/$1?rel=0' frameborder='0' allowfullscreen><\/iframe><\/p>/ig;

	return $content;
}

1;