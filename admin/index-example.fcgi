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
    gitusername => "johndoe",
    gitpassword => "test",
    key => "test346374725762572457F"
});

$admin->run();
