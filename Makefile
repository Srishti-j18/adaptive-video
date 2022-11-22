SOURCES := $(wildcard *.md)

NBS := $(patsubst %.md,%.ipynb,$(SOURCES))

%.ipynb: %.md
	pandoc  --self-contained --wrap=none  -i title.md $^ -o $@

all: $(NBS)

notebooks: $(NBS)

fabric:
	pandoc  --self-contained --wrap=none -i title.md intro_fabric.md \
		background.md reserve_resources_fabric.md  setup_adaptive_video.md \
		exec_cbr.md \
		data_analysis_fabric.md \
		exec_interruption.md exec_vary.md -o adaptive_video_fabric.ipynb

chameleon:
	pandoc  --self-contained --wrap=none -i title.md intro_chameleon.md \
		config_fabric_on_chameleon.md background.md reserve_resources_fabric.md  setup_adaptive_video.md \
		exec_cbr.md data_analysis_fabric.md exec_interruption.md exec_vary.md -o adaptive_video_chameleon.ipynb

clean: 
	rm -f *.ipynb


