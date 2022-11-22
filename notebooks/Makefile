SOURCES := $(wildcard *.md)

NBS := $(patsubst %.md,%.ipynb,$(SOURCES))

%.ipynb: %.md
	pandoc  --self-contained --wrap=none  -i title.md $^ -o $@

all: $(NBS)

notebooks: $(NBS)


clean: 
	rm -f *.ipynb


