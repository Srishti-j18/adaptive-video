SOURCES := $(wildcard *.md)

NBS := $(patsubst %.md,%.ipynb,$(SOURCES))

%.ipynb: %.md
	pandoc  --self-contained --wrap=none  $^ -o $@

all: $(NBS)

notebooks: $(NBS)

overall: background.md reserve_resources_fabric.md
	pandoc  --self-contained --wrap=none -i intro_fabric.md background.md reserve_resources_fabric.md  setup_adaptive_video.md exec_cbr.md data_analysis_fabric.md exec_interruption.md exec_vary.md -o adaptive_video_fabric.ipynb

clean: 
	rm -f *.ipynb


