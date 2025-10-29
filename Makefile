# Makefile for balenet-gen

PREFIX ?= /usr/local
INSTALL_PATH = $(PREFIX)/bin
BINARY_NAME = balenet-gen
XCODE_BUILD_DIR = $(shell xcodebuild -project balenet-gen.xcodeproj -scheme balenet-gen -configuration Release -showBuildSettings 2>/dev/null | grep "^\s*BUILT_PRODUCTS_DIR" | sed 's/.*= //')

.PHONY: all build install uninstall clean

all: build

build:
	@echo "Building balenet-gen with Xcode..."
	@xcodebuild -project balenet-gen.xcodeproj \
		-scheme balenet-gen \
		-configuration Release \
		-derivedDataPath .build \
		build

install: build
	@echo "Installing balenet-gen to $(INSTALL_PATH)..."
	@mkdir -p $(INSTALL_PATH)
	@cp -f .build/Build/Products/Release/$(BINARY_NAME) $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "✅ Installed successfully! Run 'balenet-gen --help' to verify."

uninstall:
	@echo "Uninstalling balenet-gen from $(INSTALL_PATH)..."
	@rm -f $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "✅ Uninstalled successfully."

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@echo "✅ Clean complete."
