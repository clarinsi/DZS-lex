#!/usr/bin/perl -w
use utf8;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

$char_file = shift;
open(TBL, '<:utf8', $char_file);
while (<TBL>) {
    ($dzs, $unicode) = /(.+?)\t(.+?)\t/;
    if ($dzs) {$uni{$dzs} = $unicode}
    else {$uni{''} = $unicode}
}
close TBL;

print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print "<DZS>\n";
while (<>) {
    #Remove 1 nested char specs
    s/\{\{/{/g;
    s/\}\}/}/g;
    #Tags cant start with numeral, rename
    s/<0LT>/<OLT>/g;
    s/<\/0LT>/<\/OLT>/g;
    # {vektor}: most common: {vektor}a but also {vektor}<I>c</I>, {vektor}OP, {vektor}ω
    
    # FIX ERRORS IN SOURCE

    #Typo
    s|starovisokononemško|starovisokonemško|g;
    
    # Bare text
    s|</KDE> (Kasneje preimenovana v <EN>UCTE</EN>.+?)<OPI>| </KDE><OPI>$1|;
    s|</KDE>(16.672.+strojna industrija.)|</KDE><OPI>$1</OPI>|;
    s|</KDE>(na Spitsbergih,.+<I>Kings Bay Kull</I>.)|</KDE><OPI>$1</OPI>|;
    s|</BORN>tudi <AIME>|</BORN><AIME>tudi |;
    
    # <RPOD> should be outside OPI (1 error)
    s|<OPI><RPOD>(.+?)</RPOD>|<RPOD>$1</RPOD><OPI>|g;
    # Missing OPI after KDE, but there is another KDE, hmm
    s|</KDE>(\w.+?)<OPI></OPI>|</KDE><OPI>$1</OPI>|g;
    # KDE starts too early
    s|<KDE>(<A>.+?</A><PODR>.+?</PODR>)|$1<KDE>|g;
    # OPI starts too late
    s|</KDE>(\w.+?)<OPI>|</KDE><OPI>$1|g;
    # I should be inside DOS, not outside
    s|<I><DOS>(.+?)</DOS></I>|<DOS><I>$1</I></DOS>|g;
    # I should be inside EN, not outside, difficult to identify in Perl:
    s|<I><EN>([^<]+)</EN> <EN>([^<]+)</EN></I>|<EN><I>$1</I></EN> <EN><I>$2</I></EN>|g;
    s|<I><EN>([^<]+<D>.</D>)</EN></I>|<EN><I>$1</I></EN>|g;
    s|<I><EN>([^<]+)</EN></I>|<EN><I>$1</I></EN>|g;
    # Remove OLT in YI, as otherwise oRef/date, which is not valid
    # also, doubled dates
    s|<OLT>1941</OLT>\{-}45</YI> <OLT>1941</OLT>\{-}45|1941{-}45</YI>|;

    @parts = split(/\{/);
    foreach $part (@parts) {
        if ($part =~ /}/) {
            ($code, $rest) = $part =~ /(.*)}(.*)/;
            $dzs = "{$code}";
            die "Cant find $dzs in mapping!\n"
                unless exists $uni{$dzs};
            print &render($dzs, $uni{$dzs});
            print &protect($rest)
        }
        else {
            print &protect($part)
        }
    }
}
print "</DZS>\n";

sub protect {
    my $str = shift;
    $str =~ s/&/&amp;/g;
    return $str
}

sub render {
    my $dzs = shift;
    my $codes = shift;
    my $out = '';
    if    ($codes eq '-')  {}               #Remove
    elsif ($codes eq '=')  {$out = $dzs}    #Leave original
    elsif ($codes =~ /^&/) {$out = $codes}  #Copy entity, e.g. "&lt;"
    else {
        foreach my $code (split(/,/, $codes)) {
            if    ($code =~ /^.$/) {$out .= $code} #Copy literal, e.g. "a"
            elsif (($hex) = $code =~ /^U\+(.+)/) {
                $out .= chr(hex($hex));
            }
            else {die "Bad code $code in $codes / $dzs\n"}
        }
    }
    return "$out"
}
