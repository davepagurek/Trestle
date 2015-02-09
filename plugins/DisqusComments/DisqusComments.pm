package DisqusComments;

use lib "../..";

sub new {
	my $class = shift;
	my $self = {};

	$self->{pages} = 1;
	$self->{shortname} = shift;
	$self->{default} = shift;
	if (!(defined $self->{default})) {
		$self->{default} = shift;
	}

	bless $self, $class;
	return $self;
}

sub content {
	my ($self, $content, $page) = @_;
	if ($page->meta("comments") == 1 || (!(defined $page->meta("comments")) && $self->{default})) {
		$disqus = "<div class='section odd'><div class='wrapper'><div id='disqus_thread'></div></div></div>
		    <script type='text/javascript'>
		        var disqus_shortname = '$self->{shortname}'; // required: replace example with your forum shortname
		        (function() {
		            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
		            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
		            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
		        })();
		    </script>
		    <noscript>Please enable JavaScript to view the <a href='http://disqus.com/?ref_noscript'>comments powered by Disqus.</a></noscript>";

		$content =~ s/<div class='section' id='footer'>/$disqus<div class='section' id='footer'>/i;
	}

	return $content;
}

1;