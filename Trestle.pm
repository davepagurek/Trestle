package Trestle {

    use CGI;
    use CGI::Fast;

    use Trestle::Page;
    use Trestle::Category;
    use Trestle::Theme;

    use strict;
    use warnings;
    use Moose;

    has "dev" => (
        is => "ro",
        isa => "Bool"
    );

    has "root" => (
        is => "ro",
        isa => "Str"
    );

    has "theme" => (
        is => "rw",
        isa => "Object"
    );

    has "plugins" => (
        is => "rw",
        isa => "ArrayRef"
    );

    has "cacheLife" => (
        is => "rw",
        isa => "Int"
    );

    has "query" => (
        is => "ro",
        isa => "CGI",
        init_arg => undef,
        writer => "_next_query"
    );

    sub run {
        my $self = shift;

        if ($self->dev) {
            require CGI::Carp;
            CGI::Carp->import(qw(warningsToBrowser fatalsToBrowser)) if CGI::Carp -> can ("import");
        }

        while (my $q = CGI::Fast->new) {

            $self->_next_query(CGI->new());

            for ($self->_pageName) {
                if    ($self->_showCache($_))   {  }
                elsif ($_ eq "index")           { $self->_showIndex; }
                elsif ($_ eq "archives")        { $self->_showArchives; }
                elsif ($self->_isPage($_))      { $self->_showPage($_) }
                elsif ($self->_isCategory($_))  { $self->_showCategory($_) }
                else                            { $self->_showError($_) }
            }

            if (-e "rebuild") {
                unlink "rebuild" or die "Unable to unlink rebuild: $!";
                last;
            }
        }
    }

    sub cache {
        my $self = shift;
        my $pageName = shift;
        my $content = shift;

        $content = "<!-- " . time . " -->\n" . $content;

        my $dir = "";
        $dir = $1 if $pageName =~ /^(.*)\/[\w-]/;

        my $cacheDir = "cache/" . $dir;
        if (!-d "cache") {
            mkdir "cache" or die "Unable to create cache: $1";
        }
        if (!-d $cacheDir) {
            mkdir $cacheDir or die "Unable to create $cacheDir: $!";
        }

        my $sourceCache = "cache/" . $pageName . "_cache.html";
        open my $cached, ">", $sourceCache or die "Can't open $sourceCache: $!";
        print $cached $content;
        close $cached or die "can't close $cached: $!";
    }

    sub _pageName {
        my $self = shift;
        my $pageName = $self->query->param("page") || "index";
        $pageName =~ s/\/+$//; #Remove trailing slashes
        return $pageName;
    }

    sub _isPage {
        my $self = shift;
        my $pageName = shift;
        my $source = "content/" . $pageName . ".html";

        return -e $source;
    }

    sub _isCategory {
        my $self = shift;
        my $pageName = shift;
        my $sourceDir = "content/" . $pageName;

        return $pageName ne "images" && -d $sourceDir
    }

    sub _showCache {
        my $self = shift;
        my $pageName = shift;
        my $sourceCache = "cache/" . $pageName . "_cache.html";

        return 0 unless -e $sourceCache;

        #Read the timestamp from the first line
        open my $cached, "<", $sourceCache or die "Can't open $sourceCache: $!";
        my $input = <$cached>;
        my $created = 0;
        if ($input =~ /<\!-- ([0-9]+) -->/) {
            $created = $1;
        }

        #Print the whole cached file if the cache's life hasn't expired
        close $cached && return 0 unless time-$created <= $self->cacheLife*60*60;

        print $self->query->header("text/html");
        while (<$cached>) {
            print $_;
        }
        close $cached && return 1 or die "can't close '$cached': $!";
    }

    sub _showIndex {
        my $self = shift;

        #Create index page
        my $page = Trestle::Page->new(
            source => "content/index.html",
            root => $self->root
        );

        #Get the theme's output for the index page
        my $content = $self->theme->main($page);

        #Run the output through plugins that can edit index pages
        for my $plugin (grep {$_->{index}} @{$self->plugins}) {
            $content = $plugin->content($content, $page);
        }

        $self->cache(index => $content);

        print $self->query->header("text/html");
        print $content;
    }

    sub _showArchives {
        my $self = shift;

        #Create a list of category directories
        my @categories = ();
        opendir(my $dh, "content") || die "can't opendir content: $!";
        my @dirs = grep {-d "content/$_" && ! /^\./ && $_ ne "images"} readdir($dh);

        #Create a category page for each
        for my $dir (@dirs) {
            push(@categories, Trestle::Category->new("content/" . $dir, $self->root));
        }

        #Get the theme's output for the archives page
        my $content = $self->theme->archives($self->root, @categories);

        #Run the output through plugins that can edit archives pages
        for my $plugin (grep {$_->{archives}} @{$self->plugins}) {
            $content = $plugin->content($content, @categories);
        }

        $self->cache(archives => $content);

        print $self->query->header("text/html");
        print $content;
    }

    sub _showPage {
        my $self = shift;
        my $pageName = shift;

        #Create page
        my $page = Trestle::Page->new(
            source => "content/" . $pageName . ".html",
            root => $self->root
        );

        #Get the theme's output for the page
        my $content = $self->theme->content($page);

        #Run the output through plugins that can edit pages
        for my $plugin (grep {$_->{pages}} @{$self->plugins}) {
            $content = $plugin->content($content, $page);
        }

        $self->cache($pageName => $content);
        print $self->query->header("text/html");
        print $content;
    }

    sub _showCategory {
        my $self = shift;
        my $pageName = shift;

        #Create category page
        my $category = Trestle::Category->new("content/$pageName", $self->root);

        #Get the theme's output for the category page
        my $content = $self->theme->dir($category);

        #Run the output through plugins that can edit category pages
        for my $plugin (grep {$_->{categories}} @{$self->plugins}) {
            $content = $plugin->content($content, $category);
        }

        $self->cache($pageName => $content);
        print $self->query->header("text/html");
        print $content;
    }

    sub _showError {
        my $self = shift;
        my $pageName = shift;

        #Get the theme's output for the error page
        my $content = $self->theme->error(404, $self->root);

        #Run the output through plugins that can edit 404 error pages
        for my $plugin (grep {$_->{error}} @{$self->plugins}) {
            $content = $plugin->content($content, 404);
        }

        print $self->query->header( -status => '404 Not Found' );
        print $content;
    }
}


1;
