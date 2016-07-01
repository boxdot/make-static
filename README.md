% Make static blog
%
% May 12, 2015

We want to run `make` in a directory, which transforms all md-files in the same directory and all its subdirectories to html-files. All other files are copied. Of course, make should rebuild only updated files. We apply the following

## Strategy

The following transformation rules are to apply:

1. `index.md` -> `target/index.html` using pandoc
2. `title.md` ->
	a. create dir `target/title`
  	b. `target/title/index.html` using pandoc
3. every other `file` except for the files from 1 and 2 -> `target/file`
4. Apply 1--3 to each directory except for `target`.

## Possible extension

File and directory names beginning with a date, e.g. `2015-05-11-file`, could be placed in the directory `target/2015/05/11/file/`. On the other hand, if you take a look at the great [blog](http://bost.ocks.org/) of Mike Bostock, then you will see, that he uses just simple urls for articles, e.g. http://bost.ocks.org/mike/join/. And I think, that following Mike Bostock's design decisions can't be bad. Especially, since this idea was partly initiated by his [article](http://bost.ocks.org/mike/make/) about `make`.

## Implementation

```Makefile
# redefined in the recursive call
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

PANDOC=pandoc


all: $(TARGET) $(INDEX_HTML) $(HTML_FILES) $(TARGET_OTHER_FILES) $(TARGET_DIRS) 

$(TARGET):
	mkdir -p $(TARGET)

ifdef INDEX_HTML
$(INDEX_HTML): index.md
	$(PANDOC) $< -o $@
endif

$(HTML_FILES): $(TARGET)/%/index.html: %.md $(TARGET)/%
	$(PANDOC) $< -o $@

$(HTML_DIRS): $(TARGET)/%:
	mkdir -p $@

$(TARGET_OTHER_FILES): $(TARGET)/%: %
	cp $< $@

$(TARGET_DIRS): $(TARGET)/%: %
	@echo "$(\x1b[32;01m)Building recursively $<...$(\x1b[0m)"
	@make -C $< -f ../$(MAKEFILE) TARGET=../$@ MAKEFILE=../$(MAKEFILE)


.PHONY: clean
clean: 
	rm -rf $(TARGET)

```

[Download](Makefile) (MIT License)
