package Trestle::Plugin::ImageCaption;

use String::Unescape;

sub new {
	my $class = shift;
	my $self = {};

	$self->{pages} = 1;

	bless $self, $class;
	return $self;
}

sub content {
	my ($self, $content, $page) = @_;

	#Replace image captions with actual HTML.
    #Image captions should be in the form:
    #   <img src="img" full="img-full" caption="Caption">
    $content =~ s/(?:<p>)*<img *src *= *"(.*)" *full *= *"(.*)" *caption *= *"(.*)" *\/*>(?:<\/p>)*/"<div class='img'><a href='$2'><img src='$1' \/><\/a> <p class='caption'>" . String::Unescape->unescape($3) . "<\/p><\/div>"/eig;

	return $content;
}

1;
