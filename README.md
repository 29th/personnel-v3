# Personnel

Status: Work in Progress

A rewrite of the [personnel management system](https://github.com/29th/personnel) for the [29th Infantry Division](http://29th.org) in [Ruby on Rails](https://rubyonrails.org).

## Local development

### Prerequisites
- [Docker](https://docs.docker.com/install/)

### Database snapshot
To load your database with data, you'll need to put a database dump (`.sql`) file in the `db/dump/`
directory. You can get this from another team member, or you can export a dump of the production
database by SSHing into the production server and running:

```
mysqldump -u <username> -p <database> > dump.sql
```

Put the `dump.sql` file in the `db/dump/` directory.

### Steam web api key
Users sign in to the application via Steam. To enable this functionality, you'll need to pass it
a Steam Web API Key. You can get one by [filling out this form](http://steamcommunity.com/dev/apikey).
Once you have it, copy `.env.sample` to `.env` and add your key to it.

### Running the application

```
docker-compose up
```

To view your app, go to `http://localhost:3000`.

Exit using CTRL+C and stop the containers using `docker-compose down`.

To issue rails commands, ssh into the app container using:

```
docker-compose exec app bash
```

To open phpMyAdmin, browse to `http://localhost:8081`. Username is `root` and password is `pwd`.
