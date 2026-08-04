all:	schema
val-odd:
	$j tei_odds.rng tei_dzslex_schema.xml


PARAMS = --localsource=p5subset.xml tei_dzslex_schema.xml
schema:	val-odd
	Stylesheets/bin/oddtorng        ${PARAMS} ../schema/tei_dzslex.rng
	Stylesheets/bin/teitornc        ${PARAMS} ../schema/tei_dzslex.rnc

j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
