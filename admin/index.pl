#!C:/Perl/bin/perl.exe

use CGI::Session;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Digest::MD5 qw(md5);
use File::Find;
use strict;

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
    }

    $output .= "
    </head>
    <body>
        <div id='header'>
            <h1><a href='index.pl'>Trestle Admin</a></h1>
            <form method='post' id='logout'>
                <input type='hidden' name='log_out' id='log_out' value='true' />
                <input type='submit' value='Log Out' />
            </form>
        </div>";
    return $output;
}

sub footer {
    my $output = "</body>
    </html>";
    return $output;
}

my @files = ();
sub wanted {
    if ($File::Find::name =~ /content\/(.*\.html)$/) {
        push(@files, $1);
    }
}

my %credentials = do 'credentials.pl';
my $key = "7td694VoppH58sDOnaybIbFdHONlyF";


my $query = CGI->new();

my $loggedin = 0;

my $session = new CGI::Session("driver:File", $query, {Directory=>'/tmp'});

if ($query->param("log_out")) {
    $session->clear(["logged_in"]);
} elsif ($session->param("logged_in") && $session->param("key") eq md5($credentials{password} . $key)) {
    $loggedin=1;
} elsif ($query->param("username") eq $credentials{username} && $query->param("password") eq $credentials{password}) {
    $session->param("logged_in", "true");
    $session->param("key", md5($credentials{password} . $key));
    my $cookie = $query->cookie(CGISESSID => $session->id);
    print $query->header(
        -type => "text.html",
        -cookie => $cookie
    );
    $loggedin=1;
}

print $query->header("text/html") unless $query->{".header_printed"};

if ($loggedin) {

    #extend expiration
    $session->expire('+2h');

    if ($query->url_param("edit") && -e "../content/" . $query->url_param("edit")) {

        my $source = "../content/" . $query->url_param("edit");


        if ($query->param("content")) {
            open my $content, ">", $source or die "Can't open $source: $!";
            print $content $query->param("content");
            close $content;
        }

        print header("Editor");


        print "
        <div class='full'>
            <form id='editor' method='post'>
                <textarea id='content' name='content'>";

        open my $content, "<", $source or die "Can't open $source: $!";
        while (<$content>) {
            print $_;
        }
        close $content or die "can't close '$content': $!";


        print "</textarea>
                <input type='checkbox' id='spellcheck' name='spellcheck' checked> <label for='spellcheck'>Spellcheck</label>

                <input type='submit' value='save' />
            </form>
        </div>"


    } else {

        find \&wanted, "../content";

        print header("Dashboard");

        print "
        <div class='section'>
            <h2>Edit Page</h2>
            <ul>";

        for my $file (@files) {
            print "<li><a href='?edit=$file'>$file</a></li>";
        }

        print "
            </ul>
        </div>";

        print footer();
    }
} else {
    #present login format

    print header("Log In");
    print "
        <h1>Trestle Login</h1>

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


