.PHONY: all pages clean

HTML=$(patsubst %.md,%.html,$(filter-out nav.md,$(wildcard *.md)))

all: pages

pages: $(HTML)

clean:
	rm -rf *.html tn

%.html: %.md nav.md
	@make --no-print-directory thumbs MD=$<
	@echo generating $@
	@$(call echo,$(call header,$(shell head -1 $<))) > $@~
	@echo '<nav>' >> $@~
	@$(call md,nav.md) >> $@~
	@echo '</nav>' >> $@~
	@$(call md,$<) >> $@~
	@printf '%s\n' '</body>' '</html>' >> $@~
	@mv $@~ $@

define md
cat $1 | \
sed -r 's/(\([a-zA-Z0-9-]+)\.md/\1.html/g; s%!\[([^]]+)\]\(img/([^)]+)\)%[![\1](tn\/\2)](img/\2)%g' | \
markdown
endef

define newline


endef

define echo
printf "%s\n" "$(subst $(newline)," ",$(subst ",\",$(1)))" 
endef

define header
<!DOCTYPE>
<html>
<head>
	<meta charset="utf-8">
    <title>$1</title>
	<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
endef


# thumbs target, defined only when MD is defined to a markdown filename
ifdef MD

define getimgs
perl -ne 'while (<>) { while (m%!\[.*?\]\(img/(.*?)\)%) { print "$$1\n"; $$_ = $${^POSTMATCH}; } }'
endef

imgs=$(shell $(getimgs) < $(MD))

.PHONY: thumbs
thumbs: $(foreach img,$(imgs),tn/$(img))
	@echo -n # noop

tn:
	@mkdir -p tn

tn/%: img/% tn
	convert $< -resize 400x400 $@

endif
