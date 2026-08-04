# Conversion of the "Veliki splošni leksikon DZS" to TEI

[Veliki splošni leksikon DZS](https://sl.wikipedia.org/wiki/Veliki_splo%C5%A1ni_leksikon) (Large
General Lexicon of the DZS publishing house) is still the largest encyclopedia in the Slovenian
language.  DZS-lex was first published on paper in 1997/1998 and then in 2005 on CD-ROM by the
Amebis company; it was later also installed on the the [Termania
portal](https://www.termania.net/slovarji/1028/Veliki_splosni_leksikon).

The rights for the digital source for the CD-ROM edition were obtained in the scope of the [RSDO
project](https://rsdo.slovenscina.eu/). This source is an XML-like CP1250 endoded file, with
special characters encoded in a dedicated descriptive encoding.

This repository is devoted to converting the source dictionary into [TEI](https://www.tei-c.org/),
in particular, using the elements from its dictionary module.

The repository contains the following directories:

* [Sample directory](Sample/) contains a sample of the source lexicon and all the files
  derived from this sample.
* [Scripts directory](Scripts/) contains all the scripts that are used for processing the
  dictionary; note that the scripts assume that various prerequsites are installed and assumes
  a Linux operating system. Most of the scripts are in XSLT and Perl, with a Makefile in the
  top directory containing the targets for conversion.
* *[TEI directory](TEI/) contains the TEI ODD and derived RelaxNG schema for validation and derived HTML for
  documentatin of the derived TEI lexicon encoding.
* [Lexicon directory](Lexicon/) contains the complete source and all the TEI files derived from the source.
  Given their size, the contents are gitignored but, once finished, will be deposited in the
  [CLARIN.SI repository](https://www.clarin.si/repository/xmlui/).

Useful links:

* [Introduction to the structure of the lexicon](https://slovarji.dzs.si/imgDir/slovarji/Uvod_VSL_knjiga.pdf) (print version)
