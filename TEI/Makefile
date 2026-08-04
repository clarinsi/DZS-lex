# Make RNG and RNC from ODD
schema:	val
	Stylesheets/bin/oddtorng ${PARAMS} ../TEI/tei_dzslex.rng
	Stylesheets/bin/teitornc ${PARAMS} ../TEI/tei_dzslex.rnc

# Is the ODD valid?
val:
	$j tei_odds.rng tei_dzslex.odd.xml

PARAMS = --localsource=p5subset.xml tei_dzslex.odd.xml

j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
