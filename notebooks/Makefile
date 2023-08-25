SOURCES := $(wildcard *.md)

NBS := $(patsubst %.md,%.ipynb,$(SOURCES))
NBS += reserve_resources_fabric.ipynb

RES_SNIPPETS := fabric-snippets/fab-config.md fabric-snippets/reserve-resources.md
reserve_resources_fabric.ipynb: $(RES_SNIPPETS) exp_define_fabric.md
	pandoc --wrap=none \
                -i intro_reserve_fabric.md \
				fabric-snippets/fab-config.md \
                exp_define_fabric.md \
                fabric-snippets/reserve-resources.md \
                fabric-snippets/configure-resources.md \
                fabric-snippets/ipv4-access-from-ipv6.md \
                fabric-snippets/draw-topo-detailed-labels.md \
                fabric-snippets/log-in.md \
                -o reserve_resources_fabric.md  
	pandoc --wrap=none -i reserve_resources_fabric.md -o reserve_resources_fabric.ipynb

%.ipynb: %.md
	pandoc --embed-resources --standalone --wrap=none  -i title.md $^ -o $@

all: $(NBS)

notebooks: $(NBS)


clean: 
	rm -f *.ipynb


