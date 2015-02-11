#!/usr/bin/perl

use CGI::Session;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Digest::MD5 qw(md5);
use File::Find;
use File::Path qw(rmtree);
use HTML::Entities;
use Encode;
use strict;


my $loggedin = 0;

sub header {
    my ($title) = @_;
    my $output = "<!DOCTYPE html>
    <html>
    <head>
        <title>Admin - " . $title . "</title>
        <link rel='stylesheet' type='text/css' href='style.css' />
        <link href='http://fonts.googleapis.com/css?family=Open+Sans:400italic,400,300,700' rel='stylesheet' type='text/css'>";

    if (lc($title) eq "editor") {
        $output .= "<script type='text/javascript' src='editor.js'></script>";
    } elsif (lc($title) eq "dashboard") {
        $output .= "<script type='text/javascript' src='dashboard.js'></script>";
    }

    $output .= "
    </head>
    <body>
        <div id='header'>
            <h1><a href='index.pl'>Trestle Admin</a></h1>";

    if ($loggedin) {
        $output .="
            <form method='post' id='logout'>
                <input type='hidden' name='log_out' id='log_out' value='true' />
                <input type='submit' value='Log Out' />
            </form>";
    }
    $output .= "</div><div class='container'>";
    return $output;
}

sub footer {
    my $output = "</div></body>
    </html>";
    return $output;
}

my @files = ();
my $dirs = {};
sub wanted {
    if ($File::Find::name =~ /content\/(.*\/)?(.+\.html)$/i) {
        if (length($1) == 0) {
            push(@files, $2);
        } else {
            my $dir = substr($1, 0, -1);
            if (!$dirs->{$dir}) {
                $dirs->{$dir} = ();
            }
            push(@{ $dirs->{$dir} }, $2);
        }
    }
}
sub preprocess {
    sort {  uc $a cmp uc $b } @_;
}

my %credentials = do 'credentials.pl';

my $query = CGI->new();


my $session = new CGI::Session("driver:File", $query, {Directory=>'/tmp'});
my $message = "";

if ($query->param("log_out")) {
    $session->clear(["logged_in"]);
} elsif ($session->param("logged_in") && $session->param("key") eq md5($credentials{password} . $credentials{key})) {
    $loggedin=1;
} elsif ($query->param("username") eq $credentials{username} && $query->param("password") eq $credentials{password}) {
    $session->param("logged_in", "true");
    $session->param("key", md5($credentials{password} . $credentials{key}));
    my $cookie = $query->cookie(CGISESSID => $session->id);
    print $query->header(
        -type => "text.html",
        -cookie => $cookie
    );
    $loggedin=1;
} elsif ($query->param("username") || $query->param("password")) {
    $message = "Incorrect login.";
}

print $query->header("text/html") unless $query->{".header_printed"};

if ($loggedin) {

    #extend expiration
    $session->expire('+2h');

    if ($query->url_param("edit") && -e "../content/" . $query->url_param("edit")) {

        my $source = "../content/" . $query->url_param("edit");


        if ($query->param("content")) {
            open my $content, ">", $source or die "Can't open $source: $!";
            my $decoded = $query->param("content");
            $decoded =~ s/\r//g;
            print $content $decoded;
            close $content;
        }

        print header("Editor");


        print "
        <div class='full'>
            <form id='editor' method='post'>
                <textarea id='content' name='content'>";

        open my $content, "<", $source or die "Can't open $source: $!";
        while (<$content>) {
            print encode_entities($_);
        }
        close $content or die "can't close '$content': $!";


        print "</textarea>
                <input type='checkbox' id='spellcheck' name='spellcheck' checked> <label for='spellcheck'>Spellcheck</label>

                <input type='submit' value='save' />
            </form>
            <iframe id='media' frameborder='0' src='uploader.pl'></iframe>
        </div>"


    } else {

        find ({
            "wanted" => \&wanted,
            "preprocess" => \&preprocess
        }, "../content");

        print header("Dashboard");

        print "
        <div class='section'><div class='wrapper'>
            <h2>Edit Page</h2>
            <ul class='dirlist'>";

        for my $file (@files) {
            print "<li><a href='?edit=$file'>$file</a></li>";
        }

        for my $dir (sort keys %$dirs) {
            print "<li class='dir closed'><span>$dir</span><ul>";

            for my $file (@{ $dirs->{$dir} }) {
                print "<li><a href='?edit=$dir/$file'>$file</a></li>";
            }

            print "</ul></li>"
        }

        print "
            </ul>
        </div></div>
        <div class='section'><div class='wrapper'>
            <h2>Management</h2>
            <form method='post' id='clearCache'>
                <input type='hidden' name='clear_cache' id='clear_cache' value='true' />
                <input type='submit' value='Clear Cache' />
            </form>
            <form method='post' id='restartServer'>
                <input type='hidden' name='restart_server' id='restart_server' value='true' />
                <input type='submit' value='Restart Trestle' />
            </form>
        ";
        if ($query->param("clear_cache") && $query->param("clear_cache") eq "true") {
            rmtree("../cache");
            print "<p class='message'>Cache cleared successfully.</p>"
        }
        if ($query->param("restart_server") && $query->param("restart_server") eq "true") {
            open (my $rebuild, ">", "../rebuild") or die "Could not open rebuild: $!";
            print $rebuild "1";
            close($rebuild);
            print "<p class='message'>Server restarted successfully.</p>"
        }
        print "</div></div>";

        print footer();
    }
} else {
    #present login format

    print header("Log In");
    print "
        <h1>Trestle Login</h1>";

    if ($message) {
        print "<p class='message'>$message</p>";
    }

    print "
        <form method='post' id='login'>
            <div class='line'>
                <label for='username'>Username</label>
                <input type='text' name='username' id='username' />
            </div>
            <div class='line'>
                <label for='password'>Password</label>
                <input type='password' name='password' id='password' />
            </div>

            <input type='submit' value='Log In' />
        </form>";

    print footer();
}


