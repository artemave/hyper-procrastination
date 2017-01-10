all:
	docker run --rm -v $(PWD):/app -w /app -e GOOS=`uname -s | tr -t [A-Z] [a-z]` -e GOARCH=amd64 golang:1.7 go build -v

# requires `docker-compose start nginx` first
run:
	docker run --rm -v $(PWD):/app -e NGINX_HOST=nginx -w /app --network=nodevsruby_default golang:1.7 go run get_and_parse_big_json.go
