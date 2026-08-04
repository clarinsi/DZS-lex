<?xml version="1.0" encoding="utf-8"?>
<!-- Conversion of DZS lexicon in XML to TEI Lex0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:import href="dzs2lex0-lib.xsl"/>
  
  <xsl:param name="id_prefix">dzs</xsl:param>

  <xsl:output indent="yes"/>

  <!-- Hopefully matches pronunciation, as it will always have an accented vowel (pron can have more than one word) -->
  <xsl:variable name="acc-char">[áàâéèêěəíóòôú～&#x0301;&#x032F;-]</xsl:variable>
  <xsl:variable name="pron-re"
                select="concat('^((a |an |bon |bu |če |de |di |do |du |eks |end |et |fet |fir |fon |for |i |il |le |kom |ki |kum |o |ov |sik |ša |šri |ven )?',
                        '\w*', $acc-char, '\w*)')"/>

  <xsl:variable name="lang-re">(afrikanško|algonkinsko|amharsko|angleško|arabsko|arabskega|aramejsko|asirsko|avestsko|avstrijsko|azteško|babilonsko|berbersko|brazilsko|bursko|češko|češčina|češčine|dansko|egipčansko|egiptovsko|feničansko|flamsko|francosko|francoskega|francoščine|germansko|gotsko|grško|grškega|grškemu|hebrejsko|hindijsko|indijanansko|indijansko|iransko|irsko|islandsko|italijansko|japonsko|javansko|jidiš|karibsko|kečvansko|keltsko|kitajsko|korejsko|korzijškega|reolsko|kreolsko|latinsko|latinskega|latvijsko|madžarsko|malajsko|maorsko|mehiško|mokpo|mongolsko|navaško|nemško|nizozemsko|norveško|novolatinsko|palijsko|panmundžom|paštu|perzijsko|perzijščine|polinezijsko|poljsko|portugalsko|predgrško|provansalsko|retoromansko|romunsko|rusko|sanskrtsko|saul|semitsko|semitskega|singalsko|sinijdžu|skandinavsko|slovansko|srednjeperzijsko|srbsko|starofrancosko|staroetiopsko|staronordijsko|staroperzijsko|starovisokonemško|sumersko|sumerskega|špansko|švedsko|tamilsko|tatarsko|tedžan|tegu|tehan|tibetansko|tunguško|turkmensko|turško|ugaritsko|jezik avstralskih staroselcev|v jeziku Krijcev|v algonkinskih jezikih|verjetno iz češčine)</xsl:variable>
  <!-- One or more languages a la "nemško-francosko" -->
  <xsl:variable name="langs-re" select="concat('^', $lang-re, '(-', $lang-re, ')*')"/>
  
  <xsl:variable name="lbl-re">^(i\. po |in |ali |tudi |iz |ter |zato tudi |od tod |morda |po |verjetno po |verjetno iz |prvotno |morda |pomen ni jasen |ustrezno |ustreza |zato tudi |prvotno |\+|/)</xsl:variable>

  <xsl:variable name="gram-re">^(ednina|množina|množinska pomanjševalnica za|množinska oblika od|v sestavljankah)</xsl:variable>

  <xsl:variable name="left-re">^(,|;|\]|\))</xsl:variable>
  <xsl:variable name="right-re">^(\[|\()</xsl:variable>
  <xsl:variable name="space-re">^( |&#xA0;)</xsl:variable>


  <xsl:template match="/">
    <X>
      <xsl:apply-templates select="//FOR"/>
    </X>
  </xsl:template>
  
  <!-- <FOR> is can be a combo of
       Languages: [grško], [grško-latinsko], [latinsko-italijansko-francosko], [pali]
       language and name: [turško <I><ES1>komite</ES1></I>], [slovansko, latinsko <I><ES1>caesar</ES1></I>],
       [sanskrtsko, <KP><KK>06824900+00</KK>tantra</KP><QQ><GQ><T>P</T><G>tantrizem </G><K>143</K><KR>2.2.3</KR></GQ><T>P</T><G>tantra </G><K>143</K><KR>2.2.3</KR><KDE>v Indiji magični in mistični spisi tantrizma.</KDE>[OK]</QQ>], 
       What:  ([tibetansko], 
              ([rusko], latinsko <I><LIME>pax</LIME></I>), 
      Pronunciation: [f{i/}šer], [dž{o^}{u %u}ns], [p{%e}t{i/}], [p{e/}t{%e}rson], [pask{a/}l- {~}], etc.
      Etymology: [i. po mestu Orpington v Kentu], [i. po Andih], 
      Archaic 3x:  (zastarelo), 
      Quoted a la: (<LIME><I>Tragelaphus</I></LIME>), (latinsko <I><LIME>Iuba</LIME></I>), (kratica <I><ES1>ZPIZ</ES1></I>),
  -->
  <xsl:template match="FOR">
    <xsl:choose>
      <!-- This is not true, can be just pron... -->
      <xsl:when test="matches(., '^\[')">
        <etym>
          <xsl:apply-templates mode="FOR"/>
        </etym>
      </xsl:when>
      <xsl:otherwise>
        <!--xsl:message select="concat('WARN: Strange FOR ', $for)"/-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="FOR" match="*">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template mode="FOR" match="text()">
    <xsl:call-template name="FOR">
      <xsl:with-param name="str" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="FOR">
    <xsl:param name="str"/>
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

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  </xsl:stylesheet>
