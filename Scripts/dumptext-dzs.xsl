<?xml version="1.0" encoding="utf-8"?>
<!-- Dump text from original DZS encyclopedia -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:output method="text"/>

  <xsl:variable name="left">[,.!?:;\)\]–]</xsl:variable>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//XX"/>
  </xsl:template>

  <xsl:template match="XX">
    <xsl:variable name="text">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="tokens" select="normalize-space($text)"/>
    <xsl:variable name="spacing" select="normalize-space(
                                         replace(
                                         replace($tokens,
                                         concat('&#32;+(', $left ,')'), '$1&#32;'),
                                         concat('&#32;+(', $left ,')'), '$1&#32;')
                                         )"/>
    <xsl:value-of select="replace($spacing, '&#32;', '&#10;')"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="N"/>
  <xsl:template match="KK"/>
  <xsl:template match="PON"/>
  <xsl:template match="W"/>
  <xsl:template match="QQ"/>
  <xsl:template match="GT"/>

  <xsl:template match="*">
    <xsl:apply-templates/>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
