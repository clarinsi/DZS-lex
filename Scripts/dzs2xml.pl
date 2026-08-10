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

    # Typos
    s|starovisokononemško|starovisokonemško|g;
    s|sanskt,|sanskrt,|g;
    # Dates

    s|l9|19|g;
    
    s|26\.6 \(8\.7\.\)|26.6. (8.7.)|;
    s| \(24\.\)\. | (24.) |;
    s|12\.3 \(24\.3\)|12.3. (24.3.);|;
    s|23\.101698|23.10.1698|;
    s|31\.1933|31.8.1933|;
    s|\(8\.10\.\)1846|(8.10.) 1846|;
    s|\(12\.4\.\)1823|(12.4.) 1823|;
    s|\(26\.11\.\)1894|(26.11.) 1894|;

    s|16\.11\.42|16.11.1942|;
    s|24\.10\.51|24.10.1951|;
    s|25\.1\.98|25.1.1998|;
    s|19\.9\.86|19.9.1986|;
    s|28\.4\.32|28.4.1932|;
    s|16\.4\.69|16.4.1969|;
    s|30\.12\.39|30.12.1939|;
    s|13\.9\.81|13.9.1981|;
    s|24\.6\.79|24.6.1979|;
    s|20\.12\.69|20.12.1969|;
    s|15\.3\.44|15.3.1944|;
    s|18\.9\.96|18.9.1996|;
    s|15\.12\.37|15.12.1937|;
    s|28\.9\.48|28.9.1948|;
    s|18\.9\.53|18.9.1953|;
    
    s|\(31\.3\)|(31.3.)|;
    s|\(23\.7\)|(23.7.)|;
    s|\(10\.12\)|(10.12.)|;
    s|\(8\.10\)|(8.10.)|;
    s|13\.4([^.])|13.4.$1|;
    s|24\.11\.62|24.11.1962|;
    s|20\.6([^.])|20.6.$1|;
    s|25\.7([^.])|25.7.$1|;
    s|16\.12([^.])|16.12.$1|;

    #Ha, wrong (illegal) dates
    s|31\.2\.1980|21.2.1980|;              #Alfred Andersch
    s|15.44.1972|15.4.1972|;               #Otto Brenner
    s|13\.29\.1924|13.9.1924|;
    s|30\.30\.1914|30.10.1914|;            #Ernst Stadler
    s|31\.98\.1991|30.8.1991|;             #Jean Tinguely
    s|29\.2\.1900|13.3.1900 (29.2.1900)|;  #Jean Negulesco, Seferis Giorgos: old style calendar
        
    s|ok\.1606|ok\. 1606|;
    s|Malang \(Java;|Malang (Java);|;
    s|fr, ‚brez hlač do kolen’|francosko, ‚brez hlač do kolen’|;
    
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
