#!/bin/sh

set -e -x

cd generator

export GEM_HOME=$HOME/.gems
export PATH=$GEM_HOME/bin:$PATH

gem install bundler --no-document

bundle install
bundle exec rspec
gem build *.gemspec


gm *.gem ../run-build
