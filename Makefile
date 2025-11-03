# Makefile for balenet-gen

BINARY_NAME = balenet-gen
BUILD_ROOT = .build
RELEASE_DIR = $(BUILD_ROOT)/Build/Products/Release
RELEASE_BINARY = $(RELEASE_DIR)/$(BINARY_NAME)
SITE_DIR = site
SITE_BUILD_DIR = $(SITE_DIR)/build

.PHONY: all build generate clean clean-site clean-build test serve

all: build render

build:
	@echo "Building balenet-gen with Xcode..."
	@xcodebuild -project balenet-gen.xcodeproj \
		-scheme balenet-gen \
		-configuration Release \
		-derivedDataPath .build \
		build

generate: build
	@echo "Rendering site into $(SITE_BUILD_DIR)..."
	@rm -rf $(SITE_BUILD_DIR)
	@$(RELEASE_BINARY) -s $(SITE_DIR) -o build

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_ROOT)
	@echo "✅ Clean complete."

clean-site:
	@echo "Cleaning generated site..."
	@rm -rf $(SITE_BUILD_DIR)
	@echo "✅ Site clean complete."

clean-build: clean
	@echo "✅ Clean complete."

.PHONY: test
test:
	@./scripts/test.sh

.PHONY: serve
serve: generate 
	@echo "Serving site from $(SITE_BUILD_DIR) on http://localhost:8000 ..."
	@cd $(SITE_DIR) && python3 -m http.server --directory build
