<?xml version="1.0" encoding="utf-8"?>
<!-- Convert TEI to plain text
    new line is for each entry start and top-level sense -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:output method="text"/>
  <xsl:strip-space elements="TEI teiHeader text body entry sense figure floatingText"/>
  <xsl:preserve-space elements="form def gloss hi head distinct p oRef orth note"/>

  <xsl:template match="/">
    <corpus>
      <xsl:apply-templates select="//tei:entry"/>
    </corpus>
  </xsl:template>

  <xsl:template match="tei:entry">
    <xsl:variable name="incipit">
      <xsl:apply-templates select="tei:*[name() != 'sense']"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($incipit)"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="tei:sense"/>
  </xsl:template>
  
  <xsl:template match="tei:sense">
    <xsl:variable name="sense">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($sense)"/>
    <xsl:if test="not(ancestor::tei:sense)">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:note"/>
  
  <xsl:template match="text()">
    <xsl:if test="normalize-space(.) or ../text()[normalize-space(.)][2]">
      <xsl:if test="not(
                    parent::tei:pc[@join = 'left' or @join = 'both'] or
                    preceding::tei:*[1][@join = 'right' or @join = 'both'] or
                    matches(., '^[,;:.!’\]\)]') or
                    matches(preceding::text()[normalize-space(.)][1], '[‚\(\[]$')
                    )">
        <xsl:text>&#32;</xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="not(../text()[normalize-space(.)][2])">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(
                    parent::tei:pc[@join = 'right' or @join = 'both'] or
                    following::tei:*[1][@join = 'left' or @join = 'both'] or
                    matches(., '[‚\(\[]$') or
                    matches(following::text()[normalize-space(.)][1], '^[,;:.!’\]\)]')
                    )">
        <xsl:text>&#32;</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:*">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
