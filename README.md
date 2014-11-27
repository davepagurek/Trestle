<h1>Trestle</h1>
A light, extensible Perl CMS by Dave Pagurek

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
