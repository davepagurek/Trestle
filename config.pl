use lib "themes/Pahgawks";
use Pahgawks;
use lib "plugins/CodePrettify";
use CodePrettify;

root => "http://localhost/ManagerialCMS",
theme => Pahgawks->new(),
plugins => [CodePrettify->new("tomorrow-night")],
cacheLife => 0,