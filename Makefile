PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall

install:
	mkdir -p "$(BINDIR)"
	cp ocsz "$(BINDIR)/ocsz"
	chmod +x "$(BINDIR)/ocsz"

uninstall:
	rm -f "$(BINDIR)/ocsz"
