SOURCES := $(wildcard *.md)

NBS := $(patsubst %.md,%.ipynb,$(SOURCES))

%.ipynb: %.md
	pandoc  --embed-resources --standalone --wrap=none  -i notebooks/title.md $^ -o $@

all: $(NBS)

notebooks: $(NBS)

clean: 
	rm -f *.ipynb


