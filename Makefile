yyy:
	$s -xsl:Scripts/dzs2tei.xsl Lexicon/KNAUR.xml > Lexicon/DZS-lex.body.xml

### Targets for testing scripts
test:
	$s -xsl:Scripts/test.xsl Sample/test.xml

##  Take existing lexicon and run test dzs2tei-next.xsl on it
test-next:
	$s -xsl:Scripts/dzs2tei-next.xsl Sample/DZS-lex-sample.xml > Sample/DZS-lex-sample.test.xml
	$j TEI/tei_dzslex.rng Sample/DZS-lex-sample.test.xml
	-diff Sample/DZS-lex-sample.xml Sample/DZS-lex-sample.test.xml
test-next-large:
	$s -xsl:Scripts/dzs2tei-next.xsl Lexicon/DZS-lex.xml > Lexicon/DZS-lex.test.xml
	$j TEI/tei_dzslex.rng Lexicon/DZS-lex.test.xml
test-classla:
	${venv}; ${python} < Sample/test.txt


#Dump text one word per line from original and TEI and comapre
#There are legit differences between the two (lemma in senses, punctuation glue)
test-compare:
	$s -xsl:Scripts/dumptext-dzs.xsl Sample/KNAUR-sample.xml > Sample/KNAUR-sample.txt
	$s -xsl:Scripts/dumptext-tei.xsl Sample/DZS-lex-sample.xml > Sample/DZS-lex-sample.txt
	wc Sample/KNAUR-sample.txt Sample/DZS-lex-sample.txt
	diff Sample/KNAUR-sample.txt Sample/DZS-lex-sample.txt

### Targets for producing the GitHub sample
sample-all:	sample-dzs2tei sample-tei2txt sample-ana sample-conll sample-2vert
sample-2vert:
	Scripts/conllu2vert.pl < Sample/DZS-lex-sample.conllu | Scripts/xml2vert.pl > Sample/DZS-lex-sample.vert
sample-conll:
	$s -xsl:Scripts/tei2txt-ids.xsl Sample/DZS-lex-sample.body.xml > Sample/DZS-lex-sample.meta.tmp
	Scripts/merge-conllu.pl Sample/DZS-lex-sample.meta.tmp < Sample/DZS-lex-sample.bare.conllu > Sample/DZS-lex-sample.conllu
	rm Sample/DZS-lex-sample.bare.conllu Sample/DZS-lex-sample.meta.tmp
sample-ana:
	${venv}; ${python} Scripts/anno.py < Sample/DZS-lex-sample.txt > Sample/DZS-lex-sample.bare.conllu
	rm Sample/DZS-lex-sample.txt
sample-tei2txt:
	$s -xsl:Scripts/tei2txt.xsl Sample/DZS-lex-sample.body.xml > Sample/DZS-lex-sample.txt
sample-dzs2tei:
	$s -xsl:Scripts/dzs2tei.xsl Sample/KNAUR-sample.xml > Sample/DZS-lex-sample.body.xml
	$s stamp="DZS-lex sample" authors-file=../Docs/DZS-lex.authors.xml front-file=../Docs/DZS-lex.front.xml \
	-xsl:Scripts/dzs2teiHeader.xsl Sample/DZS-lex-sample.body.xml > Sample/DZS-lex-sample.xml
	cp Docs/DZS-lex.front.xml Sample/
	$s -xi -xsl:Scripts/ident.xsl Sample/DZS-lex-sample.xml > Sample/DZS-lex-sample.tei.xml
	$j TEI/tei_dzslex.rng Sample/DZS-lex-sample.tei.xml

### Targets to run on complete source
nohup:
	nohup time make all > nohup.all &
all:	prep sample-dzs2tei dzs2tei tei2txt ana conll 2vert cqp pack
pack:
	rm -fr Lexicon/Packed/*
	mkdir Lexicon/Packed/DZS-lex.orig
	cp Docs/README.orig.txt Lexicon/Packed/DZS-lex.orig/00README.txt
	cp Lexicon/DZS-lex.front.pdf Lexicon/Packed/DZS-lex.orig/
	cp Lexicon/KNAUR.648 Lexicon/Packed/DZS-lex.orig/
	cp Lexicon/KNAUR.xml Lexicon/Packed/DZS-lex.orig/
	cp Docs/DZS-lex.chars.tsv Lexicon/Packed/DZS-lex.orig/
	cd Lexicon/Packed/; zip -r DZS-lex.orig.zip DZS-lex.orig
	mkdir Lexicon/Packed/DZS-lex.TEI
	cp Docs/README.tei.txt Lexicon/Packed/DZS-lex.TEI/00README.txt
	cp Lexicon/DZS-lex.xml Lexicon/Packed/DZS-lex.TEI/
	cp Lexicon/DZS-lex.front.xml Lexicon/Packed/DZS-lex.TEI/
	cp Lexicon/DZS-lex.body.xml Lexicon/Packed/DZS-lex.TEI/
	cp -r Lexicon/Formulas Lexicon/Packed/DZS-lex.TEI/Formulas
	cd Lexicon/Packed/; zip -r DZS-lex.TEI.zip DZS-lex.TEI
	mkdir Lexicon/Packed/DZS-lex.ana
	cp Docs/README.ana.txt Lexicon/Packed/DZS-lex.ana/00README.txt
	cp Lexicon/DZS-lex.conllu Lexicon/Packed/DZS-lex.ana/
	cp Lexicon/DZS-lex.vert.gz Lexicon/Packed/DZS-lex.ana/
	gunzip Lexicon/Packed/DZS-lex.ana/DZS-lex.vert.gz
	cp /project/clarinsi-cqp/registry/dzslex Lexicon/Packed/DZS-lex.ana/dzslex.regi
	cd Lexicon/Packed/; zip -r DZS-lex.ana.zip DZS-lex.ana
cqp:
	cd /project/clarinsi-cqp; make ske-beta CORPUS=dzslex
2vert:
	Scripts/conllu2vert.pl < Lexicon/DZS-lex.ids.conllu | Scripts/xml2vert.pl | gzip > Lexicon/DZS-lex.vert.gz
conll:
	$s -xsl:Scripts/tei2txt-ids.xsl Lexicon/DZS-lex.body.xml > Lexicon/DZS-lex.meta.tmp
	Scripts/merge-conllu.pl Lexicon/DZS-lex.meta.tmp < Lexicon/DZS-lex.bare.conllu > Lexicon/DZS-lex.conllu
	rm Lexicon/DZS-lex.bare.conllu Lexicon/DZS-lex.meta.tmp
ana:
	${python} Scripts/anno.py < Lexicon/DZS-lex.txt > Lexicon/DZS-lex.bare.conllu
	rm Lexicon/DZS-lex.txt
tei2txt:
	$s -xsl:Scripts/tei2txt.xsl Lexicon/DZS-lex.body.xml > Lexicon/DZS-lex.txt
dzs2tei:
	$s -xsl:Scripts/dzs2tei.xsl Lexicon/KNAUR.xml > Lexicon/DZS-lex.body.xml
	$s stamp="DZS-lex" authors-file=../Docs/DZS-lex.authors.xml front-file=../Docs/DZS-lex.front.xml \
	-xsl:Scripts/dzs2teiHeader.xsl Lexicon/DZS-lex.body.xml > Lexicon/DZS-lex.xml
	cp Docs/DZS-lex.front.xml Lexicon/
	$s -xi -xsl:Scripts/ident.xsl Lexicon/DZS-lex.xml > Lexicon/DZS-lex.tei.xml
	$j TEI/tei_dzslex.rng Lexicon/DZS-lex.tei.xml
	$s -xsl:Scripts/check-links.xsl Lexicon/DZS-lex.tei.xml

### Preparation of the source lexicon
prep: dzs2xml sample
sample:
	$s ratio=1000 -xsl:Scripts/dzs2sample.xsl Lexicon/KNAUR.xml > Sample/KNAUR-sample.xml
	grep -c '<XX>' Lexicon/KNAUR.xml
	grep -c '<XX>' Sample/KNAUR-sample.xml
dzs2xml:
	iconv -f CP1250 -t UTF-8 < Lexicon/KNAUR.648 > Lexicon/KNAUR.txt
	Scripts/dzs2xml.pl Docs/DZS-lex.chars.tsv < Lexicon/KNAUR.txt > Lexicon/KNAUR.xml

### Support scripts for analysing the source
show-element:
	$s element=KR -xsl:Scripts/show-element.xsl Lexicon/KNAUR.xml | sort | uniq -c


############################################
j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 0
#venv = . Scripts/classla/bin/activate
venv = . /usr/local/classla-venv/bin/activate
python = /usr/local/classla-venv/bin/python
