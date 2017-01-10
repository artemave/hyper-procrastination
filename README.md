## Description

Compares speed of different server-side tech in a following test scenario: request a large JSON file 200 times concurrently, then reduce each response to some value.

Just to give you an idea, on my machine (2015 MBP 13" Core i7), with docker allowed to gobble up to 6Gb or ram, the numbers are as follow:

| Tech | Time Spent    |
| -------------  | ------------- |
| Go 1.7         | 14 seconds    |
| Node 7.4       | 23 seconds    |
| Ruby 2.4       | 52 seconds    |

## See for yourself

Requires [docker-compose](https://docs.docker.com/compose/) and I'd say at least 4Gb of ram (may need docker settings change). Then:

```
docker-compose run go # node ruby
```
