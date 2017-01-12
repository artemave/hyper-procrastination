## Description

Compares speed of different server-side tech in a following test scenario: request a large JSON file 200 times concurrently, then reduce each response to some value.

Just to give you an idea, on my machine (2015 MBP 13" Core i7) the numbers are as follows:

| Tech          | Request time | Parsing time | Processing time | Total time |
| ------------- | -----------  | ------------ | --------------- | ---------- |
| Go 1.7        |              |              |                 | 14 s       |
| Node 7.4      |              |              |                 | 23 s       |
| Ruby 2.4      | 4.6s         | 34.9s        | 2.25s           | 42.55 s    |

## See for yourself

Requires [docker-compose](https://docs.docker.com/compose/) and I'd say at least 4Gb of ram (may need docker settings change). Then:

```
docker-compose run go # node ruby
```

## Add more tech

### Rules

- all files go in a subfolder named after the tech
- test JSON - `cityloads.json` - should be requested over HTTP from the Nginx container bundled in this project
- `docker-compose start tech` should run the test
- local environment should not require presence of tech 
- no caching

You may find `docker-compose start nginx` useful in development. It starts nginx and binds it onto the host port 8889. 

### Test spec

Each thread/worker/whatnot should independently request `cityloads.json` and print out the number of unique `properties.FROM_ST` values from `features` array.
