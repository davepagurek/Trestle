package Trestle::Admin;

use CGI::Session;
use CGI;
use CGI::Fast;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Digest::MD5 qw(md5);
use File::Find;
use File::Path qw(rmtree);
use HTML::Entities;
use HTML::Template;
use Encode;
use Git::Wrapper;
use Date::Simple qw(date today);
use strict;




sub new {
    my $self = {};
    my $class = shift;
    my $config = shift;
    $self->{config} = $config;


    bless $self, $class;
    return $self;
}


sub run {
    my $self = shift;

    while (my $query = CGI::Fast->new) {

        my $root = do 'root.pl';

        my $loggedIn = 0;
        my $templateDir = "templates";

        my @files = ();
        my $dirs = {};

        my $session = new CGI::Session("driver:File", $query, {Directory=>'/tmp'});
        my $message = "";

        if ($query->param("log_out")) {
            $session->clear(["logged_in"]);
        } elsif ($session->param("logged_in") && $session->param("key") eq md5($self->{config}->{password} . $self->{config}->{key})) {
            $loggedIn=1;
        } elsif ($query->param("username") eq $self->{config}->{username} && $query->param("password") eq $self->{config}->{password}) {
            $session->param("logged_in", "true");
            $session->param("key", md5($self->{config}->{password} . $self->{config}->{key}));
            my $cookie = $query->cookie(CGISESSID => $session->id);
            print $query->header(
                -type => "text.html",
                -cookie => $cookie
            );
            $loggedIn=1;
        } elsif ($query->param("username") || $query->param("password")) {
            $message = "Incorrect login.";
        }

        if ($loggedIn && $query->param("new")) {
            my $category = lc($query->param("category"));

            my $title = $query->param("new");

            my $slug = lc($title);
            $slug =~ s/[^\w ]+//g;
            $slug =~ s/\s+/-/g;

            my $date = today();

            my $source = "../content/$category/$slug.html";
            open my $content, ">", $source or die "Can't open $source: $!";
            print $content
            "<!--
            \"title\": \"$title\",
            \"category\": \"$category\",
            \"date\": \"$date\"
            -->
            ";
            close $content;

            print $query->redirect("$root/admin/?edit=$category/$slug.html");
        } else {
            print $query->header("text/html") unless $query->{".header_printed"};
        }

        if ($loggedIn) {

            #extend expiration
            $session->expire('+2h');

            if ($query->url_param("edit") && -e "../content/" . $query->url_param("edit")) {

                my $url = $query->url_param("edit");
                if ($url eq "index.html") {
                    $url = "";
                } else {
                    $url =~ s/(.+\/)?(.+)\.html/\/$1$2/;
                }

                my $source = "../content/" . $query->url_param("edit");
                if ($query->param("content")) {
                    open my $content, ">", $source or die "Can't open $source: $!";
                    my $decoded = $query->param("content");
                    $decoded =~ s/\r//g;
                    print $content $decoded;
                    close $content;
                    $message = "File saved successfully";
                }

                my $pageContent = "";
                open my $content, "<", $source or die "Can't open $source: $!";
                while (<$content>) {
                    $pageContent .= encode_entities($_);
                }
                close $content or die "can't close '$content': $!";

                my $template = HTML::Template->new(
                    filename => "$templateDir/editor.html",
                    die_on_bad_params =>  0
                );
                $template->param({
                        title => "Editor: " . $query->url_param("edit"),
                        loggedIn => $loggedIn,
                        editor => 1,
                        message => $message,
                        source => $pageContent,
                        root => $root,
                        url => $url
                    });
                print $template->output;


            } else {
                if ($query->param("clear_cache") && $query->param("clear_cache") eq "true") {
                    rmtree("../cache");
                    $message = "Cache cleared successfully.";
                }
                if ($query->param("restart_server") && $query->param("restart_server") eq "true") {
                    open (my $rebuild, ">", "../rebuild") or die "Could not open rebuild: $!";
                    print $rebuild "1";
                    close($rebuild);
                    $message = "Server set to restart on next request.";
                }
                if ($query->param("commit_changes") && $query->param("commit_changes") eq "true" && $query->param("commit_message")) {
                    my $git = Git::Wrapper->new('../content');
                    $git->add({ all => 1 });

                    chdir('../content');
                    qx(git config user.name "$self->{config}->{gitname}");
                    qx(git config user.email "$self->{config}->{gitemail}");
                    chdir('../admin');

                    $git->commit({
                            message => $query->param("commit_message"),
                            all => 1
                        });
                    $message = "Commit successful.";
                }
                if ($query->param("sync_changes") && $query->param("sync_changes") eq "true") {
                    my $git = Git::Wrapper->new('../content');
                    $git->pull();
                    #my @changes = $git->status->get("indexed");
                    #if (scalar @changes > 0) {
                    my $remote = ($git->config("remote.origin.url") )[0];
                    $remote =~ s/https:\/\//https:\/\/$self->{config}->{gitusername}:$self->{config}->{gitpassword}\@/;

                    chdir('../content');
                    my $out =  qx(git push $remote master 2>&1);
                    my $rc = $?;
                    chdir('../admin');

                    if ($rc == 0) {
                        $message = "Sync complete.";
                    } else {
                        $message = "Sync error: $out";
                    }
                }

                #Make file list
                my $files = [];
                find ({
                    "wanted" => sub {
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
                    },
                    "preprocess" => sub {
                        sort {  uc $a cmp uc $b } @_;
                    }
                }, "../content");

                for my $file (@files) {
                    push(@{ $files }, {
                            fileName => $file,
                        });
                }

                for my $dir (sort keys %$dirs) {
                    my $dirFiles = [];

                    for my $file (@{ $dirs->{$dir} }) {
                        push(@{ $dirFiles }, {
                                fileName => $file,
                                dirName => $dir
                            });
                    }

                    push(@{ $files }, {
                            dirName => $dir,
                            dirFiles => $dirFiles
                        })
                }
                my $template = HTML::Template->new(
                    filename => "$templateDir/dashboard.html",
                    die_on_bad_params =>  0
                );
                $template->param({
                        title => "Dashboard",
                        loggedIn => $loggedIn,
                        dashboard => 1,
                        message => $message,
                        files => $files
                    });
                print $template->output;

            }
        } else {
            #present login form
            my $template = HTML::Template->new(
                filename => "$templateDir/login.html",
                die_on_bad_params =>  0
            );
            $template->param({
                    title => "Login",
                    message => $message,
                });
            print $template->output;

        }

    }
}

1;
