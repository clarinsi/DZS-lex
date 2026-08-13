# Conversion of the "Veliki splošni leksikon DZS" to TEI

[Veliki splošni leksikon DZS](https://sl.wikipedia.org/wiki/Veliki_splo%C5%A1ni_leksikon) (Large
General Lexicon of the DZS publishing house) is the largest printed encyclopedia in the Slovenian
language.  DZS-lex was first published on paper in 1997/1998 and then in 2005 on CD-ROM by the
Amebis company; in 2025 it was also installed on the their
[Termania portal](https://www.termania.net/slovarji/1028/Veliki_splosni_leksikon).

The rights for DZS-lex were obtained in the scope of the [RSDO project](https://rsdo.slovenscina.eu/)
and the file KNAUR.648 containing the complete encyclopedia obtained.
The file is an XML-like CP1250 file, with special characters outside the CP1250 range
encoded in a dedicated descriptive encoding.

This Git repository is devoted to converting the source KNAUR.648 encyclopedia into
a [TEI](https://www.tei-c.org/) encoding, in particular, using the elements from its dictionary module.

The repository contains the following directories:

* [Sample directory](Sample/) contains a sample of the source "KNAUR" lexicon in XML and all the files
  derived from this sample.
* [Scripts directory](Scripts/) contains the scripts used for processing the
  encyclopedia; note that the scripts assume a Linux operating system and that various prerequsites are installed.
  Most of the scripts are in XSLT and Perl, with a Makefile in the top directory containing the targets for conversion.
* [TEI directory](TEI/) contains the TEI ODD and derived RelaxNG schema for validation and derived HTML for
  documentatin of the derived TEI lexicon encoding.
* [Lexicon directory](Lexicon/) is meant to contain the complete source and all the TEI files derived from the source.
  Given their size, the contents are gitignored but, once finished, will be deposited in the
  [CLARIN.SI repository](https://www.clarin.si/repository/xmlui/).

Useful links:

* [Lexicon on the Termania](https://www.termania.net/slovarji/1028/Veliki_splosni_leksikon)
* [Introduction to the structure of the printed lexicon](https://slovarji.dzs.si/imgDir/slovarji/Uvod_VSL_knjiga.pdf)
* [TEI dictionary module](https://www.tei-c.org/release/doc/tei-p5-doc/en/html/DI.html)
