# Personnel

Status: Work in Progress

A rewrite of the [personnel management system](https://github.com/29th/personnel) for the [29th Infantry Division](http://29th.org) in [Ruby on Rails](https://rubyonrails.org).

## Local development

First, export a copy of the production database and copy it into the `db/dump/` directory using:

```
mysqldump -u <username> -p <database> > dump.sql
```

With [Docker](https://docs.docker.com/install/) installed, clone this repository and run:

```
docker-compose up
```

To view your app, go to `http://localhost:3000`.

Exit using CTRL+C and stop the containers using `docker-compose down`.
Every once in a while you may get an error while running `up` that there's already a server running.
That occurs when it doesn't exit properly. Just delete `tmp/pids/server.pid` and try again.

To issue rails commands, use:

```
docker-compose run app bin/rails <cmd>
```

To open phpMyAdmin, browse to `http://localhost:8081`. Username is `root` and password is `pwd`.
