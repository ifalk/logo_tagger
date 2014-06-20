corpus <- read.table("/home/falk/Logoscope/VC/tagger/neo_tagger_test_stats.csv", sep="\t", header=TRUE, quote="")
head(corpus)

### total

### lemmata
corpus$neo

#### occurences
sum(corpus$occ)

#### sentences
sum(corpus$texts)


## nouns

corpus[corpus$pos == 'nom',]

### neo lemmas for nouns

corpus[corpus$pos == 'nom',]$neo

nrow(corpus[corpus$pos == 'nom',])

### nouns, nbr of sentences

sum(corpus[corpus$pos == 'nom',]$texts)

### nouns, nbr of occurences

sum(corpus[corpus$pos == 'nom',]$occ)

## VERBS

corpus[corpus$pos == 'verbe',]

### neo lemmas for verbs

corpus[corpus$pos == 'verbe',]$neo

nrow(corpus[corpus$pos == 'verbe',])

### verbs, nbr of sentences

sum(corpus[corpus$pos == 'verbe',]$texts)

### verbs, nbr of occurences

sum(corpus[corpus$pos == 'verbe',]$occ)

## Adjectives

corpus[corpus$pos == 'adj',]

### neo lemmas for adjectives

corpus[corpus$pos == 'adj',]$neo

nrow(corpus[corpus$pos == 'adj',])

### adjectives, nbr of sentences

sum(corpus[corpus$pos == 'adj',]$texts)

### adjectives, nbr of occurences

sum(corpus[corpus$pos == 'adj',]$occ)


## ADVERBS

corpus[corpus$pos == 'adv',]

### neo lemmas for adverbs

corpus[corpus$pos == 'adv',]$neo

nrow(corpus[corpus$pos == 'adv',])

### adverbs, nbr of sentences

sum(corpus[corpus$pos == 'adv',]$texts)

### adverbs, nbr of occurences

sum(corpus[corpus$pos == 'adv',]$occ)

## MWEs

### neo lemmas for MWEs

nrow(corpus[grep("locution", corpus$pos),])

### MWEs, nbr of sentences

sum(corpus[grep("locution", corpus$pos),]$texts)

### MWEs, nbr of occurences

sum(corpus[grep("locution", corpus$pos),]$occ)


#### hyphenated, lemmas
nrow(corpus[grep("-", corpus$neo),])

### hyphenated, nbr of sentences

sum(corpus[grep("-", corpus$neo),]$texts)

### hyphenated, nbr of occurences

sum(corpus[grep("-", corpus$neo),]$occ)
