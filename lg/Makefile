### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 18:54:13 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

LG_HOME = /home/falk/lgtagger-1.1

test_text.tagged:
	export LGTAGGER_PATH=${LG_HOME} ; \
export JAVA_HOME=/usr/lib/jvm/java-6-sun ; \
${LG_HOME}/lgtagger -t -L ../test_text.xml > $@


lg_input_wo_neo.txt neo_index.pl: ${SCRIPT_DIR}/prepare_4_lg.pl ${NEO_TAGGER_TEST_SENT}
	perl $< --no-neo ${NEO_TAGGER_TEST_SENT} > lg_input_wo_neo.txt

neo_test_lg.tagged: lg_input.txt
	export LGTAGGER_PATH=${LG_HOME} ; java -Xms1024M -Xmx1024M -cp /home/falk/lgtagger-1.1/classes:/home/falk/lgtagger-1.1/lib/JSAP-2.1.jar:/home/falk/lgtagger-1.1/lib/berkeleyParser-V1_1-fr.jar fr/upemlv/lgtools/tagging/LGTaggerMain --is_tokenized -m /home/falk/lgtagger-1.1/French/models/default $< > $@

neo_test_wo_neo_lg.tagged: lg_input_wo_neo.txt
	export LGTAGGER_PATH=${LG_HOME} ; java -Xms1024M -Xmx1024M -cp /home/falk/lgtagger-1.1/classes:/home/falk/lgtagger-1.1/lib/JSAP-2.1.jar:/home/falk/lgtagger-1.1/lib/berkeleyParser-V1_1-fr.jar fr/upemlv/lgtools/tagging/LGTaggerMain --is_tokenized -m /home/falk/lgtagger-1.1/French/models/default $< > $@




# neo_test_lg_comp.txt lg.txt: ${SCRIPT_DIR}/lg_compare.pl neo_test_lg.tagged ${NEO_TAGGER_TEST_SENT}
# 	perl $< --gold=${NEO_TAGGER_TEST_SENT} --csv_out=lg.txt neo_test_lg.tagged > neo_test_lg_comp.txt

lg_neos_comp.txt lg.txt tagset.txt: ${SCRIPT_DIR}/lg_compare_wo.pl neo_test_wo_neo_lg.tagged neo_index.pl
	perl $< --gold=neo_index.pl --csv_out=lg.txt --tagset_out=tagset.txt neo_test_wo_neo_lg.tagged > lg_neos_comp.txt 



### Makefile ends here
