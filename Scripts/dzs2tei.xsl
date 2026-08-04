<?xml version="1.0" encoding="utf-8"?>
<!-- Conversion of DZS lexicon in XML to TEI Lex0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
		xmlns:et="http://nl.ijs.si/et" 
		exclude-result-prefixes="et tei"
		version="2.0">

  <xsl:import href="dzs2tei-lib.xsl"/>
  
  <xsl:param name="id_prefix">dzs</xsl:param>

  <xsl:variable name="teiHeader">
    <teiHeader xmlns="http://www.tei-c.org/ns/1.0" xml:lang="sl">
      <fileDesc>
        <titleStmt>
          <title xml:lang="sl">Veliki splošni leksikon DZS [dzslex]</title>
          <title xml:lang="sl">Large General Lexicon DZS [dzslex]</title>
          <respStmt>
            <persName ref="https://orcid.org/0000-0002-1560-4099">Tomaž Erjavec</persName>
            <resp>Kodiranje TEI XML</resp>
            <resp xml:lang="en">TEI XML encoding</resp>
          </respStmt>
        </titleStmt>
        <editionStmt>
          <edition>Version 0.1</edition>
        </editionStmt>
        <extent>XXXXX entries</extent>
        <publicationStmt>
          <publisher>CLARIN.SI</publisher>
          <idno type="PID">http://hdl.handle.net/11356/xxxx</idno>
          <availability>
            <p xml:lang="sl">Avtorske pravice za to izdajo ureja licenca
          <ref target="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
          Priznanje avtorstva-Deljenje pod enakimi pogoji 4.0 mednarodna licenca</ref>.</p>
               <p xml:lang="en">This work is licenced under the licence
          <ref target="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
          Attribution-ShareAlike 4.0 International</ref>.</p>
            </availability>
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
      <profileDesc>
        <langUsage>
          <language ident="sl">slovenščina</language>
          <language ident="la">latinščina</language>
          <language ident="en">angleščina</language>
        </langUsage>
      </profileDesc>
      <revisionDesc xml:lang="en">
        <change when="2026-08-04"><name>Tomaž Erjavec</name> First draft.</change>
      </revisionDesc>
    </teiHeader>
  </xsl:variable>
  
  <xsl:output indent="yes"/>

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
          <xsl:apply-templates/>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="DZS">
    <!-- Group by ID for entry e.g. <XX><PO><N>00000100+01</N> and for sense <XX><PO><N>00000100+02</N> etc. -->
    <xsl:for-each-group select="XX" group-by="*/substring-before(N[1], '+')">
      <xsl:variable name="head" select="current-group()[1]"/>
      <xsl:variable name="tail" select="current-group()[position() != 1]"/>
      <entry xmlns="http://www.tei-c.org/ns/1.0" xml:lang="sl">
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
        <sense xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
          <xsl:apply-templates select="A | A/following-sibling::*"/>
        </sense>
      </xsl:when>
      <xsl:when test="A1">
        <xsl:apply-templates select="A1/preceding-sibling::*"/>
        <sense xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
          <xsl:apply-templates select="A1 | A1/following-sibling::*"/>
        </sense>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="sense" match="PO | DR | BI">
    <sense xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <xsl:attribute name="xml:id" select="et:id(N)"/>
      <xsl:apply-templates select="*[name() != 'G']"/>
    </sense>
  </xsl:template>
  
  <!-- ID of entry or sense; already processed in head / sense -->
  <xsl:template match="N"/>
    
  <!-- Milestone(?) for start of admin section at end of entry -->
  <xsl:template match="GT">
    <milestone xmlns="http://www.tei-c.org/ns/1.0" type="admin" unit="meta"/>
  </xsl:template>
    
  <!-- Headword, e.g. <G>a, </G> -->
  <xsl:template match="G">
    <form xmlns="http://www.tei-c.org/ns/1.0" type="lemma" n="{name()}">
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
        <distinct xmlns="http://www.tei-c.org/ns/1.0" type="oRef" n="{name()}">
	  <xsl:apply-templates/>
	</distinct>
      </xsl:when>
      <xsl:otherwise>
	<oRef xmlns="http://www.tei-c.org/ns/1.0" type="headword" n="{name()}">
	  <xsl:apply-templates/>
	</oRef>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Cross-reference mentioned in text of the entry -->
  <xsl:template match="ZX">
    <oRef xmlns="http://www.tei-c.org/ns/1.0" type="cross-reference" n="{name()}">
      <xsl:apply-templates/>
    </oRef>
  </xsl:template>

  <!-- (Sub?)Sense number e.g. <A>1) </A>, <A0>1. </A0>, <A1>1) </A1>, <A2>2</A2> -->
  <xsl:template match="A | A0 | A1 | A2">
    <lbl xmlns="http://www.tei-c.org/ns/1.0" type="number" n="{name()}">
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
	  <distinct type="form" xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
	    <xsl:apply-templates/>
	  </distinct>
	</xsl:when>
	<xsl:otherwise>
	  <form xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
	    <xsl:apply-templates/>
	  </form>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- FOR1 in rubric or definition, where it can be in <head>, hence cannot be form -->
    <xsl:template match="RUB//FOR1 | OPI//FOR1 | KDE//FOR1">
    <xsl:if test="normalize-space(.)">
      <distinct type="form" xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
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
        <sense xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
          <def n="{name()}">
            <xsl:apply-templates select="node()[name() != 'A0']"/>
          </def>
        </sense>
      </xsl:when>
      <xsl:when test="normalize-space(.)">
        <def xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
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
      <def xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
        <xsl:apply-templates/>
      </def>
    </xsl:if>
  </xsl:template>
  <xsl:template match="OPIX">
    <xsl:if test="normalize-space(.)">
      <def xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
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
    <floatingText xmlns="http://www.tei-c.org/ns/1.0" type="table" n="{name()}">
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
    <floatingText xmlns="http://www.tei-c.org/ns/1.0" type="list" n="{name()}">
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
    <floatingText xmlns="http://www.tei-c.org/ns/1.0" type="overview" n="{name()}">
      <body>
        <xsl:apply-templates/>
      </body>
    </floatingText>
  </xsl:template>

  <xsl:template match="RUBN">
    <head xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <xsl:apply-templates/>
    </head>
  </xsl:template>
  <xsl:template match="RUBT">
    <p xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
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
    <usg xmlns="http://www.tei-c.org/ns/1.0" type="domain" n="{name()}">
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
    <!--xr xmlns="http://www.tei-c.org/ns/1.0" n="{name()}"-->
      <xsl:apply-templates select="KK/preceding-sibling::node()"/>
      <ref xmlns="http://www.tei-c.org/ns/1.0" target="{concat('#', et:id(KK))}" n="{name()}">
        <xsl:apply-templates select="KK/following-sibling::node()"/>
      </ref>
    <!--/xr-->
  </xsl:template>

  <!-- Pronunciation, however, most pronunciations are without this tag!
       If in def, can't be pron... -->
  <xsl:template match="IZGO">
    <xsl:choose>
      <xsl:when test="ancestor::KDE">
        <distinct xmlns="http://www.tei-c.org/ns/1.0" type="pron" n="{name()}">
	  <xsl:apply-templates/>
	</distinct>
      </xsl:when>
      <xsl:otherwise>
	<pron xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
	  <xsl:apply-templates/>
	</pron>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Years, no obvious difference between the elements -->
  <xsl:template match="LX | ILT | OLT | LT">
    <date xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <xsl:apply-templates/>
    </date>
  </xsl:template>
  
  <!-- NAMES (AND TERMS) -->
  
  <!-- Name with preceeding explanation, e.g.
       <AIME>zdaj <I><EN>Arabat el Madfune</EN></I>, </AIME>
  -->
  <xsl:template match="AIME">
    <form xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
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
 
  <!-- Forename -->
  <!-- If directly in entry (i.e. BI,PO,DR), can't be name, must be form -->
  <xsl:template match="BI/OIME | PO/OIME | DR/OIME">
    <form xmlns="http://www.tei-c.org/ns/1.0" type="forename" n="{name()}">
      <xsl:apply-templates/>
    </form>
  </xsl:template>
  <xsl:template match="OIME">
    <forename xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <xsl:apply-templates/>
    </forename>
  </xsl:template>
  
  <!-- Surname -->
  <xsl:template match="PRIM">
    <surname xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <xsl:apply-templates/>
    </surname>
  </xsl:template>
  
  <!-- Additional name, e.g.
       (Karl) <DOS>Veliki</DOS>
  -->
  <xsl:template match="DOS">
    <form xmlns="http://www.tei-c.org/ns/1.0" type="addName" n="{name()}">
      <xsl:apply-templates/>
    </form>
  </xsl:template>
  <!-- Pseudonym -->
  <xsl:template match="PSIM">
    <addName xmlns="http://www.tei-c.org/ns/1.0" type="pseudonym" n="{name()}">
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
	  <form xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
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
          <distinct xmlns="http://www.tei-c.org/ns/1.0" type="form" n="{name()}">
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
      <note xmlns="http://www.tei-c.org/ns/1.0" type="admin" subtype="author" n="{name()}">
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
      <note xmlns="http://www.tei-c.org/ns/1.0" type="class" n="{name()}">
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
      <def xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
	<state xmlns="http://www.tei-c.org/ns/1.0" type="birth" n="{name()}">
          <desc>
            <xsl:apply-templates/>
          </desc>
	</state>
      </def>
    </xsl:if>
  </xsl:template>

  <!-- Birth/death info -->
  <xsl:template match="RPOD">
    <def xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <xsl:apply-templates/>
    </def>
  </xsl:template>
  <!-- Why two elements? -->
  <xsl:template match="RPOD1">
    <xsl:if test="normalize-space(.)">
      <state xmlns="http://www.tei-c.org/ns/1.0" type="birth" n="{name()}">
        <desc>
          <xsl:apply-templates/>
        </desc>
      </state>
    </xsl:if>
  </xsl:template>
  <xsl:template match="RPOD2">
    <xsl:if test="normalize-space(.)">
      <state xmlns="http://www.tei-c.org/ns/1.0" type="death" n="{name()}">
        <desc>
          <xsl:apply-templates/>
        </desc>
      </state>
    </xsl:if>
  </xsl:template>

  <!-- Always(?) inside SK, the headword(?) -->
  <xsl:template match="B">
    <hi xmlns="http://www.tei-c.org/ns/1.0" rend="bold" n="{name()}">
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <!-- Like B, except for names only -->
  <xsl:template match="BX">
    <name xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
      <hi xmlns="http://www.tei-c.org/ns/1.0" rend="bold">
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
	<hi xmlns="http://www.tei-c.org/ns/1.0" rend="italic" n="{name()}">
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
        <hi xmlns="http://www.tei-c.org/ns/1.0" rend="superscript" n="{name()}">
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
        <hi xmlns="http://www.tei-c.org/ns/1.0" rend="subscript" n="{name()}">
          <xsl:value-of select="."/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Notes -->
  <!-- Margin text with reference to figure, admin info, and caption -->
  <xsl:template match="SK | SP">
    <note xmlns="http://www.tei-c.org/ns/1.0" type="admin" subtype="figure" n="{name()}">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Caption of an illustration -->
  <xsl:template match="OPS">
    <xsl:if test="normalize-space(.)">
      <figure xmlns="http://www.tei-c.org/ns/1.0" n="{name()}">
	<head>
          <xsl:apply-templates/>
	</head>
      </figure>
    </xsl:if>
  </xsl:template>
  
  <!-- Admin notes -->
  <!-- General admin note -->
  <xsl:template match="O">
    <note xmlns="http://www.tei-c.org/ns/1.0" type="admin" subtype="comment" n="{name()}">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Reference to something, probably admin info -->
  <xsl:template match="SN">
    <note xmlns="http://www.tei-c.org/ns/1.0" type="admin" n="{name()}">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- Some sort indication of the status of entry (e.g. [OK], [O], [Z]) for internal use? -->
  <xsl:template match="text()[matches(., '^\[[A-Z]{1,3}\]$')]">
    <note xmlns="http://www.tei-c.org/ns/1.0" type="admin">
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
      <note xmlns="http://www.tei-c.org/ns/1.0" type="admin" subtype="class" n="{name()}">
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
      <note xmlns="http://www.tei-c.org/ns/1.0" type="pointer" n="{name()}">
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
 

  <!-- FUNCTIONS -->
  
  <!-- Construct IDs for entries and senses -->
  <xsl:function name="et:id">
    <xsl:param name="n"/>
    <xsl:value-of select="concat($id_prefix, replace($n, '\+', '.'))"/>
  </xsl:function>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  </xsl:stylesheet>
