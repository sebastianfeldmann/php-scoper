.DEFAULT_GOAL := help

PHPBIN=php

.PHONY: help
help:
	@echo "\033[33mUsage:\033[0m\n  make TARGET\n\n\033[32m#\n# Commands\n#---------------------------------------------------------------------------\033[0m\n"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | awk 'BEGIN {FS = ":"}; {printf "\033[33m%s:\033[0m%s\n", $$1, $$2}'


#
# Build
#---------------------------------------------------------------------------

.PHONY: clean
clean:		## Clean all created artifacts
clean:
	git clean --exclude=.idea/ -ffdx

.PHONY: build
build:		## Build the PHAR
BOX=bin/box
build: bin/php-scoper.phar


#
# Tests
#---------------------------------------------------------------------------

.PHONY: test
test:		## Run all the tests
test: tc e2e

.PHONY: tu
PHPUNIT=bin/phpunit
tu:		## Run PHPUnit tests
tu: bin/phpunit
	$(PHPBIN) $(PHPUNIT)

.PHONY: tc
tc:		## Run PHPUnit tests with test coverage
tc: bin/phpunit vendor-bin/covers-validator/vendor clover.xml

.PHONY: tm
tm:		## Run Infection (Mutation Testing)
tm: bin/phpunit
	$(MAKE) e2e_020

.PHONY: e2e
e2e:		## Run end-to-end tests
e2e: e2e_004 e2e_005 e2e_011 e2e_013 e2e_014 e2e_015 e2e_016 e2e_017 e2e_018 e2e_019 e2e_020 e2e_021 e2e_022 e2e_023 e2e_024 e2e_025 e2e_026 e2e_027

PHPSCOPER=bin/php-scoper.phar

.PHONY: e2e_004
e2e_004:	## Run end-to-end tests for the fixture set 004 — Source code case
e2e_004: bin/php-scoper.phar
	$(PHPBIN) $(BOX) compile --working-dir fixtures/set004

	php build/set004/bin/greet.phar > build/set004/output
	diff fixtures/set004/expected-output build/set004/output

.PHONY: e2e_005
e2e_005:	## Run end-to-end tests for the fixture set 005 — Third-party code case
e2e_005: bin/php-scoper.phar fixtures/set005/vendor
	$(PHPBIN) $(BOX) compile --working-dir fixtures/set005

	php build/set005/bin/greet.phar > build/set005/output
	diff fixtures/set005/expected-output build/set005/output

.PHONY: e2e_011
e2e_011:	## Run end-to-end tests for the fixture set 011 — Whitelist case
e2e_011: bin/php-scoper.phar fixtures/set011/vendor
	$(PHPBIN) $(BOX) compile --working-dir fixtures/set011
	cp -R fixtures/set011/tests/ build/set011/tests/

	php build/set011/bin/greet.phar > build/set011/output
	diff fixtures/set011/expected-output build/set011/output

.PHONY: e2e_013
e2e_013:	# Run end-to-end tests for the fixture set 013 — The init command
e2e_013: bin/php-scoper.phar
	rm -rf build/set013
	cp -R fixtures/set013 build/set013
	$(PHPSCOPER) init --working-dir=build/set013 --no-interaction
	diff src/scoper.inc.php.tpl build/set013/scoper.inc.php

.PHONY: e2e_014
e2e_014:	## Run end-to-end tests for the fixture set 014 — Source code case with PSR-0
e2e_014: bin/php-scoper.phar
	$(PHPBIN) $(BOX) compile --working-dir fixtures/set014

	php build/set014/bin/greet.phar > build/set014/output
	diff fixtures/set014/expected-output build/set014/output

.PHONY: e2e_015
e2e_015:	## Run end-to-end tests for the fixture set 015 — Third-party code case with PSR-0
e2e_015: bin/php-scoper.phar fixtures/set015/vendor
	$(PHPBIN) $(BOX) compile --working-dir fixtures/set015

	php build/set015/bin/greet.phar > build/set015/output
	diff fixtures/set015/expected-output build/set015/output

.PHONY: e2e_016
e2e_016:	## Run end-to-end tests for the fixture set 016 — Symfony Finder
e2e_016: bin/php-scoper.phar fixtures/set016-symfony-finder/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set016-symfony-finder \
		--output-dir=../../build/set016-symfony-finder \
		--force \
		--no-config \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set016-symfony-finder dump-autoload

	php build/set016-symfony-finder/main.php > build/set016-symfony-finder/output
	diff fixtures/set016-symfony-finder/expected-output build/set016-symfony-finder/output

.PHONY: e2e_017
e2e_017:	## Run end-to-end tests for the fixture set 017 — Symfony DependencyInjection
e2e_017: bin/php-scoper.phar fixtures/set017-symfony-di/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set017-symfony-di \
		--output-dir=../../build/set017-symfony-di \
		--force \
		--no-config \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set017-symfony-di dump-autoload

	php build/set017-symfony-di/main.php > build/set017-symfony-di/output
	diff fixtures/set017-symfony-di/expected-output build/set017-symfony-di/output

.PHONY: e2e_018
e2e_018:	## Run end-to-end tests for the fixture set 018 — Nikic PHP-Parser
e2e_018: bin/php-scoper.phar fixtures/set018-nikic-parser/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set018-nikic-parser \
		--prefix=_Prefixed \
		--output-dir=../../build/set018-nikic-parser \
		--force \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set018-nikic-parser dump-autoload

	php build/set018-nikic-parser/main.php > build/set018-nikic-parser/output
	diff fixtures/set018-nikic-parser/expected-output build/set018-nikic-parser/output

.PHONY: e2e_019
e2e_019:	## Run end-to-end tests for the fixture set 019 — Symfony Console
e2e_019: bin/php-scoper.phar fixtures/set019-symfony-console/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix --working-dir=fixtures/set019-symfony-console \
		--prefix=_Prefixed \
		--output-dir=../../build/set019-symfony-console \
		--force \
		--no-config \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set019-symfony-console dump-autoload

	php build/set019-symfony-console/main.php > build/set019-symfony-console/output
	diff fixtures/set019-symfony-console/expected-output build/set019-symfony-console/output

.PHONY: e2e_020
e2e_020:	## Run end-to-end tests for the fixture set 020 — Infection
e2e_020: bin/php-scoper.phar fixtures/set020-infection/vendor clover.xml
	$(PHPBIN) $(PHPSCOPER) add-prefix --working-dir=fixtures/set020-infection \
		--output-dir=../../build/set020-infection \
		--force \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set020-infection dump-autoload

	php fixtures/set020-infection/vendor/infection/infection/bin/infection \
		--coverage=dist/infection-coverage \
		> build/set020-infection/expected-output
	php build/set020-infection/vendor/infection/infection/bin/infection \
		--coverage=dist/infection-coverage \
		> build/set020-infection/output

	diff build/set020-infection/expected-output build/set020-infection/output

.PHONY: e2e_021
e2e_021:	## Run end-to-end tests for the fixture set 020 — Composer
e2e_021: bin/php-scoper.phar fixtures/set021-composer/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix --working-dir=fixtures/set021-composer \
		--output-dir=../../build/set021-composer \
		--force \
		--no-interaction \
		--stop-on-failure \
		--no-config
	composer --working-dir=build/set021-composer dump-autoload

	php fixtures/set021-composer/vendor/composer/composer/bin/composer licenses \
		--no-plugins \
		> build/set021-composer/expected-output
	php build/set021-composer/vendor/composer/composer/bin/composer licenses \
		--no-plugins \
		> build/set021-composer/output

	diff build/set021-composer/expected-output build/set021-composer/output

.PHONY: e2e_022
e2e_022:	## Run end-to-end tests for the fixture set 022 — Whitelist the project code with namespace whitelisting
e2e_022: bin/php-scoper.phar fixtures/set022/vendor
	$(PHPBIN) $(BOX) compile --working-dir fixtures/set022
	cp -R fixtures/set022/tests/ build/set022/tests/

	php build/set022/bin/greet.phar > build/set022/output

	diff fixtures/set022/expected-output build/set022/output

.PHONY: e2e_023
e2e_023:	## Run end-to-end tests for the fixture set 023 — Whitelisting a whole third-party component with namespace whitelisting
e2e_023: bin/php-scoper.phar fixtures/set023/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix --working-dir=fixtures/set023 \
		--output-dir=../../build/set023 \
		--force \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set023 dump-autoload

	php build/set023/main.php > build/set023/output
	diff fixtures/set023/expected-output build/set023/output

.PHONY: e2e_024
e2e_024:	## Run end-to-end tests for the fixture set 024 — Whitelisting user functions registered in the global namespace
e2e_024: bin/php-scoper.phar fixtures/set024/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set024 \
		--output-dir=../../build/set024 \
		--force \
		--no-interaction \
		--stop-on-failure \
		--no-config
	composer --working-dir=build/set024 dump-autoload

	php build/set024/main.php > build/set024/output
	diff fixtures/set024/expected-output build/set024/output

.PHONY: e2e_025
e2e_025:	## Run end-to-end tests for the fixture set 025 — Whitelisting a vendor function
e2e_025: bin/php-scoper.phar fixtures/set025/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set025 \
		--output-dir=../../build/set025 \
		--force \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set025 dump-autoload

	php build/set025/main.php > build/set025/output
	diff fixtures/set025/expected-output build/set025/output

.PHONY: e2e_026
e2e_026:	## Run end-to-end tests for the fixture set 026 — Whitelisting classes and functions with pattern matching
e2e_026: bin/php-scoper.phar fixtures/set026/vendor
	$(PHPBIN) $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set026 \
		--output-dir=../../build/set026 \
		--force \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set026 dump-autoload

	php build/set026/main.php > build/set026/output
	diff fixtures/set026/expected-output build/set026/output


.PHONY: e2e_027
e2e_027:	## Run end-to-end tests for the fixture set 027 — Laravel
e2e_027: bin/php-scoper.phar fixtures/set027-laravel/vendor
	php $(PHPSCOPER) add-prefix \
		--working-dir=fixtures/set027-laravel \
		--output-dir=../../build/set027-laravel \
		--no-config \
		--force \
		--no-interaction \
		--stop-on-failure
	composer --working-dir=build/set027-laravel dump-autoload --no-dev

	php build/set027-laravel/artisan -V > build/set027-laravel/output
	diff fixtures/set027-laravel/expected-output build/set027-laravel/output


.PHONY: tb
BLACKFIRE=blackfire
tb:		## Run Blackfire profiling
tb: bin/php-scoper.phar  vendor
	$(BLACKFIRE) --new-reference run $(PHPBIN) bin/php-scoper.phar add-prefix --output-dir=build/php-scoper --force --quiet

#
# Rules from files
#---------------------------------------------------------------------------

vendor: composer.lock
	export COMPOSER_ROOT_VERSION='0.9.99'; composer install
	unset "COMPOSER_ROOT_VERSION"
	touch $@

vendor/bamarni: composer.lock
	export COMPOSER_ROOT_VERSION='0.9.99'; composer install
	unset "COMPOSER_ROOT_VERSION"
	touch $@

bin/phpunit: composer.lock
	export COMPOSER_ROOT_VERSION='0.9.99'; composer install
	unset "COMPOSER_ROOT_VERSION"
	touch $@

vendor-bin/covers-validator/vendor: vendor-bin/covers-validator/composer.lock vendor/bamarni
	composer bin covers-validator install
	touch $@

fixtures/set005/vendor: fixtures/set005/composer.lock
	composer --working-dir=fixtures/set005 install
	touch $@

fixtures/set011/vendor: fixtures/set011/vendor
	composer --working-dir=fixtures/set011 dump-autoload
	touch $@

fixtures/set015/vendor: fixtures/set015/composer.lock
	composer --working-dir=fixtures/set015 install
	touch $@

fixtures/set016-symfony-finder/vendor: fixtures/set016-symfony-finder/composer.lock
	composer --working-dir=fixtures/set016-symfony-finder install
	touch $@

fixtures/set017-symfony-di/vendor: fixtures/set017-symfony-di/composer.lock
	composer --working-dir=fixtures/set017-symfony-di install
	touch $@

fixtures/set018-nikic-parser/vendor: fixtures/set018-nikic-parser/composer.lock
	composer --working-dir=fixtures/set018-nikic-parser install
	touch $@

fixtures/set019-symfony-console/vendor: fixtures/set019-symfony-console/composer.lock
	composer --working-dir=fixtures/set019-symfony-console install
	touch $@

fixtures/set020-infection/vendor: fixtures/set020-infection/composer.lock
	composer --working-dir=fixtures/set020-infection install
	touch $@

fixtures/set021-composer/vendor: fixtures/set021-composer/composer.lock
	composer --working-dir=fixtures/set021-composer install
	touch $@

fixtures/set022/vendor: fixtures/set022/composer.json
	composer --working-dir=fixtures/set022 update
	touch $@

fixtures/set023/vendor: fixtures/set023/composer.lock
	composer --working-dir=fixtures/set023 install
	touch $@

fixtures/set024/vendor: fixtures/set024/composer.lock
	composer --working-dir=fixtures/set024 install
	touch $@

fixtures/set025/vendor: fixtures/set025/composer.lock
	composer --working-dir=fixtures/set025 install
	touch $@

fixtures/set026/vendor:
	composer --working-dir=fixtures/set026 update
	touch $@

fixtures/set027-laravel/vendor: fixtures/set027-laravel/composer.lock
	composer --working-dir=fixtures/set027-laravel install --no-dev
	touch $@

composer.lock: composer.json
	@echo composer.lock is not up to date.

vendor-bin/covers-validator/composer.lock: vendor-bin/covers-validator/composer.json
	@echo covers-validator composer.lock is not up to date

fixtures/set005/composer.lock: fixtures/set005/composer.json
	@echo fixtures/set005/composer.lock is not up to date.

fixtures/set015/composer.lock: fixtures/set015/composer.json
	@echo fixtures/set015/composer.lock is not up to date.

fixtures/set016-symfony-finder/composer.lock: fixtures/set016-symfony-finder/composer.json
	@echo fixtures/set016-symfony-finder/composer.lock is not up to date.

fixtures/set017-symfony-di/composer.lock: fixtures/set017-symfony-di/composer.json
	@echo fixtures/set017-symfony-di/composer.lock is not up to date.

fixtures/set018-nikic-parser/composer.lock: fixtures/set018-nikic-parser/composer.json
	@echo fixtures/set018-nikic-parser/composer.lock is not up to date.

fixtures/set019-symfony-console/composer.lock: fixtures/set019-symfony-console/composer.json
	@echo fixtures/set019-symfony-console/composer.lock is not up to date.

fixtures/set020-infection/composer.lock: fixtures/set020-infection/composer.json
	@echo fixtures/set020-infection/composer.lock is not up to date.

fixtures/set021-composer/composer.lock: fixtures/set021-composer/composer.json
	@echo fixtures/set021-composer/composer.lock is not up to date.

fixtures/set023/composer.lock: fixtures/set023/composer.json
	@echo fixtures/set023/composer.lock is not up to date.

fixtures/set024/composer.lock: fixtures/set024/composer.json
	@echo fixtures/set024/composer.lock is not up to date.

fixtures/set025/composer.lock: fixtures/set025/composer.json
	@echo fixtures/set025/composer.lock is not up to date.

fixtures/set027-laravel/composer.lock: fixtures/set027-laravel/composer.json
	@echo fixtures/set027-laravel/composer.lock is not up to date.

bin/php-scoper.phar: bin/php-scoper src vendor scoper.inc.php box.json
	$(BOX) compile
	touch $@

box.json: box.json.dist
	cat box.json.dist | sed -E 's/\"key\": \".+\",//g' | sed -E 's/\"algorithm\": \".+\",//g' > box.json

COVERS_VALIDATOR=$(PHPBIN) vendor-bin/covers-validator/bin/covers-validator
clover.xml: src
	$(COVERS_VALIDATOR)
	phpdbg -qrr -d zend.enable_gc=0 $(PHPUNIT) \
		--coverage-html=dist/coverage \
		--coverage-text \
		--coverage-clover=clover.xml \
		--coverage-xml=dist/infection-coverage/coverage-xml \
		--log-junit=dist/infection-coverage/phpunit.junit.xml
