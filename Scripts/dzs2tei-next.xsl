<?xml version="1.0" encoding="utf-8"?>
<!-- Conversion of DZS lexicon in XML to TEI Lex0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:import href="dzs2tei-lib.xsl"/>
  
  <xsl:output indent="yes"/>

  <!-- PASS 6: -->
  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:apply-templates mode="pass6" select="@*"/>
      <xsl:apply-templates mode="pass6"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="pass6" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="pass6" select="@*"/>
      <xsl:apply-templates mode="pass6" select="tei:*|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="pass6" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="pass6" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>


</xsl:stylesheet>
