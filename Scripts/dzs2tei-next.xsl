<?xml version="1.0" encoding="utf-8"?>
<!-- Conversion of DZS lexicon in XML to TEI Lex0 -->
<!-- Stage 3: fix spaces and end punctuation -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:import href="dzs2tei-lib.xsl"/>
  
  <xsl:output indent="yes"/>

  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:apply-templates mode="pass5" select="@*"/>
      <xsl:apply-templates mode="pass5"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="pass5" match="tei:form">
    <xsl:choose>
      <xsl:when test="$str = ''"/>
      <xsl:when test="matches($str, $space-re)">
        <xsl:value-of select="replace($str, concat($space-re, '.*'), '$1')"/>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $space-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, $left-re)">
        <pc join="left">
          <xsl:value-of select="replace($str, concat($left-re, '.*'), '$1')"/>
        </pc>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $left-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, $right-re)">
        <pc join="right">
          <xsl:value-of select="replace($str, concat($right-re, '.*'), '$1')"/>
        </pc>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $right-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^‚.+’')">
        <gloss>
          <pc join="right">‚</pc>
          <xsl:value-of select="replace($str, '^‚(.+?)’.*', '$1')"/>
          <pc join="left">’</pc>
        </gloss>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, '^‚.+?’', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, $lbl-re)">
        <lbl>
          <xsl:value-of select="replace($str, concat($lbl-re, '.*'), '$1')"/>
        </lbl>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $lbl-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, $gram-re)">
        <gram>
          <xsl:value-of select="replace($str, concat($gram-re, '.*'), '$1')"/>
        </gram>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $gram-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, $langs-re)">
        <lang>
          <xsl:value-of select="replace($str, concat($langs-re, '.*'), '$1')"/>
        </lang>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $langs-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, $pron-re)">
        <pron>
          <xsl:value-of select="replace($str, concat($pron-re, '.*'), '$1')"/>
        </pron>
        <xsl:call-template name="FOR">
          <xsl:with-param name="str" select="replace($str, $pron-re, '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARN: Strange FOR ', $str)"/>
        <XXX>
          <xsl:value-of select="$str"/>
        </XXX>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template mode="pass5" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template mode="pass5" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="pass5" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="pass5" select="@*"/>
      <xsl:apply-templates mode="pass5" select="tei:*|text()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
