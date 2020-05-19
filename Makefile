SHELL := bash
.SHELLFLAGS := -e -o pipefail -c
.DEFAULT_GOAL := jekyll/serve
.DELETE_ON_ERROR:
.SUFFIXES:

empty :=
space := $(empty) $(empty)
comma := ,

escape = $(subst ','\'',$(1))

makefile_dir := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# Jekyll project is in the parent directory by default.
PROJECT_DIR ?= $(abspath $(dir $(makefile_dir))/..)
RUBY_INSTALL_VERSION ?= 0.7.0
RUBY_VERSION ?= 2.6.5
CHRUBY_VERSION ?= 0.3.9
PREFIX ?= $(HOME)/.local

ruby_install_url := https://github.com/postmodern/ruby-install/archive/v$(RUBY_INSTALL_VERSION).tar.gz
ruby_install_archive := $(makefile_dir)/ruby-install-$(RUBY_INSTALL_VERSION).tar.gz
ruby_install_dir := $(makefile_dir)/ruby-install-$(RUBY_INSTALL_VERSION)

chruby_url := https://github.com/postmodern/chruby/archive/v$(CHRUBY_VERSION).tar.gz
chruby_archive := $(makefile_dir)/chruby-$(CHRUBY_VERSION).tar.gz
chruby_dir := $(makefile_dir)/chruby-$(CHRUBY_VERSION)

chruby_sh := $(PREFIX)/share/chruby/chruby.sh
auto_sh := $(PREFIX)/share/chruby/auto.sh

.PHONY: ruby-install
ruby-install:
	wget -O '$(call escape,$(ruby_install_archive))' '$(call escape,$(ruby_install_url))'
	tar -xzvf '$(call escape,$(ruby_install_archive))' -C '$(call escape,$(makefile_dir))'
	cd -- '$(call escape,$(ruby_install_dir))' && make install 'PREFIX=$(call escape,$(PREFIX))'

.PHONY: ruby-install/uninstall
ruby-install/uninstall:
	cd -- '$(call escape,$(ruby_install_dir))' && make uninstall 'PREFIX=$(call escape,$(PREFIX))'

.PHONY: ruby-install/clean
ruby-install/clean:
	rm -rf -- '$(call escape,$(ruby_install_archive))' '$(call escape,$(ruby_install_dir))'

.PHONY: ruby
ruby:
	ruby-install -j2 --cleanup ruby '$(call escape,$(RUBY_VERSION))'

.PHONY: chruby
chruby:
	wget -O '$(call escape,$(chruby_archive))' '$(call escape,$(chruby_url))'
	tar -xzvf '$(call escape,$(chruby_archive))' -C '$(call escape,$(makefile_dir))'
	cd -- '$(call escape,$(chruby_dir))' && $(MAKE) install 'PREFIX=$(call escape,$(PREFIX))'

.PHONY: chruby/uninstall
chruby/uninstall:
	cd -- '$(call escape,$(chruby_dir))' && $(MAKE) uninstall 'PREFIX=$(call escape,$(PREFIX))'

.PHONY: chruby/clean
chruby/clean:
	rm -rf -- '$(call escape,$(chruby_archive))' '$(call escape,$(chruby_dir))'

define chruby_source
if [ -n "$$BASH_VERSION" ] || [ -n "$$ZSH_VERSION" ]; then
    [ -r '$(call escape,$(chruby_sh))' ] && source '$(call escape,$(chruby_sh))'
    [ -r '$(call escape,$(auto_sh))'   ] && source '$(call escape,$(auto_sh))'
fi
endef
export chruby_source

.PHONY: chruby/.bashrc
chruby/.bashrc:
	echo "$$chruby_source" >> ~/.bashrc

.PHONY: chruby/profile.d
chruby/profile.d:
	echo "$$chruby_source" > /etc/profile.d/chruby.sh

.PHONY: chruby/profile.d/clean
chruby/profile.d/clean:
	rm -f -- /etc/profile.d/chruby.sh

chruby := . '$(call escape,$(chruby_sh))' && chruby 'ruby-$(call escape,$(RUBY_VERSION))'
project_chruby := cd -- '$(call escape,$(PROJECT_DIR))' && $(chruby)

bundle := $(project_chruby) && bundle

.PHONY: bundler
bundler:
	$(chruby) && gem install --norc bundler

.PHONY: dependencies
dependencies:
	$(bundle) install --jobs=2 --retry=3

.PHONY: dependencies/update
dependencies/update:
	$(bundle) update --jobs=2

.PHONY: deps
deps: dependencies

.PHONY: deps/update
deps/update: dependencies/update

# List of --config files in alphabetical order.
jekyll_configs := $(shell cd -- '$(call escape,$(PROJECT_DIR))' && find . -mindepth 1 -maxdepth 1 -type f -name '_config*.yml' -print | sort)
jekyll_configs := $(subst $(space),$(comma),$(jekyll_configs))

jekyll_opts := --drafts --config '$(call escape,$(jekyll_configs))'
jekyll := $(bundle) exec jekyll

.PHONY: jekyll/build
jekyll/build:
	$(jekyll) build $(jekyll_opts)

.PHONY: jekyll/serve
jekyll/serve:
	$(jekyll) serve $(jekyll_opts) --host 0.0.0.0

JEKYLL_UID ?= $(shell id -u)
JEKYLL_GID ?= $(shell id -g)
export JEKYLL_UID JEKYLL_GID

docker_compose := cd -- '$(call escape,$(makefile_dir))' && PROJECT_DIR='$(call escape,$(abspath $(PROJECT_DIR)))' docker-compose

.PHONY: docker/build
docker/build:
	$(docker_compose) build --force-rm --build-arg 'JEKYLL_UID=$(call escape,$(JEKYLL_UID))' --build-arg 'JEKYLL_GID=$(call escape,$(JEKYLL_GID))'

.PHONY: docker/up
docker/up:
	$(docker_compose) up -d project

.PHONY: docker/logs
docker/logs:
	$(docker_compose) logs

.PHONY: docker/down
docker/down:
	$(docker_compose) down -v

.PHONY: docker/shell
docker/shell:
	$(docker_compose) exec project bash --login

.PHONY: docker/clean
docker/clean:
	docker system prune -a -f --volumes
