FROM ruby:2.0

MAINTAINER  Cyprien DIOT <wixyvir@gmail.com>

RUN mkdir -p /app
WORKDIR /app
COPY . /app
RUN bundle install
WORKDIR /root/
ENTRYPOINT ["/app/bin/gem2rpm"]
