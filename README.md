<h1>Trestle</h1>
![Trestle logo](https://github.com/pahgawk/Trestle/blob/master/admin/img/trestle.png?raw=true)
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

<h2>Setup</h2>
<h3>Trestle config</h3>
Here is an example `index.fcgi`:

```perl
use Trestle;
use Trestle::Theme::Pahgawks;
use Trestle::Plugin::CodePrettify;
use Trestle::Plugin::GoogleAnalytics;
use Trestle::Plugin::YouTube;
use Trestle::Plugin::DisqusComments;
use Trestle::Plugin::ImageCaption;

my $site = Trestle->new({
    dev => 1,
    root => "http://localhost/Trestle",
    theme => Trestle::Theme::Pahgawks->new(),
    plugins => [
        Trestle::Plugin::CodePrettify->new("tomorrow-night"),
        Trestle::Plugin::GoogleAnalytics->new("UA-8777691-3"),
        Trestle::Plugin::YouTube->new(),
        Trestle::Plugin::ImageCaption->new()
    ],
    cacheLife => 0
});

$site->run();
```

<ul>
    <li>If `dev` is enabled, `CGI::Carp` will send warnings and fatal errors to the browser</li>
    <li>`cacheLife` is the number of hours before a cached page is set to be rerendered</li>
</ul>

<h3>Apache config</h3>
In `.htaccess`, uncomment the respective line based on your system setup:
```
#Use this if your Apache setup supports mod_fcgid
#AddHandler fcgid-script .fcgi

#Use this if you want to run Trestle as normal cgi
AddHandler cgi-script .fcgi
```

<h2>Writing</h2>
Here is an example page to demonstrate page structure. 

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

<ul>
    <li>Metadata is written as a JSON object in an HTML comment at the top of the page</li>
    <li>`%root%` will be replaced by the root directory as defined in `index.fcgi`</li>
    <li>Inline YouTube video urls will be replaced with an embedded player thanks to `Trestle::Plugin::YouTube`</li>
    <li>Images in the form `<img src="img" full="img-full" caption="Caption">` will be replaced by a captioned image thanks to `Trestle::Plugin::YouTube`</li>
</ul>
