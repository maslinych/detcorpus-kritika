txtfiles := $(shell git ls-files txt/*.txt)
emigrantfiles := $(shell git ls-files emigranty/*.txt)
vertfiles := $(patsubst txt/%, vert/%, $(txtfiles:.txt=.vert)) $(patsubst emigranty/%, vert/%, $(emigrantfiles:.txt=.vert)) 
metafiles := $(vertfiles:.vert=.meta)
## corpus build setup
## corpora
corpbasename := kritika
corpsite := detcorpus
corpora := kritika
corpora-vert := $(addsuffix .vert, $(corpora))
compiled := $(corpbasename).vert
configs := config/kritika config/kritika.subcorpora
## Remote corpus installation data
corpsite-kritika := detcorpus
corpora-kritika := kritika
remotearch := corpora
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
#include remote.mk


.PHONY: test

vert:
	test -d $@ || mkdir -p $@


vert/%.vert: txt/%.txt | vert
		sed -e 's/<\?[pрPР]\([0-9]\+\)>\?/PB\1/' $< | \
		mystem -n -d -i -g -c -s --format xml | \
		sed 's/[^[:print:]]//g' | \
		python3 scripts/mystem2vert.py '$@' > '$@'

vert/%.vert: emigranty/%.txt | vert
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


export/$(corpbasename).tar.xz: $(compiled) $(configs)
	rm -f $@
	rm -f export/registry/*
	rm -f export/vert/*
	cp $(compiled) export/vert/
	cp $(configs) export/registry/
	bash -c "pushd $(@D) ; tar cJvf $(@F) --mode='a+r' registry/ vert/ ; popd"

lemmatize: $(vertfiles) scripts/mystem2vert.py

metavert: $(metafiles)

compile: $(compiled)

pack-files: export/$(corpbasename).tar.xz

upload-files: export/$(corpbasename).tar.xz
	rsync -e ssh -avP --stats $< $(HOST):$(remotearch)/

test:
	python3 test/metadata.py



