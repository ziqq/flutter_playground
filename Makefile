.PHONY: help
help: ## help dialog
				@echo 'Usage: make <OPTIONS>  <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Flutter version
				@fvm flutter --version

.PHONY: get
get: ## Getting the packages in root directory
				@echo "╠ GETTING PACKAGES"
				@fvm flutter pub get || (echo "▓▓ Get packages error ▓▓"; exit 1)
				@echo "╠ PACKAGES RECEIVED"

.PHONY: clean
clean: ## Clean generated files
				@echo "╠ RUN FLUTTER CLEAN"
				@fvm flutter clean || (echo "▓▓ Flutter clean error ▓▓"; exit 1)

.PHONY: cache-repair
cache-repair: ## Clean the pub cache
				@echo "╠ CLEAN PUB CACHE"
				@fvm flutter pub cache repair
				@echo "╠ PUB CACHE CLEANED SUCCESSFULLY"

.PHONY: fluttergen
fluttergen: ## Generate assets
				@echo "╠ RUN FLUTTERGEN"
				@fvm dart pub global activate flutter_gen
				@fvm fluttergen -c pubspec.yaml || (echo "▓▓ Fluttergen error ▓▓"; exit 1)
				@echo "╠ FLUTTERGEN SUCCESSFULLY"

.PHONY: l10n
l10n: ## Generate localization
				@fvm dart pub global activate intl_utils
				@fvm dart pub global run intl_utils:generate
				@fvm flutter gen-l10n --arb-dir lib/src/core/localization/translations --output-dir lib/src/core/localization/generated --template-arb-file intl_ru.arb

.PHONY: codegen
codegen: get fluttergen l10n build_runner format ## Generate code

.PHONY: gen
gen: codegen ## Generate all

.PHONY: upgrade
upgrade: ## Upgrade dependencies
				@echo "╠ RUN UPGRADE DEPENDENCIES"
				@fvm flutter pub upgrade || (echo "▓▓ Upgrade error ▓▓"; exit 1)
				@echo "╠ DEPENDENCIES UPGRADED SUCCESSFULLY"

.PHONY: upgrade-major
upgrade-major: ## Upgrade to major versions
				@echo "╠ RUN UPGRADE DEPENDENCIES TO MAJOR VERSIONS"
				@fvm flutter pub upgrade --major-versions|| (echo "▓▓ Upgrade error ▓▓"; exit 1)
				@echo "╠ DEPENDENCIES UPGRADED SUCCESSFULLY"

.PHONY: outdated
outdated: get ## Check outdated dependencies
				@fvm flutter pub outdated

.PHONY: dependencies
dependencies: upgrade ## Check outdated dependencies
				@fvm flutter pub outdated --dependency-overrides \
		--dev-dependencies --prereleases --show-all --transitive

.PHONY: run-build-runner
build-runner: ## Run build_runner:build
				@echo "╠ RUN BUILD RUNNER:BUILD"
				@fvm dart --disable-analytics && fvm dart run build_runner build --delete-conflicting-outputs --release
				@echo "╠ BUILD RUNNER:BUILD SUCCESSFULLY"

.PHONY: analyze
analyze: get ## Analyze code
				@echo "╠ RUN ANALYZE THE CODE"
				@fvm flutter analyze --fatal-infos --fatal-warnings lib/ test/ || (echo "👀 Analyze code error 👀"; exit 1)
				@echo "╠ ANALYZED CODE SUCCESSFULLY"

.PHONY: format
format: ## Format code
				@echo "╠ RUN FORMAT THE CODE"
				@fvm dart format --fix -l 120 . || (echo "👀 Format code error 👀"; exit 1)
				@echo "╠ CODE FORMATED SUCCESSFULLY"

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: icons
icons: ## Generate app icons used https://pub.dev/packages/flutter_launcher_icons
				@echo "╠ CREATE ICONS"
				@fvm dart run flutter_launcher_icons:main -f flutter_launcher_icons*  || (echo "▓▓ Create icons error ▓▓"; exit 1)
				@echo "╠ ICONS CREATED SUCCESSFULLY"

.PHONY: splash-screen
splash-screen: ## Generate app splash screen used https://pub.dev/packages/flutter_native_splash
				@echo "╠ CREATE SPLASH SCREEN"
				@fvm dart run flutter_native_splash:create  || (echo "▓▓ Create splash screen error ▓▓"; exit 1)
				@echo "╠ SPLASH SCREEN CREATED SUCCESSFULLY"

.PHONY: init-firebase
init-firebase: ## Init firebase
				@npm install -g firebase-tools
				@firebase login
				@firebase init
#				@fvm dart pub global activate flutterfire_cli
#				@flutterfire configure \
#				-i tld.domain.app \
#				-m tld.domain.app \
#				-a tld.domain.app \
#				-p project \
#				-e email			@gmail.com \
#				-o lib/src/common/constant/firebase_options.g.dart

# build-web:
# 	@flutter build web --release --dart-define-from-file=config/production.json --no-source-maps --pwa-strategy offline-first --web-renderer auto --web-resources-cdn --base-href /

# deploy-web: build-web
# 	@firebase deploy

#build-web-wasm: # https://docs.flutter.dev/platform-integration/web/wasm
#	@fvm spawn main build web --wasm --release --dart-define-from-file=config/development.json --no-source-maps --pwa-strategy offline-first --web-renderer skwasm --web-resources-cdn --base-href /

#deploy-web-wasm: build-web-wasm
#	@firebase hosting:channel:deploy wasm --expires 14d

# serve-web: build-web
# 	@firebase serve --only hosting -p 8080

# build-android:
# 	@fvm flutter build apk --release --dart-define-from-file=config/production.json

# build-windows:
# 	@flutter build windows --release --dart-define-from-file=config/production.json


.PHONY: build-render-object
build-render-object: ## Build and install Render Object Preview for IOS
				@fvm flutter build ios -t lib/src/render_object/preview.dart && fvm flutter install --flavor dev || (echo "¯\_(ツ)_/¯ BUILD RENDER OBJECT PREVIEW ERROR"; exit 1)