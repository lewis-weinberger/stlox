PREFIX ?= /usr/local

install: package.xml stlox
	gst-package package.xml
	gst-load -i Lox
	install -m 755 stlox $(PREFIX)/bin

test:
	gst-sunit -v -p Lox

.PHONY: install test
