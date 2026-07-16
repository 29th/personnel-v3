# Personnel

A rewrite of the [personnel management system](https://github.com/29th/personnel) for the [29th Infantry Division](http://29th.org) in [Ruby on Rails](https://rubyonrails.org).

## Local development

### Prerequisites
- [Docker](https://docs.docker.com/install/)

### Database
With a MySQL server running (e.g. `docker compose up db`), create the schema and
load it with generated sample data:

```
bin/rails db:prepare db:seed
```

Seeding takes about a minute and produces a realistic, PII-free dataset modelled
on production: the active unit hierarchy, ~335 members with careers (enlistments,
promotions, awards, qualifications, discharges) and three years of events and
attendance. Real reference data (ranks, positions, awards, abilities, AIT
standards) lives in `db/seeds/data/`; everything personal is fake. To sign in,
use the navbar's **Sign in (dev)** button with one of the `forum_member_id`
values printed at the end of seeding (e.g. the Regiment Commander for full
admin access). To start over, run `bin/rails db:reset`.

#### Alternative: database snapshot
If you're a team member and need real data, you can instead put a database dump
(`.sql`) file in the `db/dump/` directory (Docker imports it on first startup).
You can get this from another team member, or you can export a dump of the
production database by SSHing into the production server and running:

```
mysqldump -u <username> -p <database> > dump.sql
```

Put the `dump.sql` file in the `db/dump/` directory. Note dumps contain personal
data (names, emails, Steam IDs, IPs) and must never be committed or shared
outside the team.

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
