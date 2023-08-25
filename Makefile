SOURCES := $(wildcard *.md)

NBS := $(patsubst %.md,%.ipynb,$(SOURCES))

%.ipynb: %.md
	pandoc  --embed-resources --standalone --wrap=none  -i notebooks/title.md $^ -o $@

all: $(NBS)

notebooks: $(NBS)

fabric:
	pandoc --resource-path=notebooks/ --embed-resources --standalone --wrap=none -i notebooks/title.md notebooks/intro_fabric.md \
		notebooks/background.md notebooks/reserve_resources_fabric.md  notebooks/setup_adaptive_video.md \
		notebooks/exec_cbr.md \
		notebooks/data_analysis_fabric.md \
		notebooks/exec_interruption.md \
		notebooks/exec_policy.md \
		notebooks/exec_vary.md \
		notebooks/exercises.md notebooks/go_further.md \
		 -o adaptive_video_fabric.ipynb

chameleon:
	pandoc  --resource-path=notebooks/ --embed-resources --standalone --wrap=none -i notebooks/title.md notebooks/intro_chameleon.md \
		notebooks/config_fabric_on_chameleon.md notebooks/background.md notebooks/reserve_resources_fabric.md \
		notebooks/setup_adaptive_video.md \
		notebooks/exec_cbr.md \
		notebooks/data_analysis_fabric.md \
		notebooks/exec_interruption.md \
		notebooks/exec_policy.md \
		notebooks/exec_vary.md \
		notebooks/exercises.md notebooks/go_further.md \
		-o adaptive_video_chameleon.ipynb

clean: 
	rm -f *.ipynb


