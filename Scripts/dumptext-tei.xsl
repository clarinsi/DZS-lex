<?xml version="1.0" encoding="utf-8"?>
<!-- Dump text from original DZS lexicon -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//tei:entry"/>
  </xsl:template>

  <xsl:template match="tei:entry | tei:sense">
    <xsl:variable name="pc-text">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="text">
      <xsl:apply-templates mode="join" select="$pc-text"/>
    </xsl:variable>
    <xsl:for-each select="tokenize(normalize-space($text), ' ')">
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="join" match="tei:pc">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template mode="join" match="text()">
    <xsl:if test="not(preceding-sibling::tei:pc[1][@join = 'right'])">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="not(following-sibling::tei:pc[1][@join = 'left'])">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:*">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:pc[@join]">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="text()">
    <xsl:value-of select="translate(., '₀₁₂₃₄₅₆₇₈₉ ⁰¹²³⁴⁵⁶⁷⁸⁹ⁱⁿ⁺⁻⁼⁽⁾', '0123456789 0123456789in+–=()')"/>
  </xsl:template>

</xsl:stylesheet>
