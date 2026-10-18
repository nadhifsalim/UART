
PROJECT      ?= counter

RTL_FILES    ?= $(PROJECT).v
TB_FILES     ?= $(PROJECT)_tb.v

DEVICE       ?= hx1k
PACKAGE      ?= tq144
PCF          ?= pins.pcf
FREQ         ?= 12

BUILD_DIR    ?= build

IVERILOG     ?= iverilog
VVP          ?= vvp
WAVEGEN      ?= surfer
YOSYS        ?= yosys
NEXTPNR      ?= nextpnr-ice40
ICEPACK      ?= icepack
ICEPROG      ?= iceprog

SIM          = $(BUILD_DIR)/$(PROJECT)_sim
VCD          = $(BUILD_DIR)/wave.vcd
JSON         = $(BUILD_DIR)/$(PROJECT).json
ASC          = $(BUILD_DIR)/$(PROJECT).asc
BIN          = $(BUILD_DIR)/$(PROJECT).bin

.DEFAULT_GOAL := help

.PHONY: help all sim run wave synth pnr bitstream program \
        clean check-tools


help:
	@echo "Available commands:"
	@echo "  make sim       - Compile Verilog for simulation"
	@echo "  make run       - Run simulation and generate VCD"
	@echo "  make wave      - Open VCD using $(WAVEGEN)"
	@echo "  make synth     - Synthesize design using Yosys"
	@echo "  make pnr       - Place and route using nextpnr"
	@echo "  make bitstream - Generate FPGA bitstream"
	@echo "  make program   - Upload bitstream to FPGA"
	@echo "  make all       - Run synthesis through bitstream generation"
	@echo "  make clean     - Remove generated files"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

sim:$(RTL_FILES) $(TB_FILES)
	$(IVERILOG) -g2012 -Wall -s $(notdir $(basename $(TB_FILES))) \
		-o $(SIM) $(RTL_FILES) $(TB_FILES)

run: sim
	$(VVP) $(SIM)

wave: run
	$(WAVEGEN) $(VCD) &


synth: $(RTL_FILES)
	$(YOSYS) -p "read_verilog -sv $(RTL_FILES); \
		hierarchy -check -top $(PROJECT); \
		synth_ice40 -top $(PROJECT) -json $(JSON)"

pnr: synth
	$(NEXTPNR) \
		--$(DEVICE) \
		--package $(PACKAGE) \
		--json $(JSON) \
		--pcf $(PCF) \
		--freq $(FREQ) \
		--asc $(ASC)

bitstream: pnr
	$(ICEPACK) $(ASC) $(BIN)

program: bitstream
	$(ICEPROG) $(BIN)

all: bitstream

clean:
	rm -rf $(SIM) $(VCD) $(JSON) $(ASC) $(BIN)