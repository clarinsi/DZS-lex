<?xml version="1.0" encoding="utf-8"?>
<!-- Variables for conversion -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		exclude-result-prefixes="tei"
		version="2.0">

  <!-- Punctuation that appears at end of element content and should be moved out of the element -->
  <xsl:variable name="punct-re">[,:;.]</xsl:variable>
  
  <xsl:variable name="langs">
    <lang>afrikanško</lang>
    <lang>angleško</lang>
    <lang>arabsko</lang>
    <lang>aramejsko</lang>
    <lang>asirsko</lang>
    <lang>avstrijsko</lang>
    <lang>babilonsko</lang>
    <lang>dansko</lang>
    <lang>egiptovsko</lang>
    <lang>egipčansko</lang>
    <lang>francosko</lang>
    <lang>galsko</lang>
    <lang>germansko</lang>
    <lang>grško</lang>
    <lang>hebrejsko</lang>
    <lang>hindi</lang>
    <lang>hindijsko</lang>
    <lang>indijanansko</lang>
    <lang>indijansko</lang>
    <lang>iransko</lang>
    <lang>irsko</lang>
    <lang>islandsko</lang>
    <lang>italijansko</lang>
    <lang>japonsko</lang>
    <lang>javansko</lang>
    <lang>jezik avstralskih staroselcev</lang>
    <lang>jidiš</lang>
    <lang>karibsko</lang>
    <lang>keltsko</lang>
    <lang>kečvansko</lang>
    <lang>kitajsko</lang>
    <lang>latinsko</lang>
    <lang>madžarsko</lang>
    <lang>malajsko</lang>
    <lang>maorsko</lang>
    <lang>mehiško</lang>
    <lang>mongolsko</lang>
    <lang>nemško</lang>
    <lang>nizozemsko</lang>
    <lang>norveško</lang>
    <lang>pali</lang>
    <lang>palijsko</lang>
    <lang>perzijsko</lang>
    <lang>polinezijsko</lang>
    <lang>poljsko</lang>
    <lang>portugalsko</lang>
    <lang>rusko</lang>
    <lang>sanskrtsko</lang>
    <lang>semitsko</lang>
    <lang>singalsko</lang>
    <lang>skandinavsko</lang>
    <lang>slovansko</lang>
    <lang>srbsko</lang>
    <lang>staronordijsko</lang>
    <lang>staroperzijsko</lang>
    <lang>tamilsko</lang>
    <lang>tatarsko</lang>
    <lang>tibetansko</lang>
    <lang>tunguško</lang>
    <lang>turkmensko</lang>
    <lang>turško</lang>
    <lang>češko</lang>
    <lang>špansko</lang>
    <lang>švedsko</lang>
  </xsl:variable>
  
  <!-- Regular expression that matches a language -->
  <xsl:variable name="lang-regex">
    <xsl:variable name="str">
      <xsl:for-each select="$langs/tei:lang">
        <xsl:value-of select="."/>
        <xsl:text>|</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="replace($str, '\|$', '')"/>
    <xsl:text>)</xsl:text>
  </xsl:variable>

  <!-- Regular expression that matches list of languages e.g. grško-latinsko -->
  <xsl:variable name="langs-regex">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="$lang-regex"/>
    <xsl:text>-?)+</xsl:text>
  </xsl:variable>

</xsl:stylesheet>
