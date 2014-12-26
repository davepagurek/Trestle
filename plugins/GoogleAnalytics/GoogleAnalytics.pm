package GoogleAnalytics;

use lib "../..";
use Page;

sub new {
	my $class = shift;
	my $self = {};

	$self->{pages} = 1;
	$self->{categories} = 1;
	$self->{archives} = 1;
	$self->{index} = 1;
	$self->{error} = 1;


	#theme file names can be found at https://github.com/isagalaev/highlight.js/tree/master/src/styles
	#preview of themes can be found at http://highlightjs.org/static/test.html
	$self->{id} = shift || "";
	bless $self, $class;
	return $self;
}

sub content {
	my ($self, $content, $page) = @_;

	my $code = "<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	  ga('create', '" . $self->{id} . "', 'auto');
	  ga('send', 'pageview');

	</script>";

	#Add code
	$content =~ s/<\/head>/$code<\/head>/g;

	return $content;
}

1;