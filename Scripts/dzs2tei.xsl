<?xml version="1.0" encoding="utf-8"?>
<!-- Conversion of DZS lexicon in XML to TEI Lex0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.tei-c.org/ns/1.0" 
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:import href="dzs2tei-lib.xsl"/>
  
  <xsl:param name="id_prefix">dzs</xsl:param>

  <xsl:output indent="yes"/>
  <xsl:strip-space elements="TEI teiHeader text body entry sense figure floatingText"/>
  <xsl:preserve-space elements="form def gloss hi head distinct p oRef orth note"/>
  
  <!--xsl:template match="/">
    <xsl:apply-templates select="//FOR"/>
  </xsl:template-->
  
  <xsl:template match="/">
    <xsl:variable name="schema_url">TEILex0.rng</xsl:variable>
    <xsl:variable name="namespace">http://relaxng.org/ns/structure/1.0</xsl:variable>
    <xsl:text>&#10;</xsl:text>
    <xsl:processing-instruction	name="xml-model">
      <xsl:value-of select="concat(
			    'href=&quot;', $schema_url,
			    '&quot; type=&quot;application/xml&quot; schematypens=&quot;',
			    $namespace,
			    '&quot;'
			    )"/>
    </xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id" select="$id_prefix"/>
      <xsl:attribute name="xml:lang">sl</xsl:attribute>
      <xsl:copy-of select="$teiHeader"/>
      <text>
        <body>
          <xsl:variable name="pass1">
            <xsl:apply-templates/>
          </xsl:variable>
          <xsl:variable name="pass2">
            <xsl:apply-templates mode="pass2" select="$pass1"/>
          </xsl:variable>
          <xsl:variable name="pass3">
            <xsl:apply-templates mode="pass3" select="$pass2"/>
          </xsl:variable>
          <xsl:variable name="pass4">
            <xsl:apply-templates mode="pass4" select="$pass3"/>
          </xsl:variable>
          <xsl:apply-templates mode="pass5" select="$pass4"/>
        </body>
      </text>
    </TEI>
  </xsl:template>

  <!-- PASS 2: RENAME DZS ELEMENT TO TEI ONES -->
  
  <xsl:template match="DZS">
    <!-- Group by ID for entry e.g. <XX><PO><N>00000100+01</N> and for sense <XX><PO><N>00000100+02</N> etc. -->
    <xsl:for-each-group select="XX" group-by="*/substring-before(N[1], '+')">
      <xsl:variable name="head" select="current-group()[1]"/>
      <xsl:variable name="tail" select="current-group()[position() != 1]"/>
      <entry xml:lang="sl">
        <!-- No idea why these 3 types of entries are distinguished already at this level,
             their content models are similar (enough) to process them regardless which one it is;
             we distinguish them by entry/@type: -->
        <xsl:attribute name="type">
          <xsl:choose>
            <xsl:when test="$head/PO">regular</xsl:when>
            <xsl:when test="$head/BI">personOrGroup</xsl:when>
            <xsl:when test="$head/DR">country</xsl:when>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="xml:id" select="et:id(*[1]/N[1])"/>
        <xsl:attribute name="n" select="$head/*/name()"/>
        <xsl:apply-templates mode="head" select="$head/*"/>
        <xsl:apply-templates mode="sense" select="$tail/*"/>
      </entry>
    </xsl:for-each-group>
  </xsl:template>
  
  <!-- Need to fix IDs for entry and give IDs to sense! -->
  <xsl:template mode="head" match="PO | DR | BI">
    <xsl:choose>
      <xsl:when test="A">
        <xsl:apply-templates select="A/preceding-sibling::*"/>
        <sense n="{name()}">
          <xsl:apply-templates select="A | A/following-sibling::*"/>
        </sense>
      </xsl:when>
      <xsl:when test="A1">
        <xsl:apply-templates select="A1/preceding-sibling::*"/>
        <sense n="{name()}">
          <xsl:apply-templates select="A1 | A1/following-sibling::*"/>
        </sense>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="sense" match="PO | DR | BI">
    <sense n="{name()}">
      <xsl:attribute name="xml:id" select="et:id(N)"/>
      <xsl:apply-templates select="*[name() != 'G']"/>
    </sense>
  </xsl:template>
  
  <!-- ID of entry or sense; already processed in head / sense -->
  <xsl:template match="N"/>
    
  <!-- Headword, e.g. <G>a, </G> -->
  <xsl:template match="G">
    <form type="lemma" n="{name()}">
      <!-- Before G there is T, which gives some sort of label -->
      <orth>
        <xsl:if test="ancestor::BI">
          <xsl:attribute name="type">name</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="."/>
      </orth>
    </form>
  </xsl:template>
  
  <!-- Headword mentioned in text of the entry, or inside bigoraphical info -->
  <xsl:template match="YI">
    <xsl:choose>
      <xsl:when test="ancestor::RPOD">
        <distinct type="oRef" n="{name()}">
	  <xsl:apply-templates/>
	</distinct>
      </xsl:when>
      <xsl:otherwise>
	<oRef type="headword" n="{name()}">
	  <xsl:apply-templates/>
	</oRef>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Cross-reference mentioned in text of the entry -->
  <xsl:template match="ZX">
    <oRef type="cross-reference" n="{name()}">
      <xsl:apply-templates/>
    </oRef>
  </xsl:template>

  <!-- (Sub?)Sense number e.g. <A>1) </A>, <A0>1. </A0>, <A1>1) </A1>, <A2>2</A2> -->
  <xsl:template match="A | A0 | A1 | A2">
    <lbl type="number" n="{name()}">
      <xsl:value-of select="."/>
    </lbl>
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

      For now, we just treat the whole thing as <form>
  -->
  <xsl:template match="FOR | FOR1 | FOR2">
    <xsl:if test="normalize-space(.)">
      <xsl:choose>
	<!-- Various contexts where FOR(1) winds up in an element that doesn't allow form -->
	<xsl:when test="ancestor::LIME">  <!-- or ancestor::ES1 -->
	  <distinct type="form" n="{name()}">
	    <xsl:apply-templates/>
	  </distinct>
	</xsl:when>
	<xsl:otherwise>
	  <form n="{name()}">
	    <xsl:apply-templates/>
	  </form>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- FOR1 in rubric or definition, where it can be in <head>, hence cannot be form -->
    <xsl:template match="RUB//FOR1 | OPI//FOR1 | KDE//FOR1">
    <xsl:if test="normalize-space(.)">
      <distinct type="form" n="{name()}">
	<xsl:apply-templates/>
      </distinct>
    </xsl:if>
  </xsl:template>

  <!-- Not clear what this is: contains abbrevs, terms, names... -->
  <xsl:template match="FOR1X">
    <xsl:apply-templates/>
  </xsl:template>

  <!--  Definition, e.g.
       <KDE>prva črka slovenske abecede, </KDE>
       but also more comples:
       <KDE><A0>1. </A0>oznaka za mersko enoto površine <KP><KK>00377200+00</KK>ar</KP><QQ>...</QQ></KDE>
  -->
  <xsl:template match="KDE">
    <xsl:choose>
      <!-- <A0>1. </A0> ... -->
      <xsl:when test="A0">
        <xsl:apply-templates select="A0"/>
        <sense n="{name()}">
          <def n="{name()}">
            <xsl:apply-templates select="node()[name() != 'A0']"/>
          </def>
        </sense>
      </xsl:when>
      <xsl:when test="normalize-space(.)">
        <def n="{name()}">
          <xsl:apply-templates/>
        </def>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--  Weird - lingustics, with bugs and only 145, e.g.
       <hi rend="italic">Otrok-Ø piše-Ø, otrok<L>a</L> piše<L>ta</L>, otroc<L>i</L> piše<L>jo</L>; lep-Ø kraj-Ø, lep<L>o</L> mest<L>o</L>, lep<L>a</L> pokrajin<L>a</L>

      otrok</I> ← <I><L>on</L></I>

      <L>O tem sem prepričan.</L>
       
  -->
  <xsl:template match="L">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Various bits of info that all have to be encoded as definition -->
  
  <!-- OPI: description, e.g.
       <OPI>ustreza hebrejski alef in grški alfa.</OPI>
       OPIX: Wrapper for "born when and where", more or less and very few non-empty; experiment?
       <OPIX><RPOX>živel v začetku 7. st.
  -->
  <xsl:template match="OPI">
    <xsl:if test="normalize-space(.)">
      <def n="{name()}">
        <xsl:apply-templates/>
      </def>
    </xsl:if>
  </xsl:template>
  <xsl:template match="OPIX">
    <xsl:if test="normalize-space(.)">
      <def n="{name()}">
        <xsl:apply-templates/>
      </def>
    </xsl:if>
  </xsl:template>
  <xsl:template match="RPOX">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Geographical info, e.g.
       <FD> časovni pas	srednjeevropski čas + 1 ura površina	390.759 km ... </FD>
  -->
  <xsl:template match="FD">
    <floatingText type="table" n="{name()}">
      <body>
	<p>
          <xsl:apply-templates/>
	</p>
      </body>
    </floatingText>
  </xsl:template>
  
  <!-- Rubric with title and text, always(?) inside OPI, e.g.
       <RUB><RUBN><I>Dela</I></RUBN><RUBT><I>Kmetje, funkcionarji in bombe</I>....
       N.B: can have more than one RUBN, hence head hence we have to have divs
  -->
  <xsl:template match="RUB">
    <floatingText type="list" n="{name()}">
      <body>
        <xsl:for-each-group select="*" group-starting-with="RUBN">
	  <div>
            <xsl:apply-templates select="current-group()"/>
	  </div>
	</xsl:for-each-group>
      </body>
    </floatingText>
  </xsl:template>
  
  <xsl:template match="RUBK">
    <floatingText type="overview" n="{name()}">
      <body>
        <xsl:apply-templates/>
      </body>
    </floatingText>
  </xsl:template>

  <xsl:template match="RUBN">
    <head n="{name()}">
      <xsl:apply-templates/>
    </head>
  </xsl:template>
  <xsl:template match="RUBT">
    <p n="{name()}">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <!-- <FT> is a table inside RUBT, with text (rows, columns) directly in it, sparated by TAB, e.g.
       <RUBT><FT><U>1</U>/<D>32</D>"	=	0,794 mm <U>1</U>/<D>16</D>"	=	1,588 mm...
       This is marked on superordinate RUB, i.e. floatingText
  -->
  <xsl:template match="FT">
    <xsl:apply-templates/>
  </xsl:template>

  <!--  Domain e.g. <PODR><I>jezikoslovje:</I></PODR> -->
  <xsl:template match="PODR">
    <usg type="domain" n="{name()}">
      <xsl:value-of select="normalize-space(.)"/>
    </usg>
  </xsl:template>
  
  <!-- Cross reference e.g.
       <KP><KK>03691000+00</KK>lamaizmu</KP>
       <KB>U.-J.-J. <KK>03819500+00</KK>Leverriera</KB>
       
       <xr> not allowed in <def>, so simply <ref>!
  -->
  <xsl:template match="KP | KB">
    <xsl:if test="not(KK)">
      <xsl:message select="concat('ERROR: KP without KK in ', .)"/>
    </xsl:if>
    <!--xr n="{name()}"-->
      <xsl:apply-templates select="KK/preceding-sibling::node()"/>
      <ref target="{concat('#', et:id(KK))}" n="{name()}">
        <xsl:apply-templates select="KK/following-sibling::node()"/>
      </ref>
    <!--/xr-->
  </xsl:template>

  <!-- Pronunciation, however, most pronunciations are without this tag!
       If in def, can't be pron... -->
  <xsl:template match="IZGO">
    <xsl:choose>
      <xsl:when test="ancestor::KDE">
        <distinct type="pron" n="{name()}">
	  <xsl:apply-templates/>
	</distinct>
      </xsl:when>
      <xsl:otherwise>
	<pron n="{name()}">
	  <xsl:apply-templates/>
	</pron>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Years, no obvious difference between the elements -->
  <xsl:template match="LX | ILT | OLT | LT">
    <date n="{name()}">
      <xsl:apply-templates/>
    </date>
  </xsl:template>
  
  <!-- NAMES (AND TERMS) -->
  
  <!-- Name with preceeding explanation, e.g.
       <AIME>zdaj <I><EN>Arabat el Madfune</EN></I>, </AIME>
  -->
  <xsl:template match="AIME">
    <form n="{name()}">
      <xsl:apply-templates/>
    </form>
  </xsl:template>
  <!-- In defintion does not seem to perform a usefull function.
       Also, there are only 2 such cases and identical, i.e..
       <KDE><AIME><I><ES>parola</ES></I>, </AIME>
  -->
  <xsl:template match="KDE/AIME">
    <xsl:apply-templates/>
  </xsl:template>
 
  <!-- Name -->
  <!-- If directly in entry (i.e. BI,PO,DR), can't be name, must be form -->
  <xsl:template match="BI/OIME | PO/OIME | DR/OIME">
    <form type="forename" n="{name()}">
      <xsl:apply-templates/>
    </form>
  </xsl:template>
  <xsl:template match="OIME">
    <name n="{name()}">
      <xsl:apply-templates/>
    </name>
  </xsl:template>
  <!-- Name, no idea what is different from OIME -->
  <xsl:template match="PRIM">
    <name n="{name()}">
      <xsl:apply-templates/>
    </name>
  </xsl:template>
  
  <!-- Additional name, e.g.
       (Karl) <DOS>Veliki</DOS>
  -->
  <xsl:template match="DOS">
    <form type="addName" n="{name()}">
      <xsl:apply-templates/>
    </form>
  </xsl:template>
  <!-- Pseudonym -->
  <xsl:template match="PSIM">
    <addName type="pseudonym" n="{name()}">
      <xsl:apply-templates/>
    </addName>
  </xsl:template>
  
  <!-- "Names" but can be either a name or a term -->
  <xsl:template match="LIME | LIMEX | EN | ENX | ES | ES1 | ES1X">
    <xsl:if test="normalize-space(.)">
      <xsl:choose>
	<!-- LIME and ES1 are inside FOR (form) and also contains FOR1 with pronunciation, e.g.
	     <FOR>([árgav-], francosko <ES1><I>Argovie</I> <FOR1>[argoví]</FOR1></ES1>), </FOR>
	     <FOR>[arabsko <I><ES1>habeša</ES1></I>, ‚mešanje’], </FOR>
	     <FOR>(<LIME><I>Mitragyna ciliata</I></LIME>), </FOR>
	     <AIME><I><ES>pojmovno ime</ES></I>, </AIME>
	-->
	<xsl:when test="not(ancestor::KDE) and (
			(name() = 'LIME' and ancestor::FOR) or
			((name() = 'EN' or name() = 'ES' or name() = 'ES1') and (ancestor::FOR or ancestor::AIME))
			)
			">
	  <form n="{name()}">
	    <!-- Sometimes I is outside ES1, we have to move it in (cf. also template for I) -->
	    <xsl:choose>
	      <xsl:when test="ancestor::FOR and parent::I">
		<hi rend="italic" n="I">
		  <xsl:apply-templates/>
		</hi>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </form>
	</xsl:when>
	<xsl:otherwise>
          <distinct type="form" n="{name()}">
	    <xsl:if test="name() = 'LIMEX'">
	      <xsl:attribute name="xml:lang">la</xsl:attribute>
	    </xsl:if>
	    <xsl:apply-templates/>
	  </distinct>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Author / editor of entry -->
  <xsl:template match="Z">
    <xsl:if test="normalize-space(.)">
      <note type="admin" subtype="author" n="{name()}">
        <name>
          <xsl:apply-templates/>
        </name>
        <xsl:apply-templates mode="nest" select="following-sibling::K | following-sibling::KR"/>
      </note>
    </xsl:if>
  </xsl:template>
  
  <!-- Some sort of numeric key, for internal use? -->
  <xsl:template match="K | KR"/>
  <xsl:template mode="nest" match="K | KR">
    <xsl:if test="normalize-space(.)">
      <note type="class" n="{name()}">
        <xsl:apply-templates/>
      </note>
    </xsl:if>
  </xsl:template>

  <!-- Some sort of xr without reference -->
  <!-- Seems to appear only on QQ-->
  <xsl:template match="KAZ">
    <xsl:if test="ancestor::*/name() != 'QQ'">
      <xsl:message select="concat('ERROR: KAZ ancestor not QQ:', ancestor::*/name())"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Birth info (why, as there is also RPOD1? -->
  <xsl:template match="BORN">
    <xsl:if test="normalize-space(.)">
      <def n="{name()}">
	<state type="birth" n="{name()}">
          <desc>
            <xsl:apply-templates/>
          </desc>
	</state>
      </def>
    </xsl:if>
  </xsl:template>

  <!-- Birth/death info -->
  <xsl:template match="RPOD">
    <def n="{name()}">
      <xsl:apply-templates/>
    </def>
  </xsl:template>
  <xsl:template match="RPOD1">
    <xsl:if test="normalize-space(.)">
      <state type="birth" n="{name()}">
        <desc>
          <xsl:apply-templates/>
        </desc>
      </state>
    </xsl:if>
  </xsl:template>
  <xsl:template match="RPOD2">
    <xsl:if test="normalize-space(.)">
      <state type="death" n="{name()}">
        <desc>
          <xsl:apply-templates/>
        </desc>
      </state>
    </xsl:if>
  </xsl:template>

  <!-- Always(?) inside SK, the headword(?) -->
  <xsl:template match="B">
    <hi rend="bold" n="{name()}">
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <!-- Like B, except for names only -->
  <xsl:template match="BX">
    <name n="{name()}">
      <hi rend="bold">
        <xsl:apply-templates/>
      </hi>
    </name>
  </xsl:template>

  <xsl:template match="I">
    <xsl:choose>
      <!-- I will be moved inside these elements -->
      <xsl:when test="LIME or ES or ES1">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
	<hi rend="italic" n="{name()}">
	  <xsl:apply-templates/>
	</hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Superscripts -->
  <!-- Already in superscript -->
  <xsl:template match="U[. = '®' or . = '°']">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="U">
    <xsl:choose>
      <!-- mdash and hypen considered equal -->
      <xsl:when test="matches(., '^[0-9in+\-–=()]+$')">
        <xsl:analyze-string select="." regex=".">
          <xsl:matching-substring>
            <xsl:value-of select="translate(., '0123456789in+-–=()', '⁰¹²³⁴⁵⁶⁷⁸⁹ⁱⁿ⁺⁻⁻⁼⁽⁾')"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <hi rend="superscript" n="{name()}">
          <xsl:value-of select="."/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Subscripts -->
  <xsl:template match="D">
    <xsl:choose>
      <xsl:when test="matches(., '^[0-9]+$')">
        <xsl:analyze-string select="." regex=".">
          <xsl:matching-substring>
            <xsl:value-of select="translate(., '0123456789', '₀₁₂₃₄₅₆₇₈₉')"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <hi rend="subscript" n="{name()}">
          <xsl:value-of select="."/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Notes -->
  <!-- Margin text with reference to figure, admin info, and caption -->
  <xsl:template match="SK | SP">
    <note type="margin" subtype="figure" n="{name()}">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Caption of an illustration -->
  <xsl:template match="OPS">
    <xsl:if test="normalize-space(.)">
      <figure n="{name()}">
	<head>
          <xsl:apply-templates/>
	</head>
      </figure>
    </xsl:if>
  </xsl:template>
  
  <!-- Admin notes -->
  <!-- General admin note -->
  <xsl:template match="O">
    <note type="admin" subtype="comment" n="{name()}">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Reference to something, probably admin info -->
  <xsl:template match="SN">
    <note type="admin" n="{name()}">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Some sort indication of the status of entry (e.g. [OK], [O], [Z]) for internal use? -->
  <xsl:template match="text()[matches(., '^\[[A-Z]{1,3}\]$')]">
    <note type="admin">
      <lbl>
        <xsl:value-of select="."/>
      </lbl>
    </note>
  </xsl:template>

  <!-- Some sort of classification code, e.g.
       T = 41 classes like P, EN, E02, G3, G4H, L1-L1 ... L2-L2, G2/G4R etc.
       TS = EGX, EGY, SF, ...
  -->
  <xsl:template match="T | TS">
    <xsl:if test="normalize-space(.)">
      <note type="admin" subtype="class" n="{name()}">
        <xsl:apply-templates/>
      </note>
    </xsl:if>
  </xsl:template>
  
  <!-- Useless(?) admin ID(?),
       DXA is same as DX, except has added "A", e.g.
       <DX>00348500+00+01</DX>
       <DXA>00348500+00+01A</DXA>
       Some have two DX, some have empty DXA

       F0 is a pointer to externally stored equations and similar
  -->
  <xsl:template match="DX | DXA | F0">
    <xsl:if test="normalize-space(.)">
      <note type="pointer" n="{name()}">
        <xsl:apply-templates/>
      </note>
    </xsl:if>
  </xsl:template>

  <!-- REMOVED ELEMENTS -->
  
  <!--  Not clear what it means, always empty and only 4 of them: ignore -->
  <xsl:template match="PON"/>
  
  <!-- Some milestone between entry key and rest  -->
  <xsl:template match="W"/>

  <!-- Looks like an entry copied to the place where it is xr-ed, eg.
       <XX><PO><N>02894800+00</N><T>E02</T><G>Isonzo </G><FOR>[izónco], </FOR><KDE><KP><KK>06415200+00</KK>Soča</KP>
       <QQ><GQ><T>E02</T><G>Isonzo </G><K>328</K><KR>1.4.1</KR></GQ><T>G4R</T>
       <G>Soča </G><K>333e</K><KR>1.1.3.4/1.4.1</KR><KDE>reka v Sloveniji in Italiji, </KDE>[OK]</QQ>
       Will delete the whole thing!!
  -->
  <xsl:template match="QQ"/>
  <xsl:template match="GT"/>

  <!-- Catch all -->
  <xsl:template match="*">
    <xsl:message select="concat('ERROR: uncosumed element ', name())"/>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- PASS 2: MOVE DEF INTO PRECEDING SENSE (SOURCE HAS WRONG NESTING),
       MOVE AIME form into preceding form
       MARK UP ADDITIONAL DATES -->
  
  <!-- Copy def into sense -->
  <xsl:template mode="pass2" match="tei:sense[@n = 'KDE']">
    <xsl:copy>
      <xsl:apply-templates mode="pass2" select="@*"/>
      <xsl:apply-templates mode="pass2"/>
      <xsl:if test="following-sibling::tei:*[1][self::tei:def]">
        <xsl:copy-of select="following-sibling::tei:*[1]"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <!-- Remove original def -->
  <xsl:template mode="pass2" match="tei:def">
    <xsl:if test="not(preceding-sibling::tei:*[1][self::tei:sense])">
      <xsl:copy>
        <xsl:apply-templates mode="pass2" select="@*"/>
        <xsl:apply-templates mode="pass2"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!-- Move AIME into preceding non-lemma form -->
  <xsl:template mode="pass2" match="tei:form[not(@type = 'lemma')]">
    <xsl:choose>
      <xsl:when test="@n = 'AIME'">
        <!-- Remove original def -->
        <xsl:if test="not(preceding-sibling::tei:*[1][self::tei:form[not(@type = 'lemma')]])">
          <xsl:copy>
            <xsl:apply-templates mode="pass2" select="@*"/>
            <xsl:apply-templates mode="pass2"/>
          </xsl:copy>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="pass2" select="@*"/>
          <xsl:apply-templates mode="pass2"/>
          <!-- Move AIME into this form -->
          <xsl:if test="following-sibling::tei:*[1][self::tei:form[@n = 'AIME']]">
            <xsl:copy-of select="following-sibling::tei:*[1]"/>
          </xsl:if>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mark up additional dates in date range -->
  <xsl:template mode="pass2" match="text()">
    <xsl:choose>
      <!-- e.g. <date n="LT">1973</date>–76 -->
      <xsl:when test="preceding-sibling::tei:*[1][name() = 'date'] and matches(., '^–\d\d[^0-9]')">
        <xsl:variable name="century" select="replace(preceding-sibling::tei:date[1], '^(\d\d).*', '$1')"/>
        <xsl:variable name="decade" select="replace(., '^–(\d\d).*', '$1')"/>
        <xsl:text>–</xsl:text>
        <date when="{$century}{$decade}">
          <xsl:value-of select="$decade"/>
        </date>
        <xsl:value-of select="replace(., '^–(\d\d)', '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mark up additional dates in state/desc i.e. birth and death, has BC dates, and dates in old calendar -->
  <xsl:template mode="pass2" match="tei:state[@type = 'birth' or @type = 'death']/tei:desc/
                                    text()[matches(., '^[*†]')]">
    <xsl:call-template name="date-and-name"/>
  </xsl:template>
  
  <xsl:template name="date-and-name">
    <xsl:param name="str" select="."/>
    <xsl:param name="cert"/>
    <xsl:choose>
      <xsl:when test="matches($str, '^\s')">
        <xsl:text>&#32;</xsl:text>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^.', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^[*†,;:]')">
        <xsl:value-of select="replace($str, '^(.).+', '$1')"/>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^.', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^(verjetno )?ok\.')">
        <xsl:value-of select="replace($str, '^((verjetno )?ok\.).*', '$1')"/>
        <xsl:text>&#32;</xsl:text>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^(verjetno )?ok\.', '')"/>
          <xsl:with-param name="cert">low</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^verjetno ')">
        <xsl:value-of select="replace($str, '^(verjetno ).+', '$1')"/>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^verjetno ', '')"/>
          <xsl:with-param name="cert">medium</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^(\(\?\))')">
        <xsl:text>(?)</xsl:text>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^(\(\?\))', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^(\d\d?\.)?(\d\d?\.)?( \([0-9.]+\) )?(\d\d?\d?\d?)\s?(pr\. )?(n\. š\.)?')">
        <xsl:variable name="date" select="replace($str, '^((\d\d?\.)?(\d\d?\.)?( \([0-9.]+\) )?(\d\d?\d?\d?)\s?(pr\. )?(n\. š\.)?).+', '$1')"/>
        <xsl:variable name="iso-date" select="et:date2iso($date)"/>
        <date>
          <xsl:if test="normalize-space($iso-date)">
            <xsl:attribute name="when" select="$iso-date"/>
          </xsl:if>
          <xsl:if test="normalize-space($cert)">
            <xsl:attribute name="cert" select="$cert"/>
          </xsl:if>
          <xsl:value-of select="normalize-space($date)"/>
        </date>
        <xsl:if test="ends-with($date, ' ')">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, et:protect($date), '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^([\p{L} ]+\(.+?\))')">
        <xsl:variable name="placeName" select="replace($str, '^([\p{L} ]+\(.+?\)).*', '$1')"/>
        <placeName>
          <xsl:value-of select="normalize-space($placeName)"/>
        </placeName>
        <xsl:if test="ends-with($placeName, ' ')">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^([\p{L} ]+\(.+?\))', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($str, '^[\p{L} ]+\p{L}')">
        <xsl:variable name="placeName" select="replace($str, '^([\p{L} ]+\p{L}).*', '$1')"/>
        <placeName>
          <xsl:value-of select="normalize-space($placeName)"/>
        </placeName>
        <xsl:if test="ends-with($placeName, ' ')">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
        <xsl:call-template name="date-and-name">
          <xsl:with-param name="str" select="replace($str, '^[\p{L} ]+\p{L}', '')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="pass2" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="pass2" select="@*"/>
      <xsl:apply-templates mode="pass2" select="tei:*|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="pass2" match="@*">
    <xsl:copy/>
  </xsl:template>

  <!-- PASS 3: WHERE APPROPRIATE, MOVE PUNCTUATION OUTSIDE ELEMENTS, AND MOVE SPACE OUTSIDE END OF ELEMENTS -->

  <!-- Write out pc after element, if appropriate -->
  <xsl:template mode="pass3" match="tei:entry//tei:*
                                    [name() != 'body' and name() != 'div' and name() != 'head' and name() != 'p']">
    <xsl:copy>
      <xsl:apply-templates mode="pass3" select="@*"/>
      <xsl:apply-templates mode="pass3"/>
    </xsl:copy>
    <!-- The last text node in element -->
    <xsl:variable name="last" select="node()[last()]/self::text()"/>
    <!-- Nested text ends with snippable punctuation and maybe space -->
    <xsl:variable name="nested" select="."/>
    <!--xsl:message>DEBUG1: <xsl:value-of select="concat(name(), ' // ', $last, ' /// ', $nested)"/></xsl:message-->
    <xsl:choose>
      <!-- The last text node in element ends in end punctuation and this is not the only node in parent-->
      <xsl:when test="matches($last, concat($endpunct-re, '\s*$')) and (../tei:*[2] or ../text()[normalize-space(.)])">
        <xsl:variable name="punct" select="replace($last, concat('.*(', $endpunct-re, '\s*)$'), '$1')"/>
        <!--xsl:message>DEBUG2: <xsl:value-of select="concat(name(), ' // ', $punct)"/></xsl:message-->
        <xsl:choose>
          <!-- Next comes plain text, punct goes there -->
          <xsl:when test="following-sibling::node()[1]/self::text()[normalize-space(.)]">
            <xsl:value-of select="$punct"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$puncts//tei:pc[. = normalize-space($punct)]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- The text nested in element ends in end punctuation and there is only one subordinate element
           but more than one superordinate elements (we lift pc from nesting)
           Punct should not be ’ as this one is part of a gloss and should not be lifter!
           but
             and not(matches($nested, '’\s*$'))
           does not work ok.
      -->
      <xsl:when test="matches($nested, concat($endpunct-re, '\s*$'))
                      and not(tei:*[2] or text()[normalize-space(.)])
                      and (../tei:*[2] or ../text()[normalize-space(.)])">
        <xsl:variable name="punct" select="replace($nested, concat('.*(', $endpunct-re, '\s*)$'), '$1')"/>
        <!--xsl:message>DEBUG3: <xsl:value-of select="concat(name(), ' // ', $punct, ' /// ', text()[normalize-space(.)])"/></xsl:message-->
        <xsl:copy-of select="$puncts//tei:pc[. = normalize-space($punct)]"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="pass3" match="tei:entry//text()[normalize-space(.)]
                                      [not(parent::tei:head or parent::tei:p)]">
    <xsl:choose>
      <!-- If there are no following siblings and text ends in end punctuation, remove it -->
      <xsl:when test="not(following-sibling::tei:*) and matches(., concat($endpunct-re, '\s*$'))">
        <xsl:variable name="residue" select="replace(., concat($endpunct-re, '\s*$'), '')"/>
        <xsl:value-of select="replace(., concat($endpunct-re, '\s*$'), '')"/>
      </xsl:when>
      <!-- If element text in non-mixed content maybe remove start and/or end space -->
      <xsl:when test="not(../../text()[normalize-space(.)])">
        <xsl:choose>
          <!-- only element in parent, can remove both spaces --> 
          <xsl:when test="not(preceding-sibling::tei:* or following-sibling::tei:*)">
            <xsl:value-of select="replace(replace(., ' $', ''), '^ ', '')"/>
          </xsl:when>
          <!-- first element in parent, can remove start space --> 
          <xsl:when test="not(preceding-sibling::tei:*)">
            <xsl:value-of select="replace(., '^ ', '')"/>
          </xsl:when>
          <!-- last element in parent, can remove end space --> 
          <xsl:when test="not(following-sibling::tei:*)">
            <xsl:value-of select="replace(., ' $', '')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Try to remove space before left-glue punct, doesn't work! Maybe indent?
       Example:
       <hi rend="italic" n="I">vzdrževalno <oRef type="headword" n="YI">krmo</oRef>
       </hi>, -->
  <xsl:template mode="pass3" match="text()">
    <xsl:if test="normalize-space(.) or following-sibling::tei:* or 
                  not(matches(../following-sibling::node()[1][self::text()], concat('^', $endpunct-re, '$'))
                  )">
      <xsl:value-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="pass3" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="pass3" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="pass3" select="@*"/>
      <xsl:apply-templates mode="pass3" select="tei:*|text()"/>
    </xsl:copy>
  </xsl:template>

  <!-- PASS 4: CHANGE hi TO @rend ON ENCLOSED/ENCLOSING ELEMENT WHERE POSSIBLE -->

  <xsl:template mode="pass4" match="tei:entry//tei:*">
    <xsl:choose>
      <xsl:when test="self::tei:hi">
        <xsl:choose>
          <xsl:when test="tei:* and not(tei:*[2] or text()[normalize-space(.)])">
            <!--xsl:message select="concat('DEBUG: ', .)"/-->
            <xsl:apply-templates mode="pass4"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates mode="pass4" select="@*"/>
              <xsl:apply-templates mode="pass4"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="pass4" select="@*"/>
          <xsl:choose>
            <xsl:when test="parent::tei:hi and parent::tei:hi[not(tei:*[2] or text()[normalize-space(.)])]">
              <xsl:attribute name="rend" select="parent::tei:hi/@rend"/>
              <xsl:apply-templates mode="pass4"/>
            </xsl:when>
            <xsl:when test="tei:hi and not(tei:*[2] or text()[normalize-space(.)])">
              <xsl:attribute name="rend" select="tei:hi/@rend"/>
              <xsl:apply-templates mode="pass4" select="tei:hi/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="pass4"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="pass4" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template mode="pass4" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="pass4" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="pass4" select="@*"/>
      <xsl:apply-templates mode="pass4" select="tei:*|text()"/>
    </xsl:copy>
  </xsl:template>

  <!-- PASS 5: STRUCTURE form -->
  
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
        <!--xsl:message select="concat('WARNING: string left unprocessed: ', $str)"/-->
        <xsl:value-of select="$str"/>
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

  <!-- FUNCTIONS -->
  
  <!-- Construct IDs for entries and senses -->
  <xsl:function name="et:id">
    <xsl:param name="n"/>
    <xsl:value-of select="concat($id_prefix, replace($n, '\+', '.'))"/>
  </xsl:function>

  <xsl:function name="et:date2iso">
    <xsl:param name="date"/>
    <!--xsl:message select="concat('DEBUG: anaysing ', $date)"/-->
    <xsl:choose>
      <xsl:when test="matches($date, 'n\. š\.')">
        <xsl:analyze-string select="$date" regex="^(\d\d?\.)?(\d?\d?\.)?(\d\d?\d?\d?)\s?(pr. )?n. š.">
          <xsl:matching-substring>
            <xsl:variable name="day" select="replace(regex-group(1), '\.', '')"/>
            <xsl:variable name="month" select="replace(regex-group(2), '\.', '')"/>
            <xsl:variable name="bc" select="normalize-space(regex-group(4))"/>
            <xsl:variable name="year">
              <xsl:variable name="y" select="regex-group(3)"/>
              <xsl:choose>
                <!-- BC -->
                <xsl:when test="$bc">
                  <!-- BC 1 = 0000, BC 2 = -0001 etc. -->
                  <xsl:variable name="iso-year" select="string(number($y) - 1)"/>
                  <xsl:choose>
                    <xsl:when test="$iso-year = '0'">
                      <xsl:value-of select="$iso-year"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat('-', $iso-year)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <!-- AD -->
                <xsl:otherwise>
                  <xsl:value-of select="et:pad-date($y)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!--xsl:message select="concat('DEBUG: match with ', $year, ' - ', $month, ' - ', $day)"/-->
            <xsl:choose>
              <xsl:when test="normalize-space($day) and normalize-space($month) and normalize-space($year)">
                <xsl:value-of select="et:pad-date(concat($year, '-', $month, '-', $day))"/>
              </xsl:when>
              <!-- $day is here is actually month -->
              <xsl:when test="normalize-space($day) and normalize-space($year)">
                <xsl:value-of select="et:pad-date(concat($year, '-', $day))"/>
              </xsl:when>
              <xsl:when test="normalize-space($year)">
                <xsl:value-of select="et:pad-date($year)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message select="concat('ERROR: Failed to cast year from string ', $date)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:analyze-string select="$date" regex="^(\d\d?\.)?(\d\d?\.)?( \([0-9.]+\) )?(\d\d\d\d?)">
          <xsl:matching-substring>
            <xsl:variable name="day" select="replace(regex-group(1), '\.', '')"/>
            <xsl:variable name="month" select="replace(regex-group(2), '\.', '')"/>
            <xsl:variable name="year" select="regex-group(4)"/>
            <!--xsl:message select="concat('DEBUG: match with ', $year, ' - ', $month, ' - ', $day)"/-->
            <xsl:choose>
              <xsl:when test="normalize-space($day) and normalize-space($month) and normalize-space($year)">
                <xsl:value-of select="et:pad-date(concat($year, '-', $month, '-', $day))"/>
              </xsl:when>
              <!-- $day is here is actually month -->
              <xsl:when test="normalize-space($day) and normalize-space($year)">
                <xsl:value-of select="et:pad-date(concat($year, '-', $day))"/>
              </xsl:when>
              <xsl:when test="normalize-space($year)">
                <xsl:value-of select="et:pad-date($year)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message select="concat('ERROR: Failed to cast year from string ', $date)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
          
  <!-- Pad parts of date with 0 if necessary -->
  <xsl:function name="et:pad-date">
    <xsl:param name="date"/>
    <xsl:analyze-string select="$date" regex="^(-)?(\d\d?\d?\d?)(-\d\d?)?(-\d\d?)?\s*$">
      <xsl:matching-substring>
        <xsl:variable name="sign"  select="regex-group(1)"/>
        <xsl:variable name="year"  select="regex-group(2)"/>
        <xsl:variable name="month" select="substring-after(regex-group(3), '-')"/>
        <xsl:variable name="day"   select="substring-after(regex-group(4), '-')"/>
        <xsl:choose>
          <xsl:when test="normalize-space($day) and normalize-space($month) and normalize-space($year)">
            <xsl:value-of select="concat($sign, et:pad($year, 4), '-', et:pad($month, 2), '-', et:pad($day, 2))"/>
          </xsl:when>
          <xsl:when test="normalize-space($month) and normalize-space($year)">
            <xsl:value-of select="concat($sign, et:pad($year, 4), '-', et:pad($month, 2))"/>
          </xsl:when>
          <xsl:when test="normalize-space($year)">
            <xsl:value-of select="concat($sign, et:pad($year, 4))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="concat('ERROR: Cant convert date to ISO date: ', $date)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:message select="concat('ERROR: Bad date for ISO date: ', $date)"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:function>
  
  <!-- Pad a string with zeros -->
  <xsl:function name="et:pad">
    <xsl:param name="str"/>
    <xsl:param name="length"/>
    <xsl:variable name="zeros">
      <xsl:choose>
        <xsl:when test="$length = 4">0000</xsl:when>
        <xsl:when test="$length = 2">00</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="string(format-number(number($str), $zeros))"/>
    <!--xsl:value-of select="substring(
      concat('0000', $str),
      string-length($str) + 1, $length)"/-->
  </xsl:function>

  <!-- Escape special characters in string, so it can be passed to a RE literally -->
  <xsl:function name="et:protect">
    <xsl:param name="str"/>
    <xsl:value-of select="replace($str, '([\(\)\[\]\{\}\.])', '\\$1')"/>
  </xsl:function>

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
