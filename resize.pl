#!C:/Perl/bin/perl.exe
use Image::Resize;

use strict;

my ($file) = @ARGV;

my $sizes = {
    "thumbnail" => {
        "width" => 220,
        "height" => 220
    },
    "large" => {
        "width" => 800,
        "height" => 550
    }
};

if ($file && -e $file) {
    my $name = "img";
    if ($file =~ /(.*)\.[a-z]+$/i) {
        $name = $1;
    }
    my $image = Image::Resize->new($file);

    for my $size (keys $sizes) {
        my $gd = $image->resize($sizes->{$size}->{width}, $sizes->{$size}->{height});
        open(my $thumbFile, ">", "$name-$size.jpg");
        binmode $thumbFile;
        print $thumbFile $gd->jpeg();
        close($thumbFile);
        print "Wrote file $name-$size.jpg\n";
    }
    print "Done.\n";
} else {
    print "File does not exist.";
}


