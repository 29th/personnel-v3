# Personnel

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

### Running the application
Use [29th/personnel](https://github.com/29th/personnel) to run this application,
as that includes the reverse proxy that sits in front of it. You can run it
without the other applications using:

```
docker compose up v3 reverse-proxy db-personnel
```

Alternatively, if you want to run v3 standalone (without the reverse proxy), and
without docker, you can run it locally if you have Ruby installed:

```
rails server
```

To override settings, like discourse base url, api keys, etc., create `config/settings.local.yml` and populate it with the keys you want to override from `config/settings/development.yml`.

### Notes
* Application performance monitoring sponsored by [AppSignal](https://www.appsignal.com/)
