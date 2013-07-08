### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 12:42:25 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

LIA_TAGG=/home/falk/lia_tagg

test_text.tagged:
	cat ../test_text.xml| ${LIA_TAGG}/script/lia_clean  | ${LIA_TAGG}/script/lia_tagg+reacc -guess > $@


lia_input.txt: ${SCRIPT_DIR}/prepare_4_lia.pl ${NEO_TAGGER_TEST_SENT}
	perl $< ${NEO_TAGGER_TEST_SENT} > $@

neo_test_lia.tok: lia_input.txt
	cat $< | ${LIA_TAGG}/bin/lia_tokenize ${LIA_TAGG}/data/lex80k.fr.tab -keep_fmt | perl -pe 's/S\s+_\s+(\d+)/S_$$1/g' > $@

neo_test_lia.seq: ${SCRIPT_DIR}/lia_sentences.pl neo_test_lia.tok
	perl $< neo_test_lia.tok > $@

neo_test_lia.tagged: neo_test_lia.seq
	cat $< | ${LIA_TAGG}/script/lia_tagg+reacc -guess > $@

neo_test_lia_comp.txt: ${SCRIPT_DIR}/lia_compare.pl neo_test_lia.tagged ${NEO_TAGGER_TEST_SENT}
	perl $< --gold=${NEO_TAGGER_TEST_SENT} neo_test_lia.tagged > $@


### Makefile ends here
