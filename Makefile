# redefined in the recursive call
MAKEFILE := Makefile
TARGET := output

MD_FILES=$(shell find *.md -maxdepth 0 -type f 2>/dev/null | grep -v index | tr '\n' ' ')
DIRS=$(shell find * -maxdepth 0 -type d 2>/dev/null | grep -v $(TARGET) | grep -v assets | tr '\n' ' ')
OTHER_FILES=$(filter-out $(TARGET) $(DIRS) $(MD_FILES) index.md assets,$(wildcard *))

INDEX_HTML=$(addprefix $(TARGET)/,$(subst .md,.html,$(wildcard index.md)))
TARGET_DIRS=$(addprefix $(TARGET)/,$(DIRS))
HTML_FILES=$(addprefix $(TARGET)/,$(subst .md,/index.html,$(MD_FILES)))
HTML_DIRS=$(filter-out $(TARGET_DIRS),$(patsubst %/,%,$(dir $(HTML_FILES))))
TARGET_OTHER_FILES=$(addprefix $(TARGET)/,$(OTHER_FILES))

ASSETS_DIR=$(patsubst ./%,%,$(dir $(MAKEFILE)))assets
ASSETS_CSS=$(ASSETS_DIR)/style.css
ASSETS_TEMPLATE=$(ASSETS_DIR)/template.html
ASSETS=$(ASSETS_DIR) $(ASSETS_CSS) $(ASSETS_TEMPLATE)

PANDOC=pandoc -s

ifeq ($(dir $(MAKEFILE)),./)
TARGET_ASSETS_DIR=$(TARGET)/assets
endif


all: \
	info \
	$(TARGET) \
	$(INDEX_HTML) \
	$(HTML_FILES) \
	$(TARGET_OTHER_FILES) \
	$(TARGET_ASSETS_DIR) \
	$(TARGET_DIRS)

$(TARGET):
	mkdir -p $(TARGET)

ifdef INDEX_HTML
$(INDEX_HTML): index.md $(ASSETS)
	$(PANDOC) --template $(ASSETS_TEMPLATE) --css $(ASSETS_CSS) $< -o $@
endif

$(HTML_FILES): $(TARGET)/%/index.html: %.md $(TARGET)/% $(ASSETS)
	$(PANDOC)  --template $(ASSETS_TEMPLATE) --css ../$(ASSETS_CSS) $< -o $@

$(HTML_DIRS): $(TARGET)/%:
	mkdir -p $@

$(TARGET_OTHER_FILES): $(TARGET)/%: %
	cp $< $@

ifdef TARGET_ASSETS_DIR
$(TARGET)/assets: assets $(TARGET)
	cp -r $< $@
endif

$(TARGET_DIRS): $(TARGET)/%: %
	@echo "# Building recursively $<..."
	@make -s all -C $< -f ../$(MAKEFILE) TARGET=../$@ MAKEFILE=../$(MAKEFILE)


.PHONY: clean info
clean:
	rm -rf $(TARGET)

info:
	@echo $(dir $(MAKEFILE))
	@echo ASSETS_DIR $(ASSETS_DIR)
	@echo ASSETS_CSS $(ASSETS_CSS)
	@echo ASSETS_TEMPLATE $(ASSETS_TEMPLATE)
	@echo TARGET_ASSETS_DIR $(TARGET_ASSETS_DIR)

