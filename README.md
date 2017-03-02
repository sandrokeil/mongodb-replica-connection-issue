# MongoDB Replica Issue
This repo tries to reproduce the [Intermittent error: MongoConnectionException:No suitable servers found (`serverselectiontryonce` set): Server closed connection. calling ismaster on 'x.x.x.x:27017'](https://github.com/mongodb/mongo-php-driver/issues/532)

I can reproduce the error with this setup. You find the logs of a test run in [log.txt](log.txt) file. 

Also take a look at the [`php.txt`](php.txt). The test has finished at `Do 2. Mär 12:06:53 CET 2017` and now look at the 
last lines of `php.txt` from `02-Mar-2017 11:08:49`. There are multiple success requests and the sometimes the `not master` 
error occurs. The `index.php` writes and reads from MongoDB. Simply reload the page multiple times after the test has finished.
There error still exists.

Why are some requests are successfully and some failed? I guess it's a PHP-FPM static child caching (or even opcache) issue.

With this repo we have a nice playground to investigate this issue further.

## Installation
Install [Docker >= 1.13](https://docs.docker.com/engine/installation/linux/ubuntu/) 
and [Docker Compose >= 1.11](https://docs.docker.com/compose/install/). 

Install now Composer dependencies with

```
$ docker run --rm -it --volume $(pwd):/app prooph/composer:7.1 install
```

## Run test
The [`index.php`](public/index.php) uses two different MongoDB connections with `connectTimeoutMS=2000`.

* One with `readPreference=primaryPreferred` for inserts
* Second with `readPreference=secondaryPreferred` for reads

Simply run:

```
$ . start.sh | tee log.txt
```

To watch PHP logs in realtime run in another terminal 

```
$ docker-compose logs -f --tail=20 php
```

You see the output and it is also written to the `log.txt` file. Search in the log file for `MongoConnectionException` to find the error.

You can also browse the website [http://localhost:8080/](http://localhost:8080/). 

If the test has finished reload this page some times to see the `MongoConnectionException`.

## Check status manually
To manually check MongoDB Replica Status use one of

```
$ docker-compose exec mongodb0 sh status.sh
$ docker-compose exec mongodb1 sh status.sh
$ docker-compose exec mongodb2 sh status.sh
```

## Cleanup
Simply run:

```
$ . down.sh
```
