### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2013/06/20 11:27:30 falk Exp $
## Keywords: 
## X-URL: 

TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

test_text.tagged:
	java -mx300m -cp '/home/falk/stanford-postagger-full-2013-04-04/stanford-postagger.jar:' edu.stanford.nlp.tagger.maxent.MaxentTagger -model /home/falk/stanford-postagger-full-2013-04-04/models/french.tagger -textFile ../test_text.xml > test_text.tagged


neo_test_stanford_tagged.xml: ${NEO_TAGGER_TEST_SENT}
	java -mx300m -cp '/home/falk/stanford-postagger-full-2013-04-04/stanford-postagger.jar:' edu.stanford.nlp.tagger.maxent.MaxentTagger -model /home/falk/stanford-postagger-full-2013-04-04/models/french.tagger -xmlInput s -textFile $< > $@

neo_test_stanford_comp.txt stanford.txt tagset.txt: ${SCRIPT_DIR}/stanford_compare.pl neo_test_stanford_tagged.xml ${NEO_TAGGER_TEST_SENT}
	perl $< --gold=${NEO_TAGGER_TEST_SENT} --csv_out=stanford.txt neo_test_stanford_tagged.xml --tagset_out=tagset.txt > neo_test_stanford_comp.txt

### Makefile ends here
