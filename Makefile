### Targets for testing scripts
##  Take existing lexicon and run test dzs2tei-next.xsl on it
test-next:
	$s -xsl:Scripts/dzs2tei-next.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.test.xml
	$j TEI/tei_dzslex.rng Sample/DZS-lex.sample.test.xml
	-diff Sample/DZS-lex.sample.xml Sample/DZS-lex.sample.test.xml
test-next-large:
	$s -xsl:Scripts/dzs2tei-next.xsl Lexicon/DZS-lex.xml > Lexicon/DZS-lex.test.xml
	$j TEI/tei_dzslex.rng Lexicon/DZS-lex.test.xml
test-classla:
	${venv}; ${python} < Sample/test.txt

test:
	$s -xsl:Scripts/test.xsl Sample/test.xml

#Dump text one word per line from original and TEI and comapre
#There are legit differences between the two (lemma in senses, punctuation glue)
test-compare:
	$s -xsl:Scripts/dumptext-dzs.xsl Sample/KNAUR.sample.xml > Sample/KNAUR.sample.txt
	$s -xsl:Scripts/dumptext-tei.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.txt
	wc Sample/KNAUR.sample.txt Sample/DZS-lex.sample.txt
	diff Sample/KNAUR.sample.txt Sample/DZS-lex.sample.txt


### Targets for producing the GitHub sample
sample-all:	sample-dzs2tei sample-tei2txt sample-ana sample-conll sample-2vert
sample-2vert:
	Scripts/conllu2vert.pl < Sample/DZS-lex.sample.id.conllu | Scripts/xml2vert.pl > Sample/DZS-lex.sample.vert
sample-conll:
	$s -xsl:Scripts/tei2txt-ids.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.ids
	Scripts/merge-conllu.pl Sample/DZS-lex.sample.ids < Sample/DZS-lex.sample.conllu > Sample/DZS-lex.sample.id.conllu
sample-ana:
	${venv}; ${python} Scripts/anno.py < Sample/DZS-lex.sample.txt > Sample/DZS-lex.sample.conllu
sample-tei2txt:
	$s -xsl:Scripts/tei2txt.xsl Sample/DZS-lex.sample.xml > Sample/DZS-lex.sample.txt
sample-dzs2tei:
	$s -xsl:Scripts/dzs2tei.xsl Sample/KNAUR.sample.xml > Sample/DZS-lex.sample.xml
	$j TEI/tei_dzslex.rng Sample/DZS-lex.sample.xml

### Targets to run on complete source
nohup:
	nohup time make all > nohup.all &
all:	prep sample-dzs2tei dzs2tei tei2txt ana conll 2vert
2vert:
	Scripts/conllu2vert.pl < Lexicon/DZS-lex.id.conllu | Scripts/xml2vert.pl | gzip > Lexicon/DZS-lex.vert.gz
conll:
	$s -xsl:Scripts/tei2txt-ids.xsl Lexicon/DZS-lex.xml > Lexicon/DZS-lex.ids
	Scripts/merge-conllu.pl Lexicon/DZS-lex.ids < Lexicon/DZS-lex.conllu > Lexicon/DZS-lex.id.conllu
ana:
	${python} Scripts/anno.py < Lexicon/DZS-lex.txt > Lexicon/DZS-lex.conllu
tei2txt:
	$s -xsl:Scripts/tei2txt.xsl Lexicon/DZS-lex.xml > Lexicon/DZS-lex.txt
dzs2tei:
	$s -xsl:Scripts/dzs2tei.xsl Lexicon/KNAUR.xml > Lexicon/DZS-lex.xml
	$j TEI/tei_dzslex.rng Lexicon/DZS-lex.xml
	$s -xsl:Scripts/check-links.xsl Lexicon/DZS-lex.xml

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
venv = . Scripts/classla/bin/activate
python = /usr/local/classla-venv/bin/python
