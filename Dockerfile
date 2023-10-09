FROM ruby:3.2.2-alpine3.18

RUN apk --no-cache add \
      wpa_supplicant openssl \
      ruby ruby-rdoc ruby-bundler ruby-ffi mariadb-connector-c-dev \
      ruby-dev make gcc libc-dev bash

COPY Gemfile Gemfile.lock .ruby-version ./
RUN gem update --system && gem install bundler
RUN bundle check || bundle install

COPY . .

CMD ["sleep", "infinity"]
