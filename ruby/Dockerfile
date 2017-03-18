FROM ruby:2.4

WORKDIR /app

ADD Gemfile* ./
RUN bundle install

ENV NGINX_HOST=nginx

VOLUME /app

ADD . .
CMD [ "ruby", "get_and_parse_big_json.rb" ]
