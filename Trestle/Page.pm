package Trestle::Page {

    use CGI;
    use JSON;

    use strict;
    use warnings;
    use Moose;

    has "_meta" => (
        is => "ro",
        isa => "HashRef",
        init_arg => undef,
        writer => "_setMeta"
    );

    has "source" => (
        is => "ro",
        isa => "Str",
        required => 1
    );

    has "url" => (
        is => "ro",
        isa => "Str",
        init_arg => undef,
        writer => "_setURL"
    );

    has "root" => (
        is => "ro",
        isa => "Str",
        required => 1
    );

    has "onlyMeta" => (
        is => "ro",
        isa => "Bool",
        default => 0
    );

    has "content" => (
        is => "ro",
        isa => "Str",
        init_arg => undef,
        default => "",
        writer => "_setContent"
    );

    sub _pushContent {
        my ($self, @newContent) = @_;
        my $line = "";
        for my $content (@newContent) {
            $line .= $content;
        }
        $self->_setContent($self->content . $line);
    }

    sub _asCode {
        my ($self, $line) = @_;
        return CGI::escapeHTML($line);
    }

    sub _asText {
        my ($self, $line) = @_;
        #Remove extra whitespace
        $line =~ s/
            ^\s+    #Whitespace at the beginning of a line
            |
            \s+$    #Whitespace at the end of a line
        //xg;

        return "" if $line eq "";

        #Convert %root%
        $line =~ s/\%root\%/$self->root/eg;

        #If paragraphing is disabled or the line is already in a tag
        if (($self->meta("paragraph") && $self->meta("paragraph") eq "false") || $line =~ /
            (?:
                ^<(?:h(?:[0-9]+)|ul|li|table|th|tr|td|p).*> #Tag at beginning of line
            )
            |
            (?:
                <\/(?:h(?:[0-9]+)|ul|li|table|th|tr|td|p)>$ #Closing tag at end of line
            )
        /ix) {
            return $line;

        #Handle inline code snippets
        } elsif ($line =~ /(.*`)(.*)(`.*)/) {

            #Replace all occurrences with their escaped versions
            $line =~ s/(.*?`)(.*?)(`.*?)/$1 . $self->_asCode($2) . $3/eig;
            return "<p>$line</p>";

        #otherwise, wrap in a p tag
        } else {
            return "<p>$line</p>";
        }
    }

    sub _parseMeta {
        my ($self, $page) = @_;
        my $metaSource = "";

        while (my $line = <$page>) {
            chomp $line;
            #Ignore beginning comment tag
            next if $line =~ /<!--$/;
            last if $line =~ /^-->/;

            #Replace %root% with the actual server root
            $line =~ s/\%root\%/$self->root/eg;

            #Add the line
            $metaSource .= $line . "\n";
        }

        #Create a hashref out of the meta JSON info
        my $metaJSON = decode_json($metaSource);
        if ($metaJSON->{date}) {
            $metaJSON->{date} = $self->_timeFormat($metaJSON->{date});
        }
        $self->_setMeta($metaJSON);
    }

    sub _parseBody {
        my ($self, $page) = @_;
        while (my $line = <$page>) {
            chomp $line;

            #We're reading line by line, so if we encounter a newline it is a problem and should be removed
            $line =~ s/\n//g;

            next if $line eq "";

            #If it's in a code tag, don't format innards
            if (my ($start, $openTag, $code, $closeTag, $end) = $line =~ /
                (.*)                    #Normal text
                (<(?:code|pre).*?>)     #Code tag
                (.*)                    #Code snippet
                (<\/(?:code|pre)>)      #Closing code tag
                (.*)                    #Normal text
            /x) {
                $self->_pushContent(
                    $self->_asText($start),
                    $openTag,
                    $self->_asCode($code),
                    $closeTag,
                    $self->_asText($end),
                    "\n"
                );

            } elsif (($start, $openTag, $code) = $line =~ /
                (.*)                #Normal text
                (<(?:code|pre).*?>) #Code tag
                (.*)                #Code
            /x) {
                $self->_pushContent(
                    $self->_asText($start),
                    $openTag,
                    $self->_asCode($code),
                    $self->_asCode($code) ? "\n" : ""
                );

                #Keep parsing until the end of the code block is found
                CODE: while (my $codeLine = <$page>) {
                    chomp $codeLine;

                    #We're reading line by line, so if we encounter a newline it is a problem and should be removed
                    $codeLine =~ s/\n//g;

                    next if $codeLine eq "";

                    if (($code, $closeTag, $end) = $codeLine =~ /
                        (.*)                #Code
                        (<\/(?:code|pre)>)  #Closing code tag
                        (.*)                #Normal text
                    /x) {
                        $self->_pushContent(
                            $self->_asCode($code),
                            $closeTag,
                            $self->_asText($end),
                            "\n"
                        );
                        last CODE;
                    } else {
                        $self->_pushContent($self->_asCode($codeLine), "\n");
                    }
                }
            } else {
                $self->_pushContent($self->_asText($line), "\n");
            }
        }
    }

    sub BUILD {
        my $self = shift;

        die "Source does not exist: $self->source" unless -e $self->source;

        #Get the proper url of the source file on the server
        my ($pageName) = $self->source =~ /^content\/(.*)\.html$/;
        $self->_setURL($self->root . "/" . $pageName);

        my $cgi = CGI->new();
        my $json = JSON->new->allow_nonref;

        open my $page, "<", $self->source or die "Can't open $self->source: $!";

        $self->_parseMeta($page);
        $self->_parseBody($page) unless $self->onlyMeta;

        close $page or die "can't read close '$page': $!";
    }

    #Convert a yyy-mm-dd date string to a hashref with date components
    sub _timeFormat {
        my ($self, $timeStr) = @_;
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

    sub meta {
        my ($self, $value) = @_;
        if (exists $self->_meta->{$value}) {
            return $self->_meta->{$value};
        } else {
            return undef;
        }
    }

    sub template {
        my ($self, $value) = @_;
        if (exists $self->_meta->{$value}) {
            if (ref($self->_meta->{$value}) eq "HASH") {
                return [ $self->_meta->{$value} ];
            } else {
                return $self->_meta->{$value};
            }
        } else {
            return undef;
        }
    }
}


1;
