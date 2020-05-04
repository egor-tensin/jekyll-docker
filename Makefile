SHELL := bash
.SHELLFLAGS := -e -o pipefail -c
.DEFAULT_GOAL := jekyll/serve
.DELETE_ON_ERROR:
.SUFFIXES:

makefile_dir := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

PROJECT_DIR := $(abspath $(dir $(makefile_dir))/..)
RUBY_INSTALL_VERSION ?= 0.7.0
RUBY_VERSION ?= 2.6.5
CHRUBY_VERSION ?= 0.3.9
PREFIX ?= $(HOME)/.local

chruby_url := https://github.com/postmodern/chruby/archive/v$(CHRUBY_VERSION).tar.gz
chruby_archive := $(makefile_dir)/chruby-$(CHRUBY_VERSION).tar.gz
chruby_dir := $(makefile_dir)/chruby-$(CHRUBY_VERSION)

chruby_sh := $(PREFIX)/share/chruby/chruby.sh
auto_sh := $(PREFIX)/share/chruby/auto.sh

ruby_install_url := https://github.com/postmodern/ruby-install/archive/v$(RUBY_INSTALL_VERSION).tar.gz
ruby_install_archive := $(makefile_dir)/ruby-install-$(RUBY_INSTALL_VERSION).tar.gz
ruby_install_dir := $(makefile_dir)/ruby-install-$(RUBY_INSTALL_VERSION)
.PHONY: chruby
chruby:
	wget -O '$(chruby_archive)' '$(chruby_url)'
	tar -xzvf '$(chruby_archive)' -C '$(makefile_dir)'
	cd -- '$(chruby_dir)' && $(MAKE) install 'PREFIX=$(PREFIX)'

.PHONY: chruby/uninstall
chruby/uninstall:
	cd -- '$(chruby_dir)' && $(MAKE) uninstall 'PREFIX=$(PREFIX)'

.PHONY: chruby/clean
chruby/clean:
	rm -rf -- '$(chruby_archive)' '$(chruby_dir)'

define chruby_profile_d
if [ -n "$$BASH_VERSION" ] || [ -n "$$ZSH_VERSION" ]; then
    [ -r '$(chruby_sh)' ] && source '$(chruby_sh)'
    [ -r '$(auto_sh)'   ] && source '$(auto_sh)'
fi
endef
export chruby_profile_d

.PHONY: chruby/profile.d
chruby/profile.d:
	echo "$$chruby_profile_d" > /etc/profile.d/chruby.sh

.PHONY: chruby/profile.d/clean
chruby/profile.d/clean:
	rm -f -- /etc/profile.d/chruby.sh

.PHONY: ruby-install
ruby-install:
	wget -O '$(ruby_install_archive)' '$(ruby_install_url)'
	tar -xzvf '$(ruby_install_archive)' -C '$(makefile_dir)'
	cd -- '$(ruby_install_dir)' && make install 'PREFIX=$(PREFIX)'

.PHONY: ruby-install/uninstall
ruby-install/uninstall:
	cd -- '$(ruby_install_dir)' && make uninstall 'PREFIX=$(PREFIX)'

.PHONY: ruby-install/clean
ruby-install/clean:
	rm -rf -- '$(ruby_install_archive)' '$(ruby_install_dir)'

.PHONY: ruby
ruby:
	ruby-install -j2 --cleanup ruby '$(RUBY_VERSION)'

chruby := cd -- '$(PROJECT_DIR)' && . '$(chruby_sh)' && chruby 'ruby-$(RUBY_VERSION)'

.PHONY: bundler
bundler:
	$(chruby) && gem install --norc bundler

.PHONY: dependencies
dependencies:
	$(chruby) && bundle install --jobs=2 --retry=3

.PHONY: deps
deps: dependencies

jekyll := $(chruby) && bundle exec jekyll

.PHONY: jekyll/build
jekyll/build:
	$(jekyll) build --config _config.yml,_config_dev.yml

.PHONY: jekyll/serve
jekyll/serve:
	$(jekyll) serve --host 0.0.0.0 --config _config.yml,_config_dev.yml

docker_compose := cd -- '$(makefile_dir)' && docker-compose

.PHONY: docker/build
docker/build:
	$(docker_compose) build --force-rm

.PHONY: docker/up
docker/up:
	$(docker_compose) up -d

.PHONY: docker/down
docker/down:
	$(docker_compose) down -v

.PHONY: docker/shell
docker/shell:
	$(docker_compose) exec serve bash --login

.PHONY: docker/clean
docker/clean:
	docker system prune -a -f --volumes
