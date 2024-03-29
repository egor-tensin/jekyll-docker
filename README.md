jekyll-docker
=============

[![CI](https://github.com/egor-tensin/jekyll-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/egor-tensin/jekyll-docker/actions/workflows/ci.yml)

**Archiving this because I no longer think this approach is valid.
Just using rbenv and installing dependencies there seems like a much saner option.**

----

Develop your Jekyll project in a Docker container, without installing all the
dependencies on the host.
Or don't.

| Feature                | Command
| ---------------------- | ----------------------------------------------
| Install [ruby-install] | `make ruby-install && make ruby-install/clean`
| Install Ruby           | `make ruby`
| Install [chruby]       | `make chruby && make chruby/clean`
| Install [Bundler]      | `make bundler`
| Install dependencies   | `make dependencies`
| Run [Jekyll]           | `make jekyll/serve`
| Run Jekyll in Docker | `make docker/up`

[ruby-install]: https://github.com/postmodern/ruby-install
[chruby]: https://github.com/postmodern/chruby
[Bundler]: https://bundler.io/
[Jekyll]: https://jekyllrb.com/

| Parameter            | Default   | Description
| -------------------- | --------- | --------------------------------------------------
| PROJECT_DIR          | ..        | Jekyll project directory
| RUBY_INSTALL_VERSION | 0.8.5     | ruby-install version
| RUBY_VERSION         | 3.1.2     | Ruby version
| CHRUBY_VERSION       | 0.3.9     | chruby version
| PREFIX               | ~/.local/ | Installation directory for ruby-install and chruby

Set parameter values by passing them to make, i.e.

    make ruby RUBY_VERSION=2.7.0

Examples
--------

### Jekyll in Docker

    make docker/up PROJECT_DIR=../jekyll-project/

This builds two images: `jekyll_base` and `jekyll_project`, and runs a
container, which mounts PROJECT_DIR, and runs Jekyll there.

To rebuild the images (i.e. when you bump dependencies), run

    make docker/build PROJECT_DIR=../jekyll-project/

Bring everything down:

    make docker/down

### Jekyll on the host

    make ruby-install
    make ruby-install/clean
    make ruby
    make chruby
    make chruby/clean
    make bundler
    make dependencies PROJECT_DIR=../jekyll-project/
    make jekyll/serve PROJECT_DIR=../jekyll-project/

Some of these might not work on the first try (you'd need to install some
native dependencies for your gems, use `sudo`, etc.).

License
-------

Distributed under the MIT License.
See [LICENSE.txt] for details.

[LICENSE.txt]: LICENSE.txt
