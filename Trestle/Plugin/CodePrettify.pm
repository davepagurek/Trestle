package Trestle::Plugin::CodePrettify;

sub new {
    my $class = shift;
    my $self = {};

    $self->{pages} = 1;


    #theme file names can be found at https://github.com/isagalaev/highlight.js/tree/master/src/styles
    #preview of themes can be found at http://highlightjs.org/static/test.html
    $self->{theme} = shift || "default";
    bless $self, $class;
    return $self;
}

sub content {
    my ($self, $content, $page) = @_;

    #Place inline code into a <span>
    $content =~ s/`([^\r\n]+?)`/<span class="code">$1<\/span>/ig;

    #If there is code to be highlighted
    if ($content =~ /<(pre|code).*>/) {

        #format code properly
        $content =~ s/<(?:pre|code)(?: lang="(.*)")*.*?>/<pre><code class="$1">/gi;
        $content =~ s/<\/(pre|code)>/<\/code><\/pre>/gi;

        my $theme = $self->{theme};

        #add script tag
        $content =~ s/<\/head>/<link rel="stylesheet" href="http:\/\/yandex\.st\/highlightjs\/8\.0\/styles\/$theme\.min\.css"><script src="http:\/\/yandex\.st\/highlightjs\/8\.0\/highlight\.min\.js"><\/script><script>hljs\.initHighlightingOnLoad\(\);<\/script><\/head>/g;
    }

    return $content;
}

1;
