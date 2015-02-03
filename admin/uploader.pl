#!C:/Perl/bin/perl

use CGI::Session;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Digest::MD5 qw(md5);
use GD;
use strict;

my %credentials = do 'credentials.pl';

my %sizes = do 'sizes.pl';

my $root = do 'root.pl';


sub resize {
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

        for my $size (keys %sizes) {
            if ($w < $sizes{$size}->{width} && $h < $sizes{$size}->{height}) {
                next;
            }
            if ($sizes{$size}->{crop}) {
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
                my $newimg = new GD::Image($sizes{$size}->{width}, $sizes{$size}->{height}, 1);
                $newimg->copyResampled($img,0,0,$xcut,$ycut,$sizes{$size}->{width}, $sizes{$size}->{height},$cut,$cut);

                #open(FILE, "> $out") || die;
                #print FILE $newimg->jpeg;

                open(my $thumbFile, ">", "$imgDir/$name-$size.jpg");
                binmode $thumbFile;
                print $thumbFile $newimg->jpeg($sizes{$size}->{quality});
                close $thumbFile;
            } else {
                my $gd;
                if ($w>$h) {
                    $gd = new GD::Image($sizes{$size}->{width}, (($h/$w)*$sizes{$size}->{width}), 1);
                    $gd->copyResampled($img,0,0,0,0,$sizes{$size}->{width}, (($h/$w)*$sizes{$size}->{width}),$w,$h);
                } else {
                    $gd = new GD::Image(($w/$h)*$sizes{$size}->{height}, ($sizes{$size}->{height}), 1);
                    $gd->copyResampled($img,0,0,0,0,($w/$h)*$sizes{$size}->{height}, ($sizes{$size}->{height}),$w,$h);

                }

                #my $gd = $image->resize($sizes{$size}->{width}, $sizes{$size}->{height});
                open(my $thumbFile, ">", "$imgDir/$name-$size.jpg");
                binmode $thumbFile;
                print $thumbFile $gd->jpeg($sizes{$size}->{quality});
                close($thumbFile);
            }
        }
    } else {
        print "Can't find file $file\n";
    }
}

my $query = CGI->new();

my $loggedin = 0;

my $session = new CGI::Session("driver:File", $query, {Directory=>'/tmp'});

if ($session->param("logged_in") && $session->param("key") eq md5($credentials{password} . $credentials{key})) {

    print $query->header("text/html");

    #extend expiration
    $session->expire('+2h');

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

        resize("$imgDir/$basename", $imgDir);

        my $name = "img";
        my $mime = "jpg";
        if ($basename =~ /[\/\\]*([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
            $name = $1;
            $mime = $2;
        }

        $dir = "/$year/$mon";

    }

    print "<html>
        <head>
        <title>Trestle Media Uploader</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' type='text/css' href='style.css' />
        <script type='text/javascript' src='uploader.js'></script>
        </head>
        <body>
        <div class='uploader'>

            <form method='post' enctype='multipart/form-data'>
            <input type='file' name='file' />
            <input type='submit' value='Upload' />
            </form>

            <div class='files'>";

    if ($dir =~ /(.*)[\/\\].+/) {
        my $parent = $1;
        print "
            <div class='file'>
                <a href='?dir=$parent'>/..</a>
            </div>";
    }


    opendir(DIR, "../content/images/$dir") or die $!;

    my $printed = {};

    while (my $file = readdir(DIR)) {

        next if ($file =~ /^\./); #ignore hidden files

        if (-d "../content/images/$dir/$file") {
            print "<div class='file'>
                <a href='?dir=$dir/$file'>$dir/$file</a>
                </div>";
        } elsif ($file =~ /^([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
            my $name = $1;

            next if (!(-e "../content/images/$dir/$name-thumbnail.jpg")); #ignore resized images

            print "<div class='file'>
                <img src='../content/images$dir/$name-thumbnail.jpg' />
                <ul>
                    <li><input type='text' value='%root%/content/images$dir/$file' /></li>";

            for my $size (keys %sizes) {
                if (-e "../content/images$dir/$name-$size.jpg") {
                    print "
                        <li><input type='text' value='%root%/content/images$dir/$name-$size.jpg' /></li>";
                }
            }

            print "
                </ul>
                </div>";
        }

    }

    closedir(DIR);

        print "
            </div>

        </div>
        </body>
        </html>";



} else {
    print $query->redirect("$root/admin/index.pl");
}

