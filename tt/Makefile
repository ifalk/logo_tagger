### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 11:29:01 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

test_text.tagged: 
	perl /home/falk/tree-tagger/cmd/utf8-tokenize.perl -f -a /home/falk/tree-tagger/lib/french-abbreviations-utf8 ../test_text.xml | /home/falk/tree-tagger/bin/tree-tagger -token -lemma -sgml /home/falk/tree-tagger/lib/french-par-linux-3.2-utf8.bin 

tt_input.txt: ${SCRIPT_DIR}/prepare_4_tt.pl ${NEO_TAGGER_TEST_SENT}
	perl $< ${NEO_TAGGER_TEST_SENT} > $@

neo_test_tt.tagged: tt_input.txt
	perl /home/falk/tree-tagger/cmd/utf8-tokenize.perl -f -a /home/falk/tree-tagger/lib/french-abbreviations-utf8 $< | /home/falk/tree-tagger/bin/tree-tagger -token -lemma -sgml /home/falk/tree-tagger/lib/french-par-linux-3.2-utf8.bin > $@

neo_test_tt_comp.txt tt.txt tagset.txt: ${SCRIPT_DIR}/tt_compare.pl neo_test_tt.tagged ${NEO_TAGGER_TEST_SENT}
	perl $< --gold=${NEO_TAGGER_TEST_SENT} --csv_out=tt.txt --tagset_out=tagset.txt neo_test_tt.tagged > neo_test_tt_comp.txt




### Makefile ends here
