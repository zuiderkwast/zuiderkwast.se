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
	@printf '%s\n' '<article>' '<main>' >> $@~
	@$(call md,$<) >> $@~
	@echo '</main>' >> $@~
	@$(call echo,$(call footer,$<)) >> $@~
	@printf '%s\n' '</article>' '</body>' '</html>' >> $@~
	@mv $@~ $@

# Render the parameter markdown filename and output as HTML
define md
cat $1 | \
sed -r 's/(\([a-zA-Z0-9-]+)\.md/\1.html/g; s%!\[([^]]+)\]\(img/([^)]+)\)%[![\1](tn\/\2)](img/\2)%g' | \
markdown
endef

define newline


endef

# Output a multiline text (param) using a one-line command
define echo
printf "%s\n" "$(subst $(newline)," ",$(subst ",\",$(1)))" 
endef

# Markdown file as a parameter
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

define cc-by-sa
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons-license" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a> The text and images are available under <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
endef

# Markdown file as a parameter
define footer
<footer>
$(shell git log -1 --format="<p>Written %ai by %an <small>(%s)</small>.</p>" $1)
$(shell git log --skip=1 --format="<p>Edited %ai by %an <small>(%s)</small>.</p>" $1)
<p><a href="$1">Source code of this article in Markdown format</a></p>
<p>$(cc-by-sa)</p>
</footer>
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
