use lib "themes/Pahgawks";
use Pahgawks;
use lib "plugins/CodePrettify";
use CodePrettify;

root => "http://localhost/ManagerialCMS",
theme => new Pahgawks,
plugins => [new CodePrettify("tomorrow-night")],
cacheLife => 1000,