<?xml version="1.0" encoding="utf-8"?>
<!-- Output only specified element -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:param name="element"/>

  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <xsl:template match="*[name() = $element]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="text()"/>
</xsl:stylesheet>
