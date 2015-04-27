#!/usr/bin/perl

use Trestle;
use Trestle::Theme::Default;
use Trestle::Plugin::CodePrettify;
use Trestle::Plugin::GoogleAnalytics;
use Trestle::Plugin::YouTube;
use Trestle::Plugin::DisqusComments;
use Trestle::Plugin::ImageCaption;

my $site = Trestle->new({
	dev => 1,
    root => "http://localhost/Trestle",
    theme => Trestle::Theme::Default->new("Trestle Blog"),
    plugins => [
        Trestle::Plugin::CodePrettify->new("tomorrow-night"),
        Trestle::Plugin::GoogleAnalytics->new("UA-8777691-3"),
        Trestle::Plugin::YouTube->new(),
        Trestle::Plugin::ImageCaption->new()
    ],
    cacheLife => 0
});

$site->run();
