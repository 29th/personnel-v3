FROM ruby:2.6.5

ENV NODE_VERSION 12

# add non-root user named web
RUN groupadd --gid 1000 web \
  && useradd --uid 1000 --gid web --shell /bin/bash --create-home web

# install node.js and yarn
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get install -y --quiet --no-install-recommends \
    mariadb-client \
    nodejs \
    sqlite3 \
    yarn \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# USER web
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
