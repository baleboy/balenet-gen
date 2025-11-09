# Makefile for balenet-gen

BINARY_NAME = balenet-gen
BUILD_ROOT = .build
RELEASE_DIR = $(BUILD_ROOT)/Build/Products/Release
RELEASE_BINARY = $(RELEASE_DIR)/$(BINARY_NAME)
SITE_DIR = site
SITE_BUILD_DIR = $(SITE_DIR)/build

.PHONY: all build render clean clean-site clean-build test serve publish

all: build render

build:
	@echo "Building balenet-gen with Xcode..."
	@xcodebuild -project balenet-gen.xcodeproj \
		-scheme balenet-gen \
		-configuration Release \
		-derivedDataPath .build \
		build

render: build
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
serve: render
	@echo "Serving site from $(SITE_BUILD_DIR) on http://localhost:8000 ..."
	@cd $(SITE_DIR) && ( \
		python3 -m http.server --directory build & \
		SERVER_PID=$$!; \
		trap 'if kill -0 $$SERVER_PID 2>/dev/null; then kill $$SERVER_PID; fi' INT TERM EXIT; \
		sleep 1; \
		echo "Opening default browser..."; \
		python3 -m webbrowser http://localhost:8000/ >/dev/null 2>&1 || true; \
		wait $$SERVER_PID \
	)

.PHONY: publish
publish: render
	@./scripts/publish.sh
