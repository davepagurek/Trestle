#!C:/Perl/bin/perl.exe
use Image::Resize;
use GD;
use CGI;

use strict;

my ($file) = @ARGV;

my $quality = 100;
my $sizes = {
    "thumbnail" => {
        "width" => 220,
        "height" => 220,
        "crop" => 1
    },
    "medium" => {
        "width" => 800,
        "height" => 550,
        "crop" => 0
    },
    "large" => {
        "width" => 1200,
        "height" => 800,
        "crop" => 0
    }
};



if ($file && -e $file) {
    my $name = "img";
    my $mime = "jpg";
    if ($file =~ /(.*)\.([a-z]+)$/i) {
        $name = $1;
        $mime = $2;
    }
    my $image = Image::Resize->new($file);

    for my $size (keys $sizes) {
        if ($sizes->{$size}->{crop}) {
            my $img;

            if (lc($mime) eq "jpg") {
                $img = GD::Image->newFromJpeg($file);
            } elsif (lc($mime) eq "png") {
                $img = GD::Image->newFromPng($file);
            }

            my ($w,$h) = $img->getBounds(); # find dimensions

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
            my $newimg = new GD::Image($sizes->{$size}->{width}, $sizes->{$size}->{height});
            $newimg->copyResampled($img,0,0,$xcut,$ycut,$sizes->{$size}->{width}, $sizes->{$size}->{height},$cut,$cut);

            #open(FILE, "> $out") || die;
            #print FILE $newimg->jpeg;

            open(my $thumbFile, ">", "$name-$size.jpg");
            binmode $thumbFile;
            print $thumbFile $newimg->jpeg($quality);
            close $thumbFile;
            print "Wrote file $name-$size.jpg\n";
         } else {
            my $gd = $image->resize($sizes->{$size}->{width}, $sizes->{$size}->{height});
            open(my $thumbFile, ">", "$name-$size.jpg");
            binmode $thumbFile;
            print $thumbFile $gd->jpeg($quality);
            close($thumbFile);
            print "Wrote file $name-$size.jpg\n";
        }
    }
    print "Done.\n";
} else {
    print "File does not exist.";
}


