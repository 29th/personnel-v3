FROM ruby:2.3.1

# node.js
ENV NODE_VERSION 8
RUN apt-get update \
  && apt-get install -y build-essential \
  && set -x \
  && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && apt-get install -y nodejs

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
