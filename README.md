<h1>Trestle</h1>
A light, extensible Perl CMS by Dave Pagurek

<h2>Screenshots</h2>
Admin interface:
![Admin interface](http://davepagurek.com/content/images/2015/2/trestle-admin-large.jpg)

<h2>Features</h2>
<ul>
    <li>Write posts including some HTML</li>
    <li>Make categories from the directory hierarchy</li>
    <li>Store metadata in JSON a comment at the top of of each post</li>
    <li>Automatically resize images</li>
    <li>Cache generated pages to reduce server load</li>
</ul>

<h2>Example post</h2>
```html

<!--
{
	"title": "Hooked on a Feeling",
	"thumbnail": "%root%/content/images/hasselhoff-thumbnail.jpg",
	"date": "2014-08-27",
    "youtube": "PJQVlVHsFF8"
}
-->

I made this song to represent the juxtaposition of societal norms and the microcosm of cultural phenomena exhibited through the greenscreen. It is very meaningful and artistic.

The boat part is actually for real though.

```

<h2>Example config file</h2>
```perl
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

use strict;

(
	dev => 1,
    root => "http://localhost/Trestle",
    theme => Pahgawks->new(),
    plugins => [CodePrettify->new("tomorrow-night"), GoogleAnalytics->new("UA-8777691-3"), YouTube->new(), DisqusComments->new("pahgawksanimations", 0)],
    cacheLife => 0
)

```
