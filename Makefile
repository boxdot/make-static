# redefined in the recursive call
MAKEFILE := Makefile
TARGET := output

MD_FILES=$(shell find *.md -maxdepth 0 -type f 2>/dev/null | grep -v index | tr '\n' ' ')
DIRS=$(shell find * -maxdepth 0 -type d 2>/dev/null | grep -v $(TARGET) | tr '\n' ' ')
OTHER_FILES=$(filter-out $(TARGET) $(DIRS) $(MD_FILES) index.md,$(wildcard *))

INDEX_HTML=$(addprefix $(TARGET)/,$(subst .md,.html,$(wildcard index.md)))
TARGET_DIRS=$(addprefix $(TARGET)/,$(DIRS))
HTML_FILES=$(addprefix $(TARGET)/,$(subst .md,/index.html,$(MD_FILES)))
HTML_DIRS=$(filter-out $(TARGET_DIRS),$(patsubst %/,%,$(dir $(HTML_FILES))))
TARGET_OTHER_FILES=$(addprefix $(TARGET)/,$(OTHER_FILES))

ASSETS_DIR=$(TARGET)/$(replace ./,,$(dir $(MAKEFILE)))assets
ASSETS_CSS=$(ASSETS_DIR)/style.css
ASSETS=$(ASSETS_DIR) $(ASSETS_CSS) $(ASSETS_DIR)/template.html

PANDOC=pandoc -s -t html5 --template $(ASSETS_DIR)/template.html


all: $(TARGET) $(INDEX_HTML) $(HTML_FILES) $(TARGET_OTHER_FILES) $(TARGET_DIRS) 

$(TARGET):
	mkdir -p $(TARGET)

ifdef INDEX_HTML
$(INDEX_HTML): index.md $(ASSETS)
	$(PANDOC) --css $(ASSETS_CSS) $< -o $@
endif

$(HTML_FILES): $(TARGET)/%/index.html: %.md $(TARGET)/% $(ASSETS)
	$(PANDOC) --css ../$(ASSETS_CSS) $< -o $@

$(HTML_DIRS): $(TARGET)/%:
	mkdir -p $@

$(TARGET_OTHER_FILES): $(TARGET)/%: %
	cp $< $@

$(TARGET_DIRS): $(TARGET)/%: %
	@echo "$(\x1b[32;01m)Building recursively $<...$(\x1b[0m)"
	@make -s all -C $< -f ../$(MAKEFILE) TARGET=../$@ MAKEFILE=../$(MAKEFILE)


.PHONY: clean
clean: 
	rm -rf $(TARGET)
