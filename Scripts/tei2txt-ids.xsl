<?xml version="1.0" encoding="utf-8"?>
<!-- Convert DZS-lex TEI to list of text IDs and paragraph marks to join with CoNLL-U -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//tei:entry"/>
  </xsl:template>

  <xsl:template match="tei:entry">
    <text xml:id="{@xml:id}" type="{@type}" headword="{tei:form[@type = 'lemma']/tei:orth}">
      <xsl:text>&#10;</xsl:text>
      <p/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="tei:sense"/>
    </text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:sense">
    <p/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>
</xsl:stylesheet>
