test-tei2txt:
	$s -xsl:Scripts/tei2txt.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.txt
test-teitext:
	$s -xsl:Scripts/tei2text.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.text.xml

### Targets for testing scripts on sample
test-next:
	$s -xsl:Scripts/dzs2tei-next.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.test.xml
	$j TEI/tei_dzslex.rng Sample/DZS-lex.sample.test.xml
	-diff Sample/DZS-lex.sample.xml Sample/DZS-lex.sample.test.xml
test-next-large:
	$s -xsl:Scripts/dzs2tei-next.xsl Lexicon/DZS-lex.xml > Lexicon/DZS-lex.test.xml
	$j TEI/tei_dzslex.rng Lexicon/DZS-lex.test.xml

test-small:
	$s -xsl:Scripts/test.xsl Sample/test.xml

#Dump text one word per line from original and TEI and comapre
#There are legit differences between the two (lemma in senses, punctuation glue)
test-compare:
	$s -xsl:Scripts/dumptext-dzs.xsl Sample/KNAUR.sample.xml > Sample/KNAUR.sample.txt
	$s -xsl:Scripts/dumptext-tei.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.txt
	wc Sample/KNAUR.sample.txt Sample/DZS-lex.sample.txt
	diff Sample/KNAUR.sample.txt Sample/DZS-lex.sample.txt

test-all:	test-dzs2tei test-val
test-val:
	$j TEI/tei_dzslex.rng Sample/DZS-lex.sample.xml

### Targets to run on complete source
all:	prep sample-dzs2tei dzs2tei val 
val:
	$s -xsl:Scripts/check-links.xsl Lexicon/DZS-lex.xml
	$j TEI/tei_dzslex.rng Lexicon/DZS-lex.xml
sample-dzs2tei:
	$s -xsl:Scripts/dzs2tei.xsl Sample/KNAUR.sample.xml > Sample/DZS-lex.sample.xml
	$j TEI/tei_dzslex.rng Sample/DZS-lex.sample.xml

dzs2tei:
	$s -xsl:Scripts/dzs2tei.xsl Lexicon/KNAUR.xml > Lexicon/DZS-lex.xml

### Preparation of the source lexicon
prep: dzs2xml sample
sample:
	$s ratio=1000 -xsl:Scripts/dzs2sample.xsl Lexicon/KNAUR.xml > Sample/KNAUR.sample.xml
	grep -c '<XX>' Lexicon/KNAUR.xml
	grep -c '<XX>' Sample/KNAUR.sample.xml
dzs2xml:
	iconv -f CP1250 -t UTF-8 < Lexicon/KNAUR.648 > Lexicon/KNAUR.txt
	Scripts/dzs2xml.pl Scripts/DZS-chars.tsv < Lexicon/KNAUR.txt > Lexicon/KNAUR.xml

### Support scripts for analysing the source
show-element:
	$s element=FOR -xsl:Scripts/show-element.xsl Lexicon/KNAUR.xml


############################################
j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 0
