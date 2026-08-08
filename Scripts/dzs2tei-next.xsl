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

  <xsl:template mode="pass5" match="tei:form[@type != 'lemma']">
    <xsl:copy>
      <xsl:apply-templates mode="pass5" select="@*"/>
      <xsl:apply-templates mode="pass5"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="pass5" match="tei:form/text()">
    <xsl:call-template name="form">
      <xsl:with-param name="str" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="form">
    <xsl:param name="str"/>
    <xsl:variable name="pleft-re">[\[\(]</xsl:variable>
    <xsl:variable name="pright-re">[,;\]\)]</xsl:variable>
    <xsl:variable name="gloss-re">‚.+’</xsl:variable>
    <xsl:choose>
      <xsl:when test="$str = ''"/>
      <xsl:when test="et:tst-str($str, '\s+')">
        <xsl:value-of select="et:get-str($str, '\s+')"/>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, '\s+')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $pleft-re)">
        <pc join="right">
          <xsl:value-of select="et:get-str($str, $pleft-re)"/>
        </pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $pleft-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $pright-re)">
        <pc join="left">
          <xsl:value-of select="et:get-str($str, $pright-re)"/>
        </pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $pright-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $gloss-re)">
        <pc join="right">‚</pc>
        <gloss>
          <xsl:value-of select="replace(et:get-str($str, $gloss-re), '.(.+).', '$1')"/>
        </gloss>
        <pc join="left">’</pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str,  $gloss-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $langs-re)">
        <lang>
          <xsl:value-of select="et:get-str($str, $langs-re)"/>
        </lang>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $langs-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $pron-re)">
        <pron>
          <xsl:value-of select="et:get-str($str, $pron-re)"/>
        </pron>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $pron-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $lbl-re)">
        <lbl>
          <xsl:value-of select="et:get-str($str, $lbl-re)"/>
        </lbl>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $lbl-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $chem-re)">
        <term type="chemical_formula">
          <xsl:value-of select="et:get-str($str, $chem-re)"/>
        </term>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $chem-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $gram-re)">
        <gram>
          <xsl:value-of select="et:get-str($str, $gram-re)"/>
        </gram>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $gram-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $langs-re)">
        <lang>
          <xsl:value-of select="et:get-str($str, $langs-re)"/>
        </lang>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $langs-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $year-re)">
        <date>
          <xsl:value-of select="et:get-str($str, $year-re)"/>
        </date>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $year-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $name-re)">
        <name>
          <xsl:value-of select="et:get-str($str, $name-re)"/>
        </name>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $name-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $abbr-re)">
        <abbr>
          <xsl:value-of select="et:get-str($str, $abbr-re)"/>
        </abbr>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $abbr-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARN: Non-covered form {', $str, '}')"/>
        <orth type="unknown">
          <xsl:value-of select="$str"/>
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

  <xsl:function name="et:tst-str">
    <xsl:param name="str"/>
    <xsl:param name="re"/>
    <xsl:if test="matches($str, concat('^', $re))">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="et:get-str">
    <xsl:param name="str"/>
    <xsl:param name="re"/>
    <xsl:if test="matches($str, concat('^', $re))">
      <xsl:value-of select="normalize-space(
                            replace($str, concat('^(', $re, ').*'), '$1')
                            )"/>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="et:del-str">
    <xsl:param name="str"/>
    <xsl:param name="re"/>
    <xsl:if test="not(matches($str, concat('^', $re)))">
      <xsl:message select="concat('ERROR: Non-matching ', $str, ' on regex ', $re)"/>
    </xsl:if>
      <xsl:value-of select="replace($str, concat('^', $re), '')"/>
  </xsl:function>
  
</xsl:stylesheet>
