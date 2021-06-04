FROM ruby:2.6.5-alpine

WORKDIR /action

RUN apk add --update nodejs

COPY Gemfile* ./

RUN bundle config --global frozen 1 \
  && bundle config set without development test \
  && bundle install --without development test

COPY lib /action/lib
COPY bin /action/bin

CMD ["ruby", "/action/lib/index.rb"]
