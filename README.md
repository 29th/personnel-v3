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

1. Put the v5.6 database dump in the `db/dump/` directory
2. Load it into a MySQL v5.7 container by running `docker run --name db_upgrade_5.7 --rm -e MYSQL_DATABASE=personnel_development -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -v $(pwd)/db/dump:/docker-entrypoint-initdb.d mysql:5.7`
3. In a new terminal, upgrade the data to v5.7 by running `docker exec -it db_upgrade_5.7 mysql_upgrade personnel_development`
4. Manually correct the date issue by running `docker exec -it db_upgrade_5.7 mysql personnel_development -e "update assignments set end_date = null where cast(end_date as char(20)) = '0000-00-00'; update assignments set start_date = null where cast(start_date as char(20)) = '0000-00-00'"`
5. Export the upgraded database by running `docker exec -it db_upgrade_5.7 mysqldump personnel_development > dump-57.sql`
6. Stop the MySQL v5.7 container by running `docker stop db_upgrade_5.7`
7. Replace the v5.6 database dump in the `db/dump` directory with the v5.7 one you just exported
8. Load it into a MySQL v8 container by running `docker run --name db_upgrade_8 --rm -e MYSQL_DATABASE=personnel_development -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -v $(pwd)/db/dump:/docker-entrypoint-initdb.d mysql:8`
9. In a new terminal, upgrade the data to v8 by running `docker exec -it db_upgrade_8 mysql_upgrade personnel_development`
10. Export the upgraded database by running `docker exec -it db_upgrade_8 mysqldump personnel_development > dump-8.sql`
11. Stop the MySQL v8 container by running `docker stop db_upgrade_8`
12. Replace the v5.7 database dump in the `db/dump` directory with the v8 one you just exported

### Secret key
In order for the application to decrypt `config/credentials.yml.enc`, you'll need to get the `master.key`
file from another team member and place it into the `config/` directory.

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
