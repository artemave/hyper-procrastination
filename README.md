## Description

Compares speed of different server-side tech in a following test scenario: request a large JSON file 200 times concurrently, then reduce each response to some value.

Each push to master triggers a comparison test that runs on a [dedicated cloud server](https://www.vultr.com/pricing/dedicatedcloud/) (2 cpus, 8Gb ram). The results are then published here:

[![Results](https://s3.amazonaws.com/hyper-procrastination/results.svg)](https://travis-ci.org/artemave/hyper-procrastination)

## Try this at home

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
- `results.json` should ideally look like this: `{"request":4,"parse":3,"process":22,"total":42}`, but at the very list contain `total:` time in seconds.

You may find `docker-compose start nginx` useful in development. It starts nginx and binds it onto the host port 8889. 

### Test spec

Each thread/worker/whatnot should independently request `cityloads.json` and print out the number of unique `properties.FROM_ST` values from `features` array.
