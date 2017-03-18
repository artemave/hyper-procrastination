## Description

Compares speed of different server-side tech in a following test scenario: request a large JSON file 200 times concurrently, then reduce each response to some value.

Just to give you an idea, on my machine (2015 MBP 13" Core i7) the numbers are as follows:

| Tech          | Request time | Parsing time | Processing time | Total time |
| ------------- | -----------  | ------------ | --------------- | ---------- |
| Node 7.4      | ???          |  8.32s       | 0.64s           | 13.84s     |
| Go 1.7        | 2.38s        | 10.82s       | 0.09s           | 14.63s     |
| Ruby 2.4      | 4.6s         | 34.9s        | 2.25s           | 42.55s     |

## See for yourself

Requires [docker-compose](https://docs.docker.com/compose/) and I'd say at least 4Gb of ram (may need docker settings change). Then:

```
docker-compose run go # node ruby
```

## Add more tech

### Rules

- all files go in a subfolder named after the new tech
- test JSON - `cityloads.json` - should be requested over HTTP from the Nginx container bundled in this project
- `docker-compose start tech` should run the test
- local development environment should not require presence of tech 
- no caching
- the results should be stored in `results.json` and mapped as volume in docker compose
- `results.json` should look like this: `{"request":4574.575242000001,"parse":34947.504102000006,"process":2260.828687999999,"total":42772.572214}`

You may find `docker-compose start nginx` useful in development. It starts nginx and binds it onto the host port 8889. 

### Test spec

Each thread/worker/whatnot should independently request `cityloads.json` and print out the number of unique `properties.FROM_ST` values from `features` array.
