use lib "themes/Pahgawks";
use Pahgawks;
use lib "plugins/CodePrettify";
use CodePrettify;

theme => new Pahgawks,
plugins => [new CodePrettify("tomorrow-night")],
cacheLife => 0,