<?xml version="1.0" encoding="utf-8"?>
<!-- Variables for conversion -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns="http://www.tei-c.org/ns/1.0" 
		exclude-result-prefixes="tei"
		version="2.0">

  <!-- Punctuation that appears at start or end of element content and should be moved out of the element -->
  <xsl:variable name="puncts">
    <pc join="right">‚</pc>
    <!--pc join="right">(</pc Because of labels a la "1)"-->
    <!--pc join="right">[</pc Because if ( is missing, so should [ be (form)-->
    <pc join="left">,</pc>
    <pc join="left">:</pc>
    <pc join="left">;</pc>
    <!--pc join="left">.</pc Because of >idp.< etc. -->
    <pc join="left">’</pc>
    <!--pc join="left">]</pc-->
    <!--pc join="left">)</pc-->
  </xsl:variable>
  <xsl:variable name="startpunct-re">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="$puncts/tei:pc[@join = 'right']">
      <xsl:if test="matches(., '[\[\]\(\)]')">\</xsl:if>
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:variable>
  <xsl:variable name="endpunct-re">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="$puncts/tei:pc[@join = 'left']">
      <xsl:if test="matches(., '[\[\]\(\)]')">
        <xsl:text>\</xsl:text>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:variable>

  <!-- Hopefully matches pronunciation, as it will always have an accented vowel (pron can have more than one word) -->
  <xsl:variable name="acc-char">[áàâéèêěəíóòôú～&#x0301;&#x032F;-]</xsl:variable>
  <xsl:variable name="pron-re"
                select="concat('^((a |an |bon |bu |če |de |di |do |du |eks |end |et |fet |fir |fon |for |i |il |le
                        |kom |ki |kum |o |ov |sik |ša |šri |ven )?',
                        '\w*', $acc-char, '\w*)')"/>

  <xsl:variable name="langs">
    <lang>afrikanško</lang>
    <lang>algonkinsko</lang>
    <lang>amharsko</lang>
    <lang>angleško</lang>
    <lang>arabsko</lang>
    <lang>arabskega</lang>
    <lang>aramejsko</lang>
    <lang>asirsko</lang>
    <lang>avestsko</lang>
    <lang>avstrijsko</lang>
    <lang>azteško</lang>
    <lang>babilonsko</lang>
    <lang>berbersko</lang>
    <lang>brazilsko</lang>
    <lang>bursko</lang>
    <lang>češko</lang>
    <lang>češčina</lang>
    <lang>češčine</lang>
    <lang>dansko</lang>
    <lang>egipčansko</lang>
    <lang>egiptovsko</lang>
    <lang>feničansko</lang>
    <lang>flamsko</lang>
    <lang>francosko</lang>
    <lang>francoskega</lang>
    <lang>francoščine</lang>
    <lang>germansko</lang>
    <lang>gotsko</lang>
    <lang>grško</lang>
    <lang>grškega</lang>
    <lang>grškemu</lang>
    <lang>hebrejsko</lang>
    <lang>hindijsko</lang>
    <lang>indijanansko</lang>
    <lang>indijansko</lang>
    <lang>iransko</lang>
    <lang>irsko</lang>
    <lang>islandsko</lang>
    <lang>italijansko</lang>
    <lang>japonsko</lang>
    <lang>javansko</lang>
    <lang>jidiš</lang>
    <lang>karibsko</lang>
    <lang>kečvansko</lang>
    <lang>keltsko</lang>
    <lang>kitajsko</lang>
    <lang>korejsko</lang>
    <lang>korzijškega</lang>
    <lang>reolsko</lang>
    <lang>kreolsko</lang>
    <lang>latinsko</lang>
    <lang>latinskega</lang>
    <lang>latvijsko</lang>
    <lang>madžarsko</lang>
    <lang>malajsko</lang>
    <lang>maorsko</lang>
    <lang>mehiško</lang>
    <lang>mokpo</lang>
    <lang>mongolsko</lang>
    <lang>navaško</lang>
    <lang>nemško</lang>
    <lang>nizozemsko</lang>
    <lang>norveško</lang>
    <lang>novolatinsko</lang>
    <lang>palijsko</lang>
    <lang>panmundžom</lang>
    <lang>paštu</lang>
    <lang>perzijsko</lang>
    <lang>perzijščine</lang>
    <lang>polinezijsko</lang>
    <lang>poljsko</lang>
    <lang>portugalsko</lang>
    <lang>predgrško</lang>
    <lang>provansalsko</lang>
    <lang>retoromansko</lang>
    <lang>romunsko</lang>
    <lang>rusko</lang>
    <lang>sanskrtsko</lang>
    <lang>saul</lang>
    <lang>semitsko</lang>
    <lang>semitskega</lang>
    <lang>singalsko</lang>
    <lang>sinijdžu</lang>
    <lang>skandinavsko</lang>
    <lang>slovansko</lang>
    <lang>srednjeperzijsko</lang>
    <lang>srbsko</lang>
    <lang>starofrancosko</lang>
    <lang>staroetiopsko</lang>
    <lang>staronordijsko</lang>
    <lang>staroperzijsko</lang>
    <lang>starovisokonemško</lang>
    <lang>sumersko</lang>
    <lang>sumerskega</lang>
    <lang>špansko</lang>
    <lang>švedsko</lang>
    <lang>tamilsko</lang>
    <lang>tatarsko</lang>
    <lang>tedžan</lang>
    <lang>tegu</lang>
    <lang>tehan</lang>
    <lang>tibetansko</lang>
    <lang>tunguško</lang>
    <lang>turkmensko</lang>
    <lang>turško</lang>
    <lang>ugaritsko</lang>
    <lang>jezik avstralskih staroselcev</lang>
    <lang>v jeziku Krijcev</lang>
    <lang>v algonkinskih jezikih</lang>
  </xsl:variable>
  
  <!-- Regular expression that matches a language -->
  <xsl:variable name="lang-re">
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
  <xsl:variable name="langs-re">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="$lang-re"/>
    <xsl:text>-?)+</xsl:text>
  </xsl:variable>

  <!-- Various labels -->
  <xsl:variable name="lbl-re">^(i\. po |in |ali |tudi |iz |ter |zato tudi |od tod |morda |po |verjetno po |verjetno iz |prvotno |morda |pomen ni jasen |ustrezno |ustreza |zato tudi |prvotno |\+|/)</xsl:variable>

  <!-- Grammatical labels -->
  <xsl:variable name="gram-re">^(ednina|množina|množinska pomanjševalnica za|množinska oblika od|v sestavljankah)</xsl:variable>

</xsl:stylesheet>
