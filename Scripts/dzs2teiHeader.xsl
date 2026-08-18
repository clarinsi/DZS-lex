<?xml version="1.0" encoding="utf-8"?>
<!-- Construct root with teiHeader for DZS lexicon -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:import href="dzs2tei-lib.xsl"/>
  
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="TEI teiHeader text body entry sense figure floatingText"/>
  <xsl:preserve-space elements="form def gloss hi head distinct p oRef orth note"/>
  
  <xsl:param name="stamp">DZS-lex</xsl:param>
  <xsl:param name="handle">http://hdl.handle.net/11356/2332</xsl:param>
  <xsl:param name="authors-file"/>
  <xsl:param name="front-file"/>
  <xsl:param name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <xsl:variable name="xml-model">
    <xsl:variable name="schema_url">../TEI/tei_dzslex.rng</xsl:variable>
    <!--xsl:variable name="schema_url">TEILex0.rng</xsl:variable-->
    <xsl:variable name="namespace">http://relaxng.org/ns/structure/1.0</xsl:variable>
    <xsl:text>&#10;</xsl:text>
    <xsl:processing-instruction name="xml-model">
      <xsl:value-of select="concat(
			    'href=&quot;', $schema_url,
			    '&quot; type=&quot;application/xml&quot; schematypens=&quot;',
			    $namespace,
			    '&quot;'
			    )"/>
    </xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="teiHeader">
    <teiHeader xml:lang="sl">
      <fileDesc>
        <titleStmt>
          <title xml:lang="sl">Veliki splošni leksikon DZS</title>
          <title xml:lang="sl">Large General Lexicon DZS</title>
          <respStmt/>
        </titleStmt>
        <editionStmt>
          <edition>Version 1.0</edition>
        </editionStmt>
        <extent/>
        <publicationStmt>
          <publisher>CLARIN.SI</publisher>
          <idno type="PID" subtype="handle"/>
          <availability>
            <p xml:lang="sl">Avtorske pravice za to izdajo ureja licenca
            <ref target="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
            Priznanje avtorstva-Deljenje pod enakimi pogoji 4.0 mednarodna licenca</ref>.</p>
            <p xml:lang="en">This work is licenced under the licence
            <ref target="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
            Attribution-ShareAlike 4.0 International</ref>.</p>
          </availability>
          <date/>
        </publicationStmt>
        <sourceDesc>
          <biblStruct>
            <monogr>
              <title>VELIKI splošni leksikon [Elektronski vir]</title>
              <idno type="ISBN">978-961-6474-90-0</idno>
              <idno type="COBISS.SI-ID">259150339</idno>
              <imprint>
                <publisher>Amebis, d.o.o.</publisher>
                <date>2025</date>
              </imprint>
            </monogr>
          </biblStruct>
        </sourceDesc>
      </fileDesc>
      <encodingDesc>
        <projectDesc>
	  <p xml:lang="sl">Pretvorba leksikona v TEI je bila narejena, da omogoči prenos berljive
	  različice leksikona z repozitorija CLARIN.SI zainteresiranim uporabniki ter, da omogoči
	  jezikoslovno označevanje leksikona in instalacijo na konkordančnike CLARIN.SI.</p>
        </projectDesc>
        <tagsDecl/>
    </encodingDesc>
      <profileDesc>
        <langUsage>
          <language ident="sl">slovenščina</language>
          <language ident="la">latinščina</language>
          <language ident="en">angleščina</language>
        </langUsage>
      </profileDesc>
      <revisionDesc xml:lang="en">
        <change when="2026-08-11"><name>Tomaž Erjavec</name> First draft.</change>
      </revisionDesc>
    </teiHeader>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:copy-of select="$xml-model"/>
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id" select="$id_prefix"/>
      <xsl:attribute name="xml:lang">sl</xsl:attribute>
      <xsl:apply-templates mode="header" select="$teiHeader">
        <xsl:with-param name="TEI" select="/"/>
      </xsl:apply-templates>
      <text xml:lang="sl" xml:id="{concat($id_prefix, '.text')}">
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{replace($front-file, '^.+/', '')}"/>
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{replace(base-uri(),  '^.+/', '')}"/>
      </text>
    </TEI>
  </xsl:template>

  <!-- PASS "header": INTO teiHeader INSERT CURRENT DATE, EXTENT AND TAGUSAGE -->

  <xsl:template mode="header" match="tei:idno[@subtype='handle']">
    <idno type="URI" subtype="handle">
      <xsl:value-of select="$handle"/>
    </idno>
  </xsl:template>
  
  <xsl:template mode="header" match="tei:titleStmt/tei:title">
    <xsl:copy>
      <xsl:apply-templates mode="header" select="@*"/>
      <xsl:value-of select="concat(., ' [', $stamp, ']')"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="header" match="tei:titleStmt/tei:respStmt">
    <xsl:copy-of select="document($authors-file)/tei:titleStmt/tei:respStmt"/>
  </xsl:template>
  
  <xsl:template mode="header" match="tei:publicationStmt/tei:date">
    <date when="{$today}">
      <xsl:value-of select="$today"/>
    </date>
  </xsl:template>
  
  <xsl:template mode="header" match="tei:extent">
    <xsl:param name="TEI"/>
    <xsl:variable name="entries" select="count($TEI//tei:entry)"/>
    <xsl:variable name="senses" select="$entries + count($TEI//tei:sense) "/>
    <xsl:copy>
      <measure unit="entries" quantity="{$entries}" xml:lang="sl">
        <xsl:value-of select="$entries"/>
        <xsl:text> vnosov</xsl:text>
      </measure>
      <measure unit="entries" quantity="{$entries}" xml:lang="sl">
        <xsl:value-of select="$senses"/>
        <xsl:text> pomenov</xsl:text>
      </measure>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="header" match="tei:tagsDecl">
    <xsl:param name="TEI"/>
    <tagsDecl>
      <namespace name="http://www.tei-c.org/ns/1.0">
	<xsl:apply-templates mode="tagCount" select="$TEI"/>
      </namespace>
    </tagsDecl>
  </xsl:template>
  <xsl:template mode="tagCount" match="tei:*">
    <xsl:variable name="self" select="name()"/>
    <xsl:if test="not(following::*[name()=$self] or descendant::*[name()=$self] )">
      <tagUsage gi="{$self}">
	<xsl:attribute name="occurs">
	  <xsl:number level="any" from="tei:group"/>
	</xsl:attribute>
      </tagUsage>
    </xsl:if>
    <xsl:apply-templates mode="tagCount"/>
  </xsl:template>
  <xsl:template mode="tagCount" match="text()"/>
  
  <xsl:template mode="header" match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates mode="header" select="@*"/>
      <change when="{$today}"><name>Tomaž Erjavec</name> Run conversion to TEI.</change>
      <xsl:apply-templates mode="header"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="header" match="tei:*">
    <xsl:param name="TEI"/>
    <xsl:copy>
      <xsl:apply-templates mode="header" select="@*"/>
      <xsl:apply-templates mode="header" select="tei:*|text()">
        <xsl:with-param name="TEI" select="$TEI"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="header" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="header" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
