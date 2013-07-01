### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 11:44:43 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

test_text.tagged:
	cat ../test_text.xml | MElt -t > test_text.tagged


melt_input.txt: ${SCRIPT_DIR}/prepare_4_melt.pl ${NEO_TAGGER_TEST_SENT}
	perl $< ${NEO_TAGGER_TEST_SENT} > $@

neo_test_melt.tagged: melt_input.txt
	cat $< | MElt -t -c > $@

neo_test_melt_comp.txt: ${SCRIPT_DIR}/melt_compare.pl neo_test_melt.tagged ${NEO_TAGGER_TEST_SENT}
	perl $< --gold=${NEO_TAGGER_TEST_SENT} neo_test_melt.tagged > $@

### Makefile ends here
