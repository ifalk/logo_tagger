### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 18:54:13 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

SEMTAG_HOME = /home/falk/semtag

semtag_input.txt: ${SCRIPT_DIR}/prepare_4_semtag.pl ${NEO_TAGGER_TEST_SENT}
	perl $< ${NEO_TAGGER_TEST_SENT} > $@

semtag_input_wo_neo.txt neo_index.pl: ${SCRIPT_DIR}/prepare_4_semtag.pl ${NEO_TAGGER_TEST_SENT}
	perl $< --no-neo ${NEO_TAGGER_TEST_SENT} > semtag_input_wo_neo.txt


# semtag_input.txt.POS.textualised: semtag_input.txt config
# 	python ${SEMTAG_HOME}/sem_tagger.py config

semtag_input_wo_neo.txt.POS.textualised: semtag_input_wo_neo.txt config
	python ${SEMTAG_HOME}/sem_tagger.py config


# neo_test_semtag_comp.txt semtag.txt: ${SCRIPT_DIR}/semtag_compare.pl semtag_input.txt.POS.textualised ${NEO_TAGGER_TEST_SENT}
# 	perl $< --gold=${NEO_TAGGER_TEST_SENT} --csv_out=semtag.txt semtag_input.txt.POS.textualised > neo_test_semtag_comp.txt

semtag_neos_comp.txt semtag.txt tagset.txt: ${SCRIPT_DIR}/semtag_compare_wo.pl semtag_input_wo_neo.txt.POS.textualised neo_index.pl
	perl $< --gold=neo_index.pl --csv_out=semtag.txt --tagset_out=tagset.txt semtag_input_wo_neo.txt.POS.textualised > semtag_neos_comp.txt


### Makefile ends here
