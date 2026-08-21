<?xml version="1.0" encoding="utf-8"?>
<!-- Reduce the DZS encyclopedia in TEI by removing all admin inf and @n
     and change no-break space to ordinary one 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et"
		version="2.0">

  <xsl:output indent="yes" omit-xml-declaration="yes"/>
  <xsl:strip-space elements="TEI teiHeader text body entry sense figure floatingText"/>
  <xsl:preserve-space elements="form def gloss hi head distinct p oRef orth note"/>


  <xsl:template match="tei:note[@type = 'admin']"/>
  <xsl:template match="@n"/>
  <xsl:template match="text()">
    <xsl:value-of select="translate(., '&#xA0;', '&#32;')"/>
  </xsl:template>
  
  <xsl:template match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="pass2" select="@*"/>
      <xsl:apply-templates mode="pass2" select="tei:*|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
