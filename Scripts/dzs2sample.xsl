<?xml version="1.0" encoding="utf-8"?>
<!-- Sample source DZS lexicon -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et"
		version="2.0">

  <xsl:param name="ratio">100</xsl:param>

  <xsl:output indent="no" omit-xml-declaration="yes"/>

  <xsl:key name="entry" match="XX" use="substring-before(*/N, '+')"/>

  <xsl:template match="DZS">
    <xsl:comment>
      <xsl:text> This sample of the DZS lexicon contain cca 1/</xsl:text>
      <xsl:value-of select="$ratio"/>
      <xsl:text> of the complete lexicon </xsl:text>
    </xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:copy>
      <xsl:text>&#10;</xsl:text>
      <xsl:for-each select="XX">
        <xsl:if test="(position() mod $ratio) = 1">
          <xsl:variable name="id" select="substring-before(*/N, '+')"/>
          <xsl:copy-of select="key('entry', $id)"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:copy>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
