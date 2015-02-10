package Trestle::Page;

use CGI;
use JSON;
use strict;

#Convert a yyy-mm-dd date string to a hashref with date components
sub timeFormat {
    my ($timeStr) = @_;
    my $time = {};
    my $months = {
        1 => "January",
        2 => "February",
        3 => "March",
        4 => "April",
        5 => "May",
        6 => "June",
        7 => "July",
        8 => "August",
        9 => "September",
        10 => "October",
        11 => "November",
        12 => "December"
    };
    if ($timeStr =~ /([0-9]+)-([0-9]+)-([0-9]+)/) {
        $time->{full} = 0 + $1*10000 + $2*100 + $3;
        $time->{year} = 0 + $1;
        $time->{month} = $2;
        $time->{fullmonth} = $months->{ 0 + $2};
        $time->{mday} = $3;
    }
    return $time;
}

sub new {
    my $self = { };

    my $class = shift;
    my $source = shift;
    my $root = shift;
    my $onlyMeta = shift;

    #Get the proper url of the source file on the server
    my $url = $source;
    $url =~ s/^content\/(.*).html$/$root\/$1/;

    #Set public properties
    $self->{source} = $source;
    $self->{url} = $url;
    $self->{root} = $root;

    my $cgi = CGI->new();
    my $json = JSON->new->allow_nonref;

    if (-e $source) {
        open my $page, "<", $source or die "Can't open $source: $!";
        my $meta = 0;
        my $metaSource = "";
        my $content = "";
        my $isCode = 0;

        #Read the source file
        while (<$page>) {
            chomp;
            my $line = $_;

            #We're reading line by line, so if we encounter a newline it is a problem and should be removed
            $line =~ s/\n//g;

            #If we're not reading a code snippet, remove proceeding whitespace
            if (!$isCode) {
                $line =~ s/^\s+|\s+$//g;
            }

            #If we encounter the beginning of the meta information HTML comment, go to meta mode
            if (!$isCode && $line =~ /<!--$/) {
                $meta = 1;
                next;
            }

            #ignore blank lines if not code
            if (!$line && !$isCode) {
                next;

                #If we're in meta mode
            } elsif ($meta) {

                #If we encounter the end of the meta comment block
                if ($line =~ /^-->/) {
                    $meta = 0;

                    #Create a hashref out of the meta JSON info
                    my $metaJSON = $json->decode($metaSource);
                    foreach my $key (keys %$metaJSON) {
                        $self->{$key} = $metaJSON->{$key};
                    }
                    if ($self->{date}) {
                        $self->{date} = timeFormat($self->{date});
                    }

                    #If we are on a category page and don't need the actual post content, stop reading the rest
                    if ($onlyMeta) {
                        last;
                    }

                    #Keep building up the meta string if we aren't at the end yet
                } else {

                    #Replace %root% with the actual server root
                    $line =~ s/\%root\%/$root/g;

                    #Add the line
                    $metaSource .= $line . "\n";
                }
            } else {

                #If it's in a code tag, don't format innards
                if ($line =~ /(.*<(?:code|pre).*?>)(.*)(<\/(?:code|pre).*)/) {
                    my $start = $1;
                    my $end = $3;
                    $start =~ s/\%root\%/$root/g;
                    $end =~ s/\%root\%/$root/g;
                    $content .= $start . $cgi->escapeHTML($2) . $end . "\n";
                } elsif ($line =~ /(.*<(?:code|pre).*?>)(.*)/) {
                    $isCode = 1;
                    my $start = $1;
                    $start =~ s/\%root\%/$root/g;
                    $content .= $start;
                    if ($2) {
                        $content .= $cgi->escapeHTML($2) . "\n";
                    }
                } elsif ($isCode) {
                    if ($line =~ /(.*)(<\/(?:code|pre).*)/) {
                        $isCode = 0;
                        my $end = $2;
                        $end =~ s/\%root\%/$root/g;
                        $content .= $cgi->escapeHTML($1) . $end . "\n";
                    } else {
                        $content .= $cgi->escapeHTML($line) . "\n";
                    }

                #If paragraphing is off or it's in a heading or p tag, don't wrap in a p tag
                } elsif (($self->{paragraph} && $self->{paragraph} eq "false") || $line =~ /(?:^<(?:h(?:[0-9]+)|ul|li|table|th|tr|td|p).*>)|(?:<\/(?:h(?:[0-9]+)|ul|li|table|th|tr|td|p)>$)/i) {
                    $line =~ s/\%root\%/$root/g;
                    $content .= $line . "\n";

                } elsif ($line =~ /(.*`)(.*)(`.*)/) {
                    $line =~ s/(.*?`)(.*?)(`.*?)/$1 . $cgi->escapeHTML($2) . $3/eig;
                    $content .= "<p>$line</p>\n";

                #otherwise, wrap in a p tag
                } else {
                    $line =~ s/\%root\%/$root/g;
                    $content .= "<p>" . $line . "</p>\n";
                }
            }
        }
        close $page or die "can't read close '$page': $!";
        if (!$onlyMeta) {
            $self->{content} = $content;
        }
    }

    # use Data::Dumper;
    # print Dumper $self;

    bless $self, $class;
    return $self;
}

sub content {
    my ($self) = @_;
    return $self->{content};
}

sub meta {
    my ($self, $value) = @_;
    if (exists $self->{$value}) {
        return $self->{$value};
    } else {
        return undef;
    }
}

sub template {
    my ($self, $value) = @_;
    if (exists $self->{$value}) {
        if (ref($self->{$value}) eq "HASH") {
            return [ $self->{$value} ];
        } else {
            return $self->{$value};
        }

    } else {
        return undef;
    }
}



1;
