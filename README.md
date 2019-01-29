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

#### Upgrading the database snapshot
At the time of this writing, the production database uses MySQL v5.6, so you'll need to upgrade the
dump you created to MySQL v8.0 to be compatible with this application. This part is a bit of a pain,
but once we upgrade the production database to v8.0 this won't be necessary.

1. In `docker-compose.yml`, change the mysql version from `mysql:8` to `mysql:5.7`
2. Run `docker-compose up db`
3. Run `docker-compose run db mysql_upgrade -u root -p -h db` (password `pwd`) to upgrade the database to v5.7
4. Run `docker-compose run db mysqldump -u root -p -h db > dump-5.7.sql` to export the upgraded database
5. Run `docker-compose down`
6. In `docker-compose.yml`, change the mysql version back to `mysql:8`
7. Run `docker-compose up db`
8. Run `docker-compose run db mysql_upgrade -u root -p -h db` (password `pwd`) to upgrade the database to v8
9. Run `docker-compose run db mysqldump -u root -p -h db > dump-8.sql` to export the upgraded database
10. Run `docker-compose down`
11. Place `dump-8.sql` in the `db/dump/` directory. You can delete the other files.

### Secret key
In order for the application to decrypt `config/credentials.yml.enc`, you'll need to get the `master.key`
file from another team member and place it into the `config/` directory.

### Running the application

```
docker-compose up
```

To view your app, go to `http://localhost:3000`.

Exit using CTRL+C and stop the containers using `docker-compose down`.

To issue rails commands, use:

```
docker-compose run app bin/rails <cmd>
```

To open phpMyAdmin, browse to `http://localhost:8081`. Username is `root` and password is `pwd`.
