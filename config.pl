use lib "themes/Pahgawks";
use Pahgawks;
use lib "plugins/CodePrettify";
use CodePrettify;
use lib "plugins/GoogleAnalytics";
use GoogleAnalytics;

use strict;

(
    root => "http://localhost/Trestle",
    theme => Pahgawks->new(),
    plugins => [CodePrettify->new("tomorrow-night"), GoogleAnalytics->new("UA-8777691-3")],
    cacheLife => 0
)
