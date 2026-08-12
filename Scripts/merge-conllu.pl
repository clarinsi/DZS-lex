#!/usr/bin/perl -w
use utf8;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

$id_file = shift;

open(TBL, '<:utf8', $id_file);
while (<TBL>) {
    chomp;
    s|&amp;|&|g;
    push(@struct, $_)
        unless  m|</text>|
}
close TBL;

while (<>) {
    if (m|^# newpar id|) {
        $mark = shift(@struct);
        if ($mark eq '<p/>') {}
        else {
            ($id, $type, $head) = $mark =~ m|<text xml:id="(.+?)" type="(.+?)" headword="(.+?)">|
                or die "Bad line $mark!\n";
            print "# newdoc id = $id\n";
            print "# type = $type\n";
            print "# headword = $head\n";
            shift(@struct);
        }
    }
    print
}
