### Makefile --- 

## Author: falk@lormoral
## Version: $Id: Makefile,v 0.0 2014/03/21 09:38:44 falk Exp $
## Keywords: 
## X-URL: 


TAGGER_DIR=/home/falk/Logoscope/VC/tagger
SCRIPT_DIR=${TAGGER_DIR}/bin
NEO_TAGGER_TEST_SENT=${TAGGER_DIR}/neo_tagger_test_sentences.xml

input_sentence.txt neo_index.pl: ${SCRIPT_DIR}/prepare_4_talismane.pl ${NEO_TAGGER_TEST_SENT}
	perl $< ${NEO_TAGGER_TEST_SENT} > $@

tokenised.txt: input_sentence.txt tokeniser_template_with_location.ftl
	java -Xmx1024M -jar talismane-fr-1.8.2b-allDeps.jar command=analyse startModule=tokenise endModule=tokenise template=tokeniser_template_with_location.ftl inFile=$< outFile=$@


# postagged.txt: tokenised.txt postag_input_pattern.txt
# 	java -Xmx1024M -jar talismane-fr-1.8.2b-allDeps.jar command=analyse startModule=postag endModule=postag inputPatternFile=postag_input_pattern.txt inFile=$< outFile=$@

postagged.txt: input_sentence.txt posTagger_template_with_location.ftl
	java -Xmx1024M -jar talismane-fr-1.8.2b-allDeps.jar command=analyse startModule=tokenise endModule=postag template=posTagger_template_with_location.ftl inFile=$< outFile=$@


neos_comp.txt talismane.txt: ${SCRIPT_DIR}/talismane_compare.pl postagged.txt ../melt/neo_index.pl
	perl $< --gold=../melt/neo_index.pl --csv_out=talismane.txt postagged.txt > neos_comp.txt 

### Makefile ends here
