#!/usr/bin/perl

use lib "../";
use Trestle::Admin;

use strict;

my $admin = Trestle::Admin->new({
    root => "http://localhost/Trestle",
    username => "test",
    password => "test",
    gitname => "John Doe",
    gitemail => "test\@test.com",
    gitprotocol => "HTTPS",
    gitusername => "johndoe",
    gitpassword => "test",
    key => "test346374725762572457F",
    sizes => {
        "thumbnail" => {
            "width" => 220,
            "height" => 220,
            "crop" => 1,
            "quality" => 90
        },
        "medium" => {
            "width" => 820,
            "height" => 550,
            "crop" => 0,
            "quality" => 98
        },
        "large" => {
            "width" => 1200,
            "height" => 800,
            "crop" => 0,
            "quality" => 98
        }
    }
});

$admin->run();
