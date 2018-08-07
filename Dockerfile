FROM ruby:2.3.1

# node.js
ENV NODE_VERSION 8
RUN apt-get update \
  && apt-get install -y build-essential \
  && set -x \
  && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && apt-get install -y nodejs

RUN mkdir /personnel
WORKDIR /personnel
COPY Gemfile /personnel/Gemfile
COPY Gemfile.lock /personnel/Gemfile.lock
RUN bundle install
COPY . /personnel
