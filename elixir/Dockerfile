FROM elixir:1.4

WORKDIR /app
ADD . .
RUN mix local.hex --force && mix local.rebar --force && mix deps.get && mix compile

VOLUME ./results
ENV NGINX_HOST=nginx

CMD [ "mix",  "run", "-e", "GetAndParseBigJSON.main" ]
