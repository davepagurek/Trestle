#!C:/Perl/bin/perl.exe

use Trestle;
use lib "themes/Pahgawks";
use Pahgawks;
use lib "plugins/CodePrettify";
use CodePrettify;
use lib "plugins/GoogleAnalytics";
use GoogleAnalytics;
use lib "plugins/YouTube";
use YouTube;
use lib "plugins/DisqusComments";
use DisqusComments;

my $site = Trestle->new({
	dev => 1,
    root => "http://localhost/Trestle",
    theme => Pahgawks->new(),
    plugins => [CodePrettify->new("tomorrow-night"), GoogleAnalytics->new("UA-8777691-3"), YouTube->new(), DisqusComments->new("pahgawksanimations", 0)],
    cacheLife => 0
});

$site->run();
