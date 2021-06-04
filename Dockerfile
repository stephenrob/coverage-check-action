FROM ruby:2.6.5-alpine

WORKDIR /action

RUN apk add --update nodejs

COPY Gemfile* /action

RUN bundle install

COPY lib /action/lib
COPY bin /action/bin

CMD ["ruby", "/action/lib/index.rb"]
