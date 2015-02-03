#!C:/Perl/bin/perl
#!/usr/bin/perl
use CGI;
use Page;
use Category;
use strict;

my %config = do 'config.pl';

if ($config{dev}) {
    require CGI::Carp;
    CGI::Carp->import(qw(warningsToBrowser fatalsToBrowser)) if CGI::Carp -> can ("import");
}

my $query = CGI->new();
my $pageName = $query->param("page") || "index";
$pageName =~ s/\/+$//;
my $source = "content/" . $pageName . ".html";
my $sourceDir = "content/" . $pageName;
my $sourceCache = "cache/" . $pageName . "_cache.html";

#Check if cache exists
my $remake = 0;
if (-e $sourceCache) {

    #Read the timestamp from the first line
    open my $cached, "<", $sourceCache or die "Can't open $source: $!";
    my $input = <$cached>;
    my $created = 0;
    if ($input =~ /<\!-- ([0-9]+) -->/) {
        $created = $1;
    }

    #Print the whole cached file if the cache's life hasn't expired
    if (time-$created <= $config{cacheLife}*60*60) {
        print $query->header("text/html");
        while (<$cached>) {
            print $_;
        }

        #Otherwise mark the post to be re-cached
    } else {
        $remake = 1;
    }
    close $cached or die "can't close '$cached': $!";
} else {
    $remake = 1;
}

if ($remake) {

    #make cache subdirectory if it doesn't exist
    my $dir = "";
    $dir = $1 if $pageName =~ /^(.*)\/[\w-]/;


    my $content = "";
    my $cache = 0;

    if ($pageName eq "index") {
        print $query->header("text/html");
        $cache = 1;

        #Create index page
        my $page = Page->new($source, $config{root});

        #Get the theme's output for the index page
        $content .= $config{theme}->main($page);

        #Run the output through plugins that can edit index pages
        for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
            if ($config{plugins}[$i]->{index}) {
                $content = $config{plugins}[$i]->content($content, $page);
            }
        }

    } elsif ($pageName eq "archives") {
        print $query->header("text/html");
        $cache = 1;

        #Create a list of category directories
        my @categories = ();
        opendir(my $dh, "content") || die "can't opendir content: $!";
        my @dirs = grep {-d "content/$_" && ! /^\./} readdir($dh);

        #Create a category page for each
        for my $dir (@dirs) {
            if ($dir ne "images") {
                push(@categories, Category->new("content/" . $dir, $config{root}));
            }
        }

        #Get the theme's output for the archives page
        $content .= $config{theme}->archives($config{root}, @categories);

        #Run the output through plugins that can edit archives pages
        for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
            if ($config{plugins}[$i]->{archives}) {
                $content = $config{plugins}[$i]->content($content, @categories);
            }
        }

        #If the source file exists, display the page
    } elsif (-e $source) {
        print $query->header("text/html");
        $cache = 1;

        #Create page
        my $page = Page->new($source, $config{root});

        #Get the theme's output for the page
        $content .= $config{theme}->content($page);

        #Run the output through plugins that can edit index pages
        for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
            if ($config{plugins}[$i]->{pages}) {
                $content = $config{plugins}[$i]->content($content, $page);
            }
        }

        #If the directory exists, display it as a category (excluding the images directory)
    } elsif ($pageName ne "images" && -d $sourceDir) {
        print $query->header("text/html");
        $cache = 1;

        #Create category page
        my $category = Category->new($sourceDir, $config{root});

        #Get the theme's output for the category page
        $content .= $config{theme}->dir($category);

        #Run the output through plugins that can edit index pages
        for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
            if ($config{plugins}[$i]->{categories}) {
                $content = $config{plugins}[$i]->content($content, $category);
            }
        }

        #Otherwise, it's an error
    } else {
        print $query->header( -status => '404 Not Found' );

        #Get the theme's output for the error page
        $content .= $config{theme}->error(404, $config{root});

        #Run the output through plugins that can edit 404 error pages
        for (my $i=0; $i<scalar @{$config{plugins}}; $i++) {
            if ($config{plugins}[$i]->{error}) {
                $content = $config{plugins}[$i]->content($content, 404);
            }
        }
    }

    #Print the page
    print $content;

    #Add a timestamp and save the cached version
    $content = "<!-- " . time . " -->\n" . $content;

    if ($cache) {
        my $cacheDir = "cache/" . $dir;
        if (!-d "cache") {
            mkdir "cache" or die "Unable to create cache: $1";
        }
        if (!-d $cacheDir) {
            mkdir $cacheDir or die "Unable to create $cacheDir: $!";
        }
        open my $cached, ">", $sourceCache or die "Can't open $sourceCache: $!";
        print $cached $content;
        close $cached or die "can't close '$cached': $!";
    }
}
