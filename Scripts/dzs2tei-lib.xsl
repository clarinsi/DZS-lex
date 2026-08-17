<?xml version="1.0" encoding="utf-8"?>
<!-- Variables for conversion -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns="http://www.tei-c.org/ns/1.0" 
		exclude-result-prefixes="tei"
		version="2.0">

  <xsl:param name="stamp">DZS-lex</xsl:param>
  <xsl:param name="id_prefix">dzs</xsl:param>
  <xsl:param name="handle">http://hdl.handle.net/11356/2332</xsl:param>
  <xsl:param name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <xsl:variable name="xml-model">
    <xsl:variable name="schema_url">../TEI/tei_dzslex.rng</xsl:variable>
    <!--xsl:variable name="schema_url">TEILex0.rng</xsl:variable-->
    <xsl:variable name="namespace">http://relaxng.org/ns/structure/1.0</xsl:variable>
    <xsl:text>&#10;</xsl:text>
    <xsl:processing-instruction name="xml-model">
      <xsl:value-of select="concat(
			    'href=&quot;', $schema_url,
			    '&quot; type=&quot;application/xml&quot; schematypens=&quot;',
			    $namespace,
			    '&quot;'
			    )"/>
    </xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="teiHeader">
    <teiHeader xml:lang="sl">
      <fileDesc>
        <titleStmt>
          <title xml:lang="sl">Veliki splošni leksikon DZS</title>
          <title xml:lang="sl">Large General Lexicon DZS</title>
          <respStmt/>
        </titleStmt>
        <editionStmt>
          <edition>Version 1.0</edition>
        </editionStmt>
        <extent/>
        <publicationStmt>
          <publisher>CLARIN.SI</publisher>
          <idno type="PID" subtype="handle"/>
          <availability>
            <p xml:lang="sl">Avtorske pravice za to izdajo ureja licenca
            <ref target="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
            Priznanje avtorstva-Deljenje pod enakimi pogoji 4.0 mednarodna licenca</ref>.</p>
            <p xml:lang="en">This work is licenced under the licence
            <ref target="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
            Attribution-ShareAlike 4.0 International</ref>.</p>
          </availability>
          <date/>
        </publicationStmt>
        <sourceDesc>
          <biblStruct>
            <monogr>
              <title>VELIKI splošni leksikon [Elektronski vir]</title>
              <idno type="ISBN">978-961-6474-90-0</idno>
              <idno type="COBISS.SI-ID">259150339</idno>
              <imprint>
                <publisher>Amebis, d.o.o.</publisher>
                <date>2025</date>
              </imprint>
            </monogr>
          </biblStruct>
        </sourceDesc>
      </fileDesc>
      <encodingDesc>
        <projectDesc>
	  <p xml:lang="sl">Pretvorba leksikona v TEI je bila narejena, da omogoči prenos berljive
	  različice leksikona z repozitorija CLARIN.SI zainteresiranim uporabniki ter, da omogoči
	  jezikoslovno označevanje leksikona in instalacijo na konkordančnike CLARIN.SI.</p>
        </projectDesc>
        <tagsDecl/>
    </encodingDesc>
      <profileDesc>
        <langUsage>
          <language ident="sl">slovenščina</language>
          <language ident="la">latinščina</language>
          <language ident="en">angleščina</language>
        </langUsage>
      </profileDesc>
      <revisionDesc xml:lang="en">
        <change when="2026-08-11"><name>Tomaž Erjavec</name> First draft.</change>
      </revisionDesc>
    </teiHeader>
  </xsl:variable>
  
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

  <xsl:variable name="langs">
    <lang>afrikanško</lang>
    <lang>afrikansko</lang>
    <lang>akadsko</lang>
    <lang>algonkinsko</lang>
    <lang>ameriški slang</lang>
    <lang>amharsko</lang>
    <lang>angleška</lang>
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
    <lang>bretonsko</lang>
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
    <lang>grenlandsko</lang>
    <lang>grško</lang>
    <lang>grškega</lang>
    <lang>grškemu</lang>
    <lang>hebrejsko</lang>
    <lang>hindijsko</lang>
    <lang>hindi</lang>
    <lang>hrvaško</lang>
    <lang>indijansko</lang>
    <lang>indonezijsko</lang>
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
    <lang>kirgiško</lang>
    <lang>kitajsko</lang>
    <lang>korejsko</lang>
    <lang>korzijškega</lang>
    <lang>kreolsko</lang>
    <lang>langue d'oc</lang>
    <lang>laoško</lang>
    <lang>latinsko</lang>
    <lang>latinskega</lang>
    <lang>latvijsko</lang>
    <lang>madžarsko</lang>
    <lang>makedonsko</lang>
    <lang>malajsko</lang>
    <lang>mandejsko</lang>
    <lang>maorsko</lang>
    <lang>mehiško</lang>
    <lang>melanezijsko</lang>
    <lang>mokpo</lang>
    <lang>mongolsko</lang>
    <lang>navaško</lang>
    <lang>nemško</lang>
    <lang>nizozemsko</lang>
    <lang>norveško</lang>
    <lang>normansko</lang>
    <lang>novolatinsko</lang>
    <lang>palijsko</lang>
    <lang>pali</lang>
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
    <lang>sanskrt</lang>
    <lang>saul</lang>
    <lang>semitsko</lang>
    <lang>semitskega</lang>
    <lang>singalsko</lang>
    <lang>sinijdžu</lang>
    <lang>skandinavsko</lang>
    <lang>slovansko</lang>
    <lang>slovaško</lang>
    <lang>slovensko</lang>
    <lang>slovenska</lang>
    <lang>spodnjenemško</lang>
    <lang>srednjeperzijsko</lang>
    <lang>srbsko</lang>
    <lang>starofrancosko</lang>
    <lang>starodansko</lang>
    <lang>staroegipčansko</lang>
    <lang>staroetiopsko</lang>
    <lang>starogrško</lang>
    <lang>staroiransko</lang>
    <lang>staronordijsko</lang>
    <lang>staronordijske</lang>
    <lang>staroperzijsko</lang>
    <lang>starorusko</lang>
    <lang>starovisokonemško</lang>
    <lang>sumersko</lang>
    <lang>sumerskega</lang>
    <lang>svahilijsko</lang>
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
    <lang>vzhodnoturško</lang>
    <lang>ugaritsko</lang>
    <lang>ujgursko</lang>
    <lang>ukrajinsko</lang>
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

  <!-- Hopefully matches pronunciation, as it will always have an accented vowel (pron can have more than one word) -->
  <xsl:variable name="acc-char">/?[ŕáàâéèêěəíóòôú～&#x0301;&#x032F;()]</xsl:variable>




  <xsl:variable name="pron-re">
    <xsl:variable name="pword" select="concat('(\p{Ll}*', $acc-char, '\p{Ll}*-?)')"/>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:value-of select="concat('^((a |al |an |as |aš bon |aš |apre |bi |bon |bu |če |d\)sen[^ ]*? |',
                          'd', $apos, '|',
                          'de |del |dela |de |dez |di |doš |do |duž |du |e |',
                          'eks |end |et |fen |fet |fir di |fir |fo |fon |for |i |il |la |le |',
                          'kom |ki |kum |kva |o |ov di |ov |pur |sik |san |sa |se |ša |šri |und |van |ven |/', ')?',
                          $pword, '(-', $pword, '?)?', '(\s', $pword, ')*)')"/>
    <!--xsl:value-of select="$acc-char"/-->
  </xsl:variable>

  <!-- Various labels -->
  <xsl:variable name="lbl-re">
    <xsl:text>^((</xsl:text>
    <xsl:text>i\. po|i\.|in|ali|tudi|do|iz|ter|morda|zato tudi|napačno tudi|od tod|od|oz\.|</xsl:text>
    <xsl:text>po kraju|po gorovju|po|</xsl:text>
    <xsl:text>verjetno po|verjetno iz|prvotno|pomen ni jasen|ustrezno|ustreza|zato tudi|</xsl:text>
    <xsl:text>zdaj|prej|prvotno|zastarelo|okrajšava|kratica za|kratica|kratici|simbol|</xsl:text>
    <xsl:text>lastno poimenovanje|pravo ime|polno ime|pojmovno ime|polno ime|trivialno ime za|častno ime|uradno ime|imenovan tudi|</xsl:text>
    <xsl:text>antični|beseda neznanega izvora|psevdonim|znak|oznaka|svetopisemski|komunistična kratica iz|</xsl:text>
    <xsl:text>znan tudi kot|sir|kemijska formula|celo ime|besedna igra na|</xsl:text>
    <xsl:text>ad lib\.|ad l\.|\+</xsl:text>
    <xsl:text>) )</xsl:text>
  </xsl:variable>

  <!-- Grammatical labels -->
  <xsl:variable name="gram-re">^(ednina|množina|množinska pomanjševalnica za|množinska oblika od|v sestavljankah)</xsl:variable>

  <!-- Year -->
  <xsl:variable name="year-re">1?(\d\d\d)</xsl:variable>

  <!-- Names of months -->
  <xsl:variable name="months">
    <date when="1">januar</date>
    <date when="2">februar</date>
    <date when="3">marec</date>
    <date when="4">april</date>
    <date when="5">maj</date>
    <date when="6">junij</date>
    <date when="7">julij</date>
    <date when="8">avgust</date>
    <date when="9">september</date>
    <date when="10">oktober</date>
    <date when="11">november</date>
    <date when="12">december</date>
  </xsl:variable>

  <!-- Regular expression that matches a month -->
  <xsl:variable name="month-re">
    <xsl:variable name="str">
      <xsl:for-each select="$months/tei:date">
        <xsl:value-of select="."/>
        <xsl:text>|</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="replace($str, '\|$', '')"/>
    <xsl:text>)</xsl:text>
  </xsl:variable>

  <!-- Abbreviation, at least three letters -->
  <xsl:variable name="abbr-re">(\p{Lu}[\p{Lu}\p{Ll}]{3,})</xsl:variable>

  <!-- Names -->
  <xsl:variable name="name-re">
    <!-- Frank or F(rank) -->
    <xsl:variable name="nameword-re">((([dl]')?\p{Lu}'?\p{Ll}+('s)?)|(\p{Lu}\(\p{Ll}+\)))</xsl:variable>
    <xsl:variable name="addword-re">(van|von|von \(de\)|d'|dall'|dell'|da|de|don|el|markizu de|sr\.|jr\.|&amp;)</xsl:variable>
    <xsl:variable name="abbrword-re">(\p{Lu}\.)</xsl:variable>
    <xsl:value-of select="concat('(', $abbrword-re, '|', $addword-re, '\s)?',
                          '(', '(', $nameword-re, '[-]', $nameword-re, ')', '|', $nameword-re, ')',
                          '(\s', $addword-re, '|', $abbrword-re, '|', $nameword-re, ')*®?')"/>
  </xsl:variable>
  
  <xsl:variable name="roman-re">([IVXLC]+)</xsl:variable>

  <xsl:variable name="element-re">(H|He|Li|Be|Br|B|C|N|O|F|Ne|Na|Mg|Al|Si|P|S|Cl|Ar|K|Ca|Fe|Cu|Ag|Au|Hg|Pb)</xsl:variable>
  <xsl:variable name="chemformula-re" select="concat('([=–]?', $element-re,
                                              '(',
                                              '\((', $element-re, '|', '[₀₁₂₃₄₅₆₇₈₉]', ')+\)', '|',
                                              '[=–\[\]₀₁₂₃₄₅₆₇₈₉⁻⁺]', '|', $element-re, ')',
                                              '+)')"/>
  <xsl:variable name="chemcompound-re">(\d+[,\-][\p{Nd}\p{Ll},\- ]+\p{Ll})</xsl:variable>

  <!-- Ordinary words, at least three chars not to pull in individual letters that are before
       the highlighted rest of the word, e.g.
       E<hi rend="italic" n="I">uzkadi</hi>
  -->
  <xsl:variable name="orth-re">(»?\p{L}[\p{L}\-,.!xyw ]+[\p{L}.]?«?)</xsl:variable>
</xsl:stylesheet>
