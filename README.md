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

<h2>Plugins</h2>
Here is the structure of an example plugin:
```perl
package Trestle::Plugin::Example;

sub new {
	my $class = shift;
	my $self = {};

	$self->{pages} = 1;
	$self->{categories} = 1;
	$self->{archives} = 1;
	$self->{index} = 1;
	$self->{error} = 1;

	bless $self, $class;
	return $self;
}

sub content {
	my ($self, $content, $page) = @_;

    $content =~ s/foo/bar/ig;

	return $content;
}

1;
```

Set `$self->{pagetype}` in `sub new` to register the plugin for that type of content.
In the `content` sub, you can do what you want with the `$content` variable and then return the new page content.

<h2>Themes</h2>
Here is the basic structure of a theme:
```perl
package Trestle::Theme::Example;

use strict;

use lib "../..";
use Trestle::Theme;

sub new {
    my $class = shift;
    my $self = {
        dir => "Trestle/Theme/Example",
        theme => Trestle::Theme->new()
    };

    bless $self, $class;
    return $self;
}

sub content {
    my ($self, $page) = @_;

    return $self->{theme}->render("$self->{dir}/template/content.tmpl", {
        themeDir => $self->{dir},
        title => $page->meta("title"),
        category => $page->meta("category"),
        content => $page->content
    });
}

sub dir {
    my ($self, $category) = @_;

    return $self->{theme}->render("$self->{dir}/template/dir.tmpl", {
        themeDir => $self->{dir},
        title => $category->info("name"),
        name => $category->info("name"),
        pages => $category->info("pages")
    });
}

sub archives {
    my ($self, $root, @cats) = @_;
    my $source = "";

    return $self->{theme}->render("$self->{dir}/template/archives.tmpl", {
        themeDir => $self->{dir},
        title => "Portfolio",
        categories => \@cats
    });

}

sub error {
    my ($self, $error, $root) = @_;

    return $self->{theme}->render("$self->{dir}/template/error.tmpl", {
        themeDir => $self->{dir},
        title => "Page Not Found",
        error => $error
    });
}

sub main {
    my ($self, $page) = @_;

    return $self->{theme}->render("$self->{dir}/template/content.tmpl", {
        themeDir => $self->{dir},
        title => $page->meta("title"),
        content => $page->content
    });
}

1;
```

A theme uses `HTML::Template`-style templates for pages, documentation for which can be found here: search.cpan.org/~samtregar/HTML-Template-2.6/Template.pm

Themes have subs for each of the types of pages that potentially need to be rendered.
