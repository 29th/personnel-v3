FROM ruby:2.5.1

# node.js
ENV NODE_VERSION 8
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get install -qq -y build-essential nodejs yarn --fix-missing --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /personnel
WORKDIR /personnel
COPY Gemfile /personnel/Gemfile
COPY Gemfile.lock /personnel/Gemfile.lock
RUN bundle install
COPY . /personnel
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server"]
