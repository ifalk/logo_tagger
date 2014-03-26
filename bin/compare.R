stanford <- read.table("/home/falk/Logoscope/VC/tagger/stanford/stanford_edited.txt", sep="\t", header=TRUE, quote="")

lg <- read.table("/home/falk/Logoscope/VC/tagger/lg/lg_wo_edited.txt", sep="\t", header=TRUE, quote="")

lia <- read.table("/home/falk/Logoscope/VC/tagger/lia/lia_edited_wo.txt", sep="\t", header=TRUE, quote="")

melt <- read.table("/home/falk/Logoscope/VC/tagger/melt/melt_wo_edited.txt", sep="\t", header=TRUE, quote="")
#### proper nouns = common nouns
melt <- read.table("/home/falk/Logoscope/VC/tagger/melt/melt_nc=np_edited.txt", sep="\t", header=TRUE, quote="")

tt <- read.table("/home/falk/Logoscope/VC/tagger/tt/tt_edited.txt", sep="\t", header=TRUE, quote="")

semtag <- read.table("/home/falk/Logoscope/VC/tagger/sem_tag/semtag_edited_wo.txt", sep="\t", header=TRUE, quote="")

tali <- read.table("/home/falk/Logoscope/VC/tagger/talismane/talismane_edited.txt", sep="\t", header=TRUE, quote="")


sf.score <- nrow(stanford[stanford$correct.==1,])/nrow(stanford)
lg.score <- nrow(lg[lg$correct.==1,])/nrow(lg)
lia.score <- nrow(lia[lia$correct.==1,])/nrow(lia)
melt.score <- nrow(melt[melt$correct.==1,])/nrow(melt)
tt.score <- nrow(tt[tt$correct.==1,])/nrow(tt)
semtag.score <- nrow(semtag[semtag$correct.==1,])/nrow(semtag)
tali.score <- nrow(tali[tali$correct.==1,])/nrow(tali)


comp <- cbind(tt[c("s_id", "g_word", "g_pos")], tt$correct., lg$correct., lia$correct., melt$correct., stanford$correct., semtag$correct., tali$correct.)

comp <- cbind(tt[c("s_id", "g_word", "g_pos")], tt$"t_pos" , lg$"t_pos", lia$"t_pos", melt$"t_pos", stanford$"t_pos", semtag$"t_pos", tali$"t_pos")




total <- colSums(comp[,4:9])/nrow(comp)

V = comp$g_pos == 'verbe'
nrow(comp[V,]) ## number of verbs in gold
verbs <- colSums(comp[V, 4:9])/nrow(comp[V,]) 

N = comp$g_pos == 'nom'
nrow(comp[N,]) ## number of nouns in gold
nouns <- colSums(comp[N, 4:9])/nrow(comp[N,]) 

A = comp$g_pos == 'adj'
nrow(comp[A,]) ## number of adjectives in gold
adj <- colSums(comp[A, 4:9])/nrow(comp[A,]) 

ADV = comp$g_pos == 'adv'
nrow(comp[ADV,]) ## number of adverbs in gold
adv <- colSums(comp[ADV, 4:9])/nrow(comp[ADV,]) 

NV = comp$g_pos != 'verbe'
NN = comp$g_pos != 'nom'
NAdj = comp$g_pos != 'adj'
NAdv = comp$g_pos != 'adv'

O = NV & NN & NAdj & NAdv
nrow(comp[O,]) ## other pos in gold (mwes)
other <- colSums(comp[O, 4:9])/nrow(comp[O,])

hynbr <- length(grep('-', comp[,2])) ## hyphenated words
hynbr
hyphen = colSums(comp[grep('-', comp[,2]), 4:9])/hynbr

wsnbr <- length(grep("\\s", comp[,3])) ## mwes
wsnbr
mwe = colSums(comp[grep("\\s", comp[,3]), 4:9])/wsnbr

comp$sumcorr <- rowSums(comp[, 4:9])
best.tagged <- comp[order(-comp$sumcorr, comp$g_pos),]
nrow(best.tagged[best.tagged$sumcorr == 6,])
nrow(best.tagged[best.tagged$sumcorr == 5,])
nrow(best.tagged[best.tagged$sumcorr == 4,])
nrow(best.tagged[best.tagged$sumcorr == 3,])
nrow(best.tagged[best.tagged$sumcorr == 2,])
nrow(best.tagged[best.tagged$sumcorr == 1,])
nrow(best.tagged[best.tagged$sumcorr == 0,])

### tt
best.tagged[best.tagged$sumcorr == 1 & best.tagged[["tt$correct."]] == 1, c("g_word", "g_pos", "tt$correct.")]
nrow(best.tagged[best.tagged$sumcorr == 1 & best.tagged[["tt$correct."]] == 1, c("g_word", "g_pos", "tt$correct.")])


### melt
best.tagged[best.tagged$sumcorr == 1 & best.tagged[["melt$correct."]] == 1, c("g_word", "g_pos", "melt$correct.")]
nrow(best.tagged[best.tagged$sumcorr == 1 & best.tagged[["melt$correct."]] == 1, c("g_word", "g_pos", "melt$correct.")])

### stanford
best.tagged[best.tagged$sumcorr == 1 & best.tagged[["stanford$correct."]] == 1, c("g_word", "g_pos", "stanford$correct.")]
nrow(best.tagged[best.tagged$sumcorr == 1 & best.tagged[["stanford$correct."]] == 1, c("g_word", "g_pos", "stanford$correct.")])


### lia
best.tagged[best.tagged$sumcorr == 1 & best.tagged[["lia$correct."]] == 1, c("g_word", "g_pos", "lia$correct.")]
nrow(best.tagged[best.tagged$sumcorr == 1 & best.tagged[["lia$correct."]] == 1, c("g_word", "g_pos", "lia$correct.")])


### lg
best.tagged[best.tagged$sumcorr == 1 & best.tagged[["lg$correct."]] == 1, c("g_word", "g_pos", "lg$correct.")]
nrow(best.tagged[best.tagged$sumcorr == 1 & best.tagged[["lg$correct."]] == 1, c("g_word", "g_pos", "lg$correct.")])


### semtag
best.tagged[best.tagged$sumcorr == 1 & best.tagged[["semtag$correct."]] == 1, c("g_word", "g_pos", "semtag$correct.")]
nrow(best.tagged[best.tagged$sumcorr == 1 & best.tagged[["semtag$correct."]] == 1, c("g_word", "g_pos", "semtag$correct.")])


best.tagged[best.tagged$sumcorr == 0, c("g_word", "g_pos")]
nrow(best.tagged[best.tagged$sumcorr == 0, c("g_word", "g_pos")])

best.tagged[best.tagged$sumcorr == 5, c("g_word", "g_pos")]
nrow(best.tagged[best.tagged$sumcorr == 5, c("g_word", "g_pos")])
 
### melt errors 92

nrow(comp[comp[["melt$correct."]] == 0, c("g_word", "g_pos")])

### stanford errors 66

nrow(comp[comp[["stanford$correct."]] == 0, c("g_word", "g_pos")])

### melt or stanford wrong 115

comp[comp[["stanford$correct."]] == 0 | comp[["melt$correct."]] == 0, c("g_word", "g_pos", "stanford$correct.", "melt$correct.")]

### stanford correct, melt wrong 49/32

comp[comp[["stanford$correct."]] == 1 & comp[["melt$correct."]] == 0, c("g_word", "g_pos", "stanford$correct.", "melt$correct.")]

melt[comp[["stanford$correct."]] == 1 & comp[["melt$correct."]] == 0, c("g_word", "g_pos", "t_pos")]

### melt correct, stanford wrong (25)

stanford[comp[["stanford$correct."]] == 0 & comp[["melt$correct."]] == 1, c("g_word", "g_pos", "t_pos")]

### melt errors

melt[comp[["melt$correct."]] == 0, c("g_word", "g_pos", "t_pos")]

### stanford errors

stanford[comp[["stanford$correct."]] == 0, c("g_word", "g_pos", "t_pos")]

##### used gold pos tags
levels(comp$"g_pos")
##### used lg pos tags
levels(comp$"lg$t_pos")

##### used lia pos tags
levels(comp$"lia$t_pos")

##### used melt pos tags
levels(comp$"melt$t_pos")

##### used semtag pos tags
levels(comp$"semtag$t_pos")

##### used stanford pos tags
levels(comp$"stanford$t_pos")

##### used tali pos tags
levels(comp$"tali$t_pos")

##### used tt pos tags
levels(comp$"tt$t_pos")
