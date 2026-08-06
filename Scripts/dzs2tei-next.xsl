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
    <xsl:copy>
      <xsl:apply-templates mode="pass5" select="@*"/>
      <xsl:choose>
        <xsl:when test="@type = '@lemma'">
          <xsl:copy-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="pass5"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="pass5" match="tei:form/text()">
    <xsl:call-template name="form">
      <xsl:with-param name="str" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="form">
    <xsl:param name="str"/>
    <xsl:choose>
      <xsl:when test="$str = ''"/>
      <xsl:when test="matches($str, '^\s')">
        <xsl:value-of select="replace($str, '^(\s+).*', '$1')"/>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, '^\s+', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^[\[\(]')">
        <pc join="right">
          <xsl:value-of select="replace($str, '^(.).*', '$1')"/>
        </pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, '^.', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^[,;\]\)]')">
        <pc join="left">
          <xsl:value-of select="replace($str, '^(.).*', '$1')"/>
        </pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, '^.', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^‚.+’')">
        <pc join="right">‚</pc>
        <gloss>
          <xsl:value-of select="replace($str, '^‚(.+?)’.*', '$1')"/>
        </gloss>
        <pc join="left">’</pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, '^‚(.+?)’', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $langs-re))">
        <lang>
          <xsl:value-of select="replace($str, concat('^(', $langs-re, ').*'), '$1')"/>
        </lang>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $langs-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $pron-re))">
        <pron>
          <xsl:value-of select="replace($str, concat('^(', $pron-re, ').*'), '$1')"/>
        </pron>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $pron-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $lbl-re))">
        <lbl>
          <xsl:value-of select="normalize-space(replace($str, concat('^(', $lbl-re, ').*'), '$1'))"/>
        </lbl>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $lbl-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $gram-re))">
        <gram>
          <xsl:value-of select="replace($str, concat('^(', $gram-re, ').*'), '$1')"/>
        </gram>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $gram-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $langs-re))">
        <lang>
          <xsl:value-of select="replace($str, concat('^(', $langs-re, ').*'), '$1')"/>
        </lang>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $langs-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $year-re))">
        <date>
          <xsl:value-of select="replace($str, concat('^(', $year-re, ').*'), '$1')"/>
        </date>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $year-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $name-re))">
        <name>
          <xsl:value-of select="replace($str, concat('^(', $name-re, ').*'), '$1')"/>
        </name>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $name-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, concat('^', $abbr-re))">
        <abbr>
          <xsl:value-of select="replace($str, concat('^(', $abbr-re, ').*'), '$1')"/>
        </abbr>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="replace($str, concat('^', $abbr-re), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARN: Non-covered form {', $str, '}')"/>
        <orth type="unknown">
          <xsl:value-of select="."/>
        </orth>
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
