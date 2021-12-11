txtfiles := $(shell git ls-files txt/*.txt)
vertfiles := $(patsubst txt/%, vert/%, $(txtfiles:.txt=.vert))
metafiles := $(vertfiles:.vert=.meta)
## corpus build setup
## corpora
corpbasename := detcorpus
corpsite := detcorpus
corpora := kritika
corpora-vert := $(addsuffix .vert, $(corpora))
compiled := $(patsubst %,export/data/%/word.lex,$(corpora))
## Remote corpus installation data
corpsite-kritika := detcorpus
corpora-kritika := kritika
# SETUP CREDENTIALS
HOST=detcorpus
# CHROOTS
TESTING=testing
PRODUCTION=production
ROLLBACK=rollback
TESTPORT=8098
PRODPORT=8099
RSYNC=rsync -avP --stats -e ssh
## remote operation scripts
include remote.mk


.PHONY: test

vert:
	test -d $@ || mkdir -p $@


vert/%.vert: txt/%.txt | vert
		sed -e 's/<\?[pрPР]\([0-9]\+\)>\?/PB\1/' $< | \
		mystem -n -d -i -g -c -s --format xml | \
		sed 's/[^[:print:]]//g' | \
		python3 scripts/mystem2vert.py '$@' > '$@'

%.meta: %.vert metadata.csv scripts/getfilemeta.py
	sed -i -e  "1c $$(python3 scripts/getfilemeta.py metadata.csv $(*F))" $<
	touch $@

kritika.vert: $(metafiles) metadata.csv scripts/getfileids.py
	rm -f $@
	python3 scripts/getfileids.py metadata.csv | while read f ; do cat $$f >> $@ ; done

export/data/%/word.lex: config/% %.vert
	rm -rf export/data/$*
	rm -f export/registry/$*
	mkdir -p $(@D)
	mkdir -p export/registry
	mkdir -p export/vert
	encodevert -c ./$< -p $(@D) $*.vert
	cp $< export/registry
ifeq ("$(wildcard config/$*.subcorpora)","")
	echo "no subcorpora defined for $*:: $(wildcard config/$*.subcorpora)"
else
	mksubc ./export/registry/$* export/data/$*/subcorp config/$*.subcorpora
endif
	sed -i 's,./export,/var/lib/manatee/,' export/registry/$*

export/kritika.tar.xz: $(compiled)
	rm -f $@
	bash -c "pushd $(@D) ; tar cJvf $(@F) --mode='a+r' * ; popd"


lemmatize: $(vertfiles) scripts/mystem2vert.py

metavert: $(metafiles)

compile: $(compiled)

test:
	python3 test/metadata.py
