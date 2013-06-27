### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 09:37:25 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_CORPUS=/home/falk/Logoscope/VC/logoscope_2/stageRPF/corpusNeologismesFinal.xml

neo_tagger_test.xml: ${SCRIPT_DIR}/make_tagger_test_corpus.pl ${NEO_CORPUS}
	perl $< ${NEO_CORPUS} > $@

EDITED_TAGGER_TF=neo_tagger_test_edited.xml
neo_tagger_test_stats.csv: ${SCRIPT_DIR}/analyse_neo_tagger_test.pl ${EDITED_TAGGER_TF}
	perl $< ${EDITED_TAGGER_TF} > $@

neo_tagger_test_sentences.xml: ${SCRIPT_DIR}/sentences_neo_tagger_test.pl ${EDITED_TAGGER_TF}
	perl $< ${EDITED_TAGGER_TF} > $@

### Makefile ends here
