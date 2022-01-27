SRC:=config.go ipc.go options.go
EXT_SRC:=$(wildcard extension/Chrome/*) extension/Firefox/manifest.json
ldflags += -s -w 
out += open-in-mpv

ifeq ($(platform),)
  ifeq ($(OS),Windows_NT)
    platform := windows
  endif
endif

ifeq ($(platform),)
  uname := $(shell uname)
  ifeq ($(uname),)
    platform := windows
  else ifneq ($(findstring Windows,$(uname)),)
    platform := windows
  else ifneq ($(findstring NT,$(uname)),)
    platform := windows
  else ifneq ($(findstring Linux,$(uname)),)
    platform := linux
  else ifneq ($(findstring BSD,$(uname)),)
    platform := bsd
  else
    platform := linux
  endif
endif

ifeq ($(platform),windows)
	ldflags += -H=windowsgui
	out :=$(out).exe
endif

flags += -ldflags="$(ldflags)" 


all: build/open-in-mpv

build/open-in-mpv: $(SRC)
	@mkdir -p build
	go build $(flags) -o build/$(out) ./cmd/open-in-mpv

build/Firefox.zip: $(EXT_SRC)
	@mkdir -p build
	cp -t extension/Firefox extension/Chrome/{*.html,*.js,*.png,*.css}
	zip -r build/Firefox.zip extension/Firefox/
	@rm extension/Firefox/{*.html,*.js,*.png,*.css}

install: build/open-in-mpv
	cp build/open-in-mpv /usr/bin

install-protocol:
	scripts/install-protocol.sh

uninstall:
	rm /usr/bin/open-in-mpv

clean:
	rm -rf build/*

test:
	go test ./...

.PHONY: all install install-protocol uninstall clean test