#!C:/Perl/bin/perl.exe

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
            if ($sizes{$size}->{crop}) {
                my ($cut,$xcut,$ycut);
                if ($w>$h){
                    $cut=$h;
                    $xcut=(($w-$h)/2);
                    $ycut=0;
                }
                if ($w<$h){
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

    my $file = $query->param('file');
    my $filehandle = $query->upload("file");
    if ($file && $filehandle) {
        my $basename = $file;
        $basename =~ s/.*[\/\\](.*)/$1/;

        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
        $year = $year+1900;
        $mon += 1;

        my $imgDir = "../content/images/$year/$mon";
        if (!-d $imgDir) {
            mkdir $imgDir or die "Unable to create $imgDir";
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

        print "<img src='$imgDir/$name-thumbnail.jpg' />";

    }
    my $dir = "";
    if ($query->url_param("dir") && -e "../content/images/" . $query->url_param("dir") && !($query->url_param("dir") =~ /^[\/\\]*\./)) {
        $dir = $query->url_param("dir");
    }




    print "<html>
        <head>
        <title>Trestle Media Uploader</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' type='text/css' href='style.css' />
        </head>
        <body>

            <form method='post' enctype='multipart/form-data'>
            <input type='file' name='file' />
            <input type='submit' value='Upload' />
            </form>

            <div class='files'>";

        opendir(DIR, "../content/images/$dir") or die $!;

        my $printed = {};

        while (my $file = readdir(DIR)) {

            next if ($file =~ /^\./); #ignore hidden files

            print "<div class='file'>";
            if (-d "../content/images/$dir/$file") {
                print "<a href='?dir=$dir/$file'>$dir/$file</a>";
            } elsif ($file =~ /^([a-zA-Z0-9-_ ]*)\.([a-z]+)$/i) {
                my $name = $1;

                next if (!(-e "../content/images/$dir/$name-thumbnail.jpg")); #ignore resized images

                print "<img src='../content/images/$dir/$name-thumbnail.jpg' />
                    <ul>
                        <li>$root/content/images/$dir/$file</li>";

                for my $size (keys %sizes) {
                    print "
                        <li>$root/content/images/$dir/$name-$size.jpg</li>";
                }

                print "
                    </ul>";
            }

            print "</div>";

        }

    closedir(DIR);

        print "
            </div>

        </body>
        </html>";



} else {
    print $query->redirect( -uri=>'index.pl', -nph=>1 );
}

