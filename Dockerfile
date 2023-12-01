FROM ruby:3.1.2

ENV NODE_MAJOR_VERSION 16

# install node.js, yarn and imagemagick
RUN curl --silent --show-error --location --retry 5 --retry-connrefuse --retry-delay 4 https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash - \
  && apt-get update \
  && apt-get install -y --quiet --no-install-recommends \
  mariadb-client \
  nodejs \
  sqlite3 \
  time \
  build-essential \
  imagemagick \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate --size 0 /var/log/*log \
  && npm install --global yarn

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --jobs 4

COPY package.json yarn.lock ./
RUN time yarn install --frozen-lockfile

COPY . ./
RUN time rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=$(openssl rand -hex 32) PRECOMPILE=true

RUN groupadd ruby --gid 3000 \
  && useradd --create-home --uid 3000 --no-user-group ruby \
  && usermod --gid ruby ruby \
  && chmod -R 777 tmp log

USER ruby

CMD ["rails", "server", "-b", "0.0.0.0"]
