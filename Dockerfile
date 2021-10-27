ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/network-access-control-integration-tests:ruby-3-0-2-alpine3-14


RUN apk --no-cache add \
      wpa_supplicant openssl \
      ruby ruby-rdoc ruby-bundler ruby-ffi mariadb-connector-c-dev \
      ruby-dev make gcc libc-dev bash

COPY Gemfile Gemfile.lock .ruby-version ./
RUN gem update --system && gem install bundler
RUN bundle check || bundle install

COPY . .

CMD ["sleep", "infinity"]
