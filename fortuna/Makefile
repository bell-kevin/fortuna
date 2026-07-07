# SPDX-License-Identifier: AGPL-3.0-or-later
# fortuna -- build with any recent gfortran (>= 10). `make`, `make test`.

FC      ?= gfortran
FFLAGS  ?= -O2 -Wall -Wextra -ffree-line-length-none -J$(BUILD)
PREFIX  ?= /usr/local

BUILD   := build
BIN     := bin

MODS := \
	src/fortuna_kinds.f90 \
	src/fortuna_rng.f90 \
	src/fortuna_sim.f90 \
	src/fortuna_forms.f90 \
	src/fortuna_json.f90 \
	src/fortuna_report.f90 \
	src/fortuna_web_assets.f90 \
	src/fortuna_http.f90 \
	src/fortuna_cli.f90

OBJS := $(patsubst src/%.f90,$(BUILD)/%.o,$(MODS))

.PHONY: all test clean install uninstall webassets run

all: $(BIN)/fortuna

$(BUILD)/%.o: src/%.f90 | $(BUILD)
	$(FC) $(FFLAGS) -c $< -o $@

# module dependencies
$(BUILD)/fortuna_rng.o:        $(BUILD)/fortuna_kinds.o
$(BUILD)/fortuna_sim.o:        $(BUILD)/fortuna_kinds.o $(BUILD)/fortuna_rng.o
$(BUILD)/fortuna_forms.o:      $(BUILD)/fortuna_kinds.o
$(BUILD)/fortuna_json.o:       $(BUILD)/fortuna_kinds.o
$(BUILD)/fortuna_report.o:     $(BUILD)/fortuna_sim.o $(BUILD)/fortuna_forms.o
$(BUILD)/fortuna_http.o:       $(BUILD)/fortuna_sim.o $(BUILD)/fortuna_forms.o \
                               $(BUILD)/fortuna_json.o $(BUILD)/fortuna_web_assets.o
$(BUILD)/fortuna_cli.o:        $(BUILD)/fortuna_report.o $(BUILD)/fortuna_http.o \
                               $(BUILD)/fortuna_json.o

$(BIN)/fortuna: $(OBJS) app/main.f90 | $(BIN)
	$(FC) $(FFLAGS) app/main.f90 $(OBJS) -o $@

$(BIN)/check: $(OBJS) test/check.f90 | $(BIN)
	$(FC) $(FFLAGS) test/check.f90 $(OBJS) -o $@

test: $(BIN)/check
	./$(BIN)/check

run: $(BIN)/fortuna
	./$(BIN)/fortuna serve

# regenerate src/fortuna_web_assets.f90 after editing web/index.html
webassets:
	python3 tools/embed_web.py web/index.html src/fortuna_web_assets.f90

install: $(BIN)/fortuna
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(BIN)/fortuna $(DESTDIR)$(PREFIX)/bin/fortuna

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/fortuna

$(BUILD) $(BIN):
	mkdir -p $@

clean:
	rm -rf $(BUILD) $(BIN)
