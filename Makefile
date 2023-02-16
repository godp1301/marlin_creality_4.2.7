.PHONY: build

SCRATCH_DIR := .scratch
OUTPUT_DIR := output
MARLIN_RELEASE := 2.1.2

all: prepare get_configuration get_marlin apply_configuration build compile firmware
default: all

clean:
	@rm -rf $(SCRATCH_DIR)
	@rm -rf $(OUTPUT_DIR)

prepare: $(SCRATCH_DIR) $(OUTPUT_DIR)

${SCRATCH_DIR}:
	@mkdir $(SCRATCH_DIR)

${OUTPUT_DIR}:
	@mkdir $(OUTPUT_DIR)

get_configuration: $(SCRATCH_DIR)/Configurations-$(MARLIN_RELEASE).zip

${SCRATCH_DIR}/Configurations-$(MARLIN_RELEASE).zip:
	curl -L https://github.com/MarlinFirmware/Configurations/archive/refs/tags/$(MARLIN_RELEASE).zip -o $(SCRATCH_DIR)/Configurations-$(MARLIN_RELEASE).zip
	unzip $(SCRATCH_DIR)/Configurations-$(MARLIN_RELEASE).zip -d $(SCRATCH_DIR) || true

get_marlin: $(SCRATCH_DIR)/release-$(MARLIN_RELEASE).zip

${SCRATCH_DIR}/release-$(MARLIN_RELEASE).zip:
	curl -L https://github.com/MarlinFirmware/Marlin/archive/refs/tags/$(MARLIN_RELEASE).zip -o $(SCRATCH_DIR)/release-$(MARLIN_RELEASE).zip
	unzip $(SCRATCH_DIR)/release-$(MARLIN_RELEASE).zip -d $(SCRATCH_DIR) || true

apply_configuration:
	cp $(SCRATCH_DIR)/Configurations-$(MARLIN_RELEASE)/config/examples/Creality/Ender-3\ Pro/CrealityV427/* $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/
	sed -i bck 's|//#define BLTOUCH|#define BLTOUCH|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|//#define AUTO_BED_LEVELING_BILINEAR|#define AUTO_BED_LEVELING_BILINEAR|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|//#define Z_SAFE_HOMING|#define Z_SAFE_HOMING|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|#define Z_MIN_PROBE_USES_Z_MIN_ENDSTOP_PIN|//#define Z_MIN_PROBE_USES_Z_MIN_ENDSTOP_PIN|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|//#define USE_PROBE_FOR_Z_HOMING|#define USE_PROBE_FOR_Z_HOMING|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|//#define Z_MIN_PROBE_PIN 32 // Pin 32 is the RAMPS default|#define Z_MIN_PROBE_PIN 17|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|//#define LCD_BED_LEVELING|#define LCD_BED_LEVELING|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|#define NOZZLE_TO_PROBE_OFFSET { 10, 10, 0 }|#define NOZZLE_TO_PROBE_OFFSET { -42, -2, 0 }|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	#sed -i bck 's|//#define MULTIPLE_PROBING 2|#define MULTIPLE_PROBING 2|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration.h
	sed -i bck 's|#define BLTOUCH_SET_5V_MODE|//#define #define BLTOUCH_SET_5V_MODE|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration_adv.h
	sed -i bck 's|//#define BABYSTEP_ZPROBE_OFFSET|#define BABYSTEP_ZPROBE_OFFSET|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration_adv.h
	sed -i bck 's|//#define PROBE_OFFSET_WIZARD|#define PROBE_OFFSET_WIZARD|' $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/Marlin/Configuration_adv.h

build:
	docker build . -t platformio:build

compile:
	docker run -it --rm -v $(shell pwd)/$(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE):/usr/src/Marlin-$(MARLIN_RELEASE) -w /usr/src/Marlin-$(MARLIN_RELEASE) platformio:build platformio run -e STM32F103RE_creality

firmware: $(OUTPUT_DIR)/firmware.bin

${OUTPUT_DIR}/firmware.bin:
	cp $(SCRATCH_DIR)/Marlin-$(MARLIN_RELEASE)/.pio/build/STM32F103RE_creality/firmware*.bin $(OUTPUT_DIR)/firmware.bin
