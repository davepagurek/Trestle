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
use GD;
use strict;




sub new {
    my $self = {};
    my $class = shift;
    my $config = shift;
    $self->{config} = $config;


    bless $self, $class;
    return $self;
}

sub resize {
    my $self = shift;
    my $file = shift;
    my $imgDir = shift;
    if ($file && -e $file) {
        my $name = "img";
        my $mime = "jpg";
        if ($file =~ /[\/\\]*([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
            $name = $1;
            $mime = $2;
        }

        #my $image = Image::Resize->new($file);
        my $img;

        if (lc($mime) eq "jpg" || lc($mime) eq "jpeg") {
            $img = GD::Image->newFromJpeg($file);
        } elsif (lc($mime) eq "png") {
            $img = GD::Image->newFromPng($file);
        }
        my ($w,$h) = $img->getBounds(); # find dimensions


        for my $size (keys $self->{config}->{sizes}) {
            if ($w < $self->{config}->{sizes}->{$size}->{width} && $h < $self->{config}->{sizes}->{$size}->{height}) {
                next;
            }
            if ($self->{config}->{sizes}->{$size}->{crop}) {
                my ($cut,$xcut,$ycut);
                if ($w>$h){
                    $cut=$h;
                    $xcut=(($w-$h)/2);
                    $ycut=0;
                } else {
                    $cut=$w;
                    $xcut=0;
                    $ycut=(($h-$w)/2);
                }
                my $newimg = new GD::Image($self->{config}->{sizes}->{$size}->{width}, $self->{config}->{sizes}->{$size}->{height}, 1);
                $newimg->copyResampled($img,0,0,$xcut,$ycut,$self->{config}->{sizes}->{$size}->{width}, $self->{config}->{sizes}->{$size}->{height},$cut,$cut);

                #open(FILE, "> $out") || die;
                #print FILE $newimg->jpeg;

                open(my $thumbFile, ">", "$imgDir/$name-$size.jpg");
                binmode $thumbFile;
                print $thumbFile $newimg->jpeg($self->{config}->{sizes}->{$size}->{quality});
                close $thumbFile;
            } else {
                my $gd;
                if ($w>$h) {
                    $gd = new GD::Image($self->{config}->{sizes}->{$size}->{width}, (($h/$w)*$self->{config}->{sizes}->{$size}->{width}), 1);
                    $gd->copyResampled($img,0,0,0,0,$self->{config}->{sizes}->{$size}->{width}, (($h/$w)*$self->{config}->{sizes}->{$size}->{width}),$w,$h);
                } else {
                    $gd = new GD::Image(($w/$h)*$self->{config}->{sizes}->{$size}->{height}, ($self->{config}->{sizes}->{$size}->{height}), 1);
                    $gd->copyResampled($img,0,0,0,0,($w/$h)*$self->{config}->{sizes}->{$size}->{height}, ($self->{config}->{sizes}->{$size}->{height}),$w,$h);

                }

                #my $gd = $image->resize($self->{config}->{sizes}->{$size}->{width}, $self->{config}->{sizes}->{$size}->{height});
                open(my $thumbFile, ">", "$imgDir/$name-$size.jpg");
                binmode $thumbFile;
                print $thumbFile $gd->jpeg($self->{config}->{sizes}->{$size}->{quality});
                close($thumbFile);
            }
        }
    } else {
        print "Can't find file $file\n";
    }
}


sub run {
    my $self = shift;

    while (my $query = CGI::Fast->new) {

        my $root = $self->{config}->{root};

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
{
\t\"title\": \"$title\",
\t\"category\": \"$category\",
\t\"date\": \"$date\"
}
-->";
            close $content;

            print $query->redirect("$root/admin/?edit=$category/$slug.html");
        } else {
            print $query->header("text/html") unless $query->{".header_printed"};
        }

        if ($loggedIn) {

            #extend expiration
            $session->expire('+2h');

            if ($query->url_param("uploader")) {

                my $dir = "";
                if ($query->url_param("dir") && -e "../content/images/" . $query->url_param("dir") && !($query->url_param("dir") =~ /^[\/\\]*\./)) {
                    $dir = $query->url_param("dir");
                }

                my $file = $query->param('file');
                my $filehandle = $query->upload("file");
                if ($file && $filehandle) {
                    my $basename = $file;
                    $basename =~ s/.*[\/\\](.*)/$1/;

                    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
                    $year = $year+1900;
                    $mon += 1;

                    my $imgDir = "../content/images/$year/$mon";
                    if (!-d "../content/images/$year") {
                        mkdir "../content/images/$year" or die "Unable to create ../content/images/$year: $!";
                    }
                    if (!-d $imgDir) {
                        mkdir $imgDir or die "Unable to create $imgDir: $!";
                    }

                    binmode($filehandle);
                    open (my $OUTFILE,'>',"$imgDir/$basename");
                    binmode($OUTFILE);
                    while ( my $nBytes = read($filehandle, my $buffer, 1024) ) {
                        print $OUTFILE $buffer;
                    }
                    close($OUTFILE);

                    $self->resize("$imgDir/$basename", $imgDir);

                    my $name = "img";
                    my $mime = "jpg";
                    if ($basename =~ /[\/\\]*([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
                        $name = $1;
                        $mime = $2;
                    }

                    $dir = "/$year/$mon";

                }

                my $parent = "";
                my $hasParent = 0;
                if ($dir =~ /(.*)[\/\\].+?$/) {
                    $parent = $1;
                    $hasParent = 1;
                }

                opendir(DIR, "../content/images/$dir") or die $!;

                my $dirs = [];
                my $files = [];


                while (my $file = readdir(DIR)) {
                    next if ($file =~ /^\./); #ignore hidden files

                    if (-d "../content/images/$dir/$file") {
                        push(@{ $dirs }, {
                            dir => $dir,
                            file => $file
                        });
                    } elsif ($file =~ /^([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
                        my $name = $1;

                        next if (!(-e "../content/images/$dir/$name-thumbnail.jpg")); #ignore resized images

                        my @sizes = keys $self->{config}->{sizes};
                        for my $size (keys $self->{config}->{sizes}) {
                            unless (-e "../content/images$dir/$name-$size.jpg") {
                                @sizes = grep { ! /^$size\b/ } @sizes;
                            }
                        }
                        @sizes = map {
                            {
                                size => $_
                            }
                        } @sizes;

                        push(@{ $files }, {
                            name => $name,
                            dir => $dir,
                            file => $file,
                            sizes => \@sizes
                        });
                    }

                }

                closedir(DIR);

                my $template = HTML::Template->new(
                    filename => "$templateDir/uploader.html",
                    die_on_bad_params =>  0,
                    global_vars => 1
                );
                $template->param({
                    parent => $parent,
                    hasParent => $hasParent,
                    dirs => $dirs,
                    files => $files
                });
                print $template->output;

            } elsif ($query->url_param("edit") && -e "../content/" . $query->url_param("edit")) {

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
                if ($query->param("restart_admin") && $query->param("restart_admin") eq "true") {
                    open (my $rebuild, ">", "rebuild") or die "Could not open rebuild: $!";
                    print $rebuild "1";
                    close($rebuild);
                    $message = "Reload the dashboard to restart Trestle Admin.";
                }
                if ($query->param("commit_changes") && $query->param("commit_changes") eq "true" && $query->param("commit_message")) {
                    my $commitMessage = $query->param("commit_message");

                    chdir('../content');
                    qx(git config user.name "$self->{config}->{gitname}");
                    qx(git config user.email "$self->{config}->{gitemail}");
                    qx(git add --all);
                    qx(git commit -am "$commitMessage");
                    chdir('../admin');

                    $message = "Commit successful.";
                }
                if ($query->param("sync_changes") && $query->param("sync_changes") eq "true") {

                    chdir('../content');
                    qx(git pull);
                    if ($self->{config}->{gitprotocol} eq "SSH") {
                        my $remote = qx(git config --get remote.origin.url);
                        unless ($remote =~ /$self->{config}->{gitpassword}/) {
                            $remote =~ s/https:\/\//https:\/\/$self->{config}->{gitusername}:$self->{config}->{gitpassword}\@/;
                            qx(git remote set-url origin $remote);
                        }
                    }

                    qx(git push origin master);
                    #while (qx(git status) =~ /ahead of/) {
                        #print qx(git push $remote master --porcelain);
                    #}

                    $message = qx(git status);

                    chdir('../admin');
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
        if (-e "rebuild") {
            unlink "rebuild" or die "Unable to unlink rebuild: $!";
            last;
        }

    }
}

1;
