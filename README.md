jekyll-docker
=============

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
| RUBY_INSTALL_VERSION | 0.7.0     | ruby-install version
| RUBY_VERSION         | 2.6.5     | Ruby version
| CHRUBY_VERSION       | 0.3.9     | chruby version
| PREFIX               | ~/.local/ | Installation directory for ruby-install and chruby

Set parameter values by passing them to make, i.e.

    make ruby RUBY_VERSION=2.7.0

Examples
--------

1. Set up an environment and run Jekyll locally:

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

2. Run Jekyll in Docker:

       make docker/up PROJECT_DIR=../jekyll-project/

   This builds two images: `jekyll_base` and `jekyll_project`, and runs a
   container, which binds PROJECT_DIR, and runs Jekyll there.

   To rebuild the images (i.e. when you bump dependencies), run

       make docker/build PROJECT_DIR=../jekyll-project/

   To bring everything down,

       make docker/down
    
Notes
-----

This project was supposed to be included as a submodule in my Jekyll projects'
repositories.
I would then `cd` to Jekyll project's directory and run something like

    make -f jekyll-docker/Makefile docker/up

and I'd get a Docker container running Jekyll, without actually bothering to
install everything locally.
This goal was achieved, but I also noticed that "out-of-tree" builds were
actually possible, hence the introduction of the PROJECT_DIR parameter, and the
slight crazyness with the two separate images.