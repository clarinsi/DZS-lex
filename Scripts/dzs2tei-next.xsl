<?xml version="1.0" encoding="utf-8"?>
<!-- Conversion of DZS lexicon in XML to TEI Lex0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <!-- Double problem:
            <form n="FOR">
               <pc join="right">(</pc>
               <lbl>kratica za</lbl>
               <form n="ES1">
                  <orth>E</orth>
                  <hi rend="italic" n="I">uzkadi</hi>
                  <orth>T</orth>
                  <hi rend="italic" n="I">a</hi>
                  <orth>A</orth>
                  <hi rend="italic" n="I">zkatasuna</hi>
                  <orth type="undenfined">‚Baskija</orth>
               </form>
               <orth type="undenfined">’)</orth>
            </form>
            <pc join="left">,</pc>
  -->

  <xsl:import href="dzs2tei-lib.xsl"/>
  
  <xsl:output indent="yes"/>

  <!-- PASS 5: structure form -->
  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:apply-templates mode="pass5" select="@*"/>
      <xsl:apply-templates mode="pass5"/>
    </xsl:copy>
  </xsl:template>

  <!-- Give type to some forms -->
  <xsl:template mode="pass5" match="tei:form[not(@type)]">
    <xsl:variable name="form">
      <xsl:apply-templates mode="pass5"/>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="$form/tei:*[1][self::tei:pc = '(']">variant</xsl:when>
        <xsl:when test="$form/tei:lang">etymology</xsl:when>
        <xsl:when test="$form/tei:pron">pronunciation</xsl:when>
        <xsl:when test="$form/tei:name">name</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates mode="pass5" select="@*"/>
      <xsl:if test="$type != ''">
        <xsl:attribute name="type" select="$type"/>
      </xsl:if>
      <xsl:copy-of select="$form"/>
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
    <xsl:variable name="pright-re">[.,;\]\)]</xsl:variable>
    <xsl:variable name="punct-re">[–·]</xsl:variable>
    <xsl:variable name="gloss-re">‚.+’</xsl:variable>
    <xsl:choose>
      <xsl:when test="$str = ''"/>
      <!-- Only one upper letter maybe with spaces, for cases such as " T" in
           <form n="ES1">E<hi rend="italic" n="I">uzkadi</hi> T<hi rend="italic" n="I">a</hi>
      -->
      <xsl:when test="et:tst-str($str, '^\s*\p{Lu}\s*$')">
        <xsl:value-of select="et:get-str($str, '\s*\p{Lu}\s*')"/>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, '\s*\p{Lu}\s*')"/>
        </xsl:call-template>
      </xsl:when>
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
      <xsl:when test="et:tst-str($str, $punct-re)">
        <pc>
          <xsl:value-of select="et:get-str($str, $punct-re)"/>
        </pc>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $punct-re)"/>
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
      <xsl:when test="et:tst-str($str, $chemformula-re) and string-length(et:get-str($str, $chemformula-re)) &gt; 2">
        <term type="chemical_formula">
          <xsl:value-of select="et:get-str($str, $chemformula-re)"/>
        </term>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $chemformula-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="et:tst-str($str, $chemcompound-re)">
        <term type="chemical_compound">
          <xsl:value-of select="et:get-str($str, $chemcompound-re)"/>
        </term>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $chemcompound-re)"/>
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
      <xsl:when test="et:tst-str($str, concat($roman-re, '\s'))">
        <num type="roman">
          <xsl:value-of select="et:get-str($str, $roman-re)"/>
        </num>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $roman-re)"/>
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
      <!-- Ordinary words, for the complete string modulo end bracket, probably ok -->
      <xsl:when test="matches($str, concat('^', $orth-re, '[\)\]]*$'))">
        <orth>
          <xsl:value-of select="et:get-str($str, $orth-re)"/>
        </orth>
        <xsl:call-template name="form">
          <xsl:with-param name="str" select="et:del-str($str, $orth-re)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARNING: string left unprocessed: ', $str)"/>
        <!--orth type="error"-->
          <xsl:value-of select="$str"/>
        <!--/orth-->
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
      <xsl:value-of select="replace($str, concat('^(', $re, ').*'), '$1')"/>
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
