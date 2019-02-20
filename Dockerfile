FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y install git unzip ruby ruby-dev \
        libxml2-dev libxslt-dev libcurl4-openssl-dev \
        build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev

RUN gem install bundler --no-rdoc --no-ri
RUN gem install bosh_cli -v 1.3177.0 --no-rdoc --no-ri


RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app
RUN bundle install
RUN gem build *.gemspec && gem install *.gem --no-document
