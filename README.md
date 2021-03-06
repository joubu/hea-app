hea-app
=======

This website intends to display koha community usage statistics. Data are collected from installed koha if librarian wants anonymously or not.

Data collected is available under the CC-BY-SA 4.0 License


## External references

 * http://wiki.koha-community.org/w/index.php?title=KohaUsageStat_RFC
 * https://github.com/jajm/hea-ws

## Install Hea locally

 * git clone https://github.com/biblibre/hea-app.git
 * git clone https://github.com/biblibre/hea-ws.git

 * Create a database whith the schema in hea-app/sql/schema.sql
 * Optional : Import mock data (hea-app/sql/mock-data.sql)

 * copy hea-app/environments/config.yml to hea-app/environments/production.yml
 * In this production.yml file, replace all REPLACE_ME with the name of the database created above and a user/password

 If it's not working, don't forget to see in hea-app/logs/production.log which Libraries are missing, and install them.

## Install perl libraries

* Libraries used: Dancer,  Dancer::Plugin::Database, Template, Template::Plugin::Number::Format
```
  # one installation way
  root # curl -L http://cpanmin.us | perl - --sudo <lib_name>
```

## Launch the app

```
hea-app$ ./bin/app.pl 
```


## Database and sample data

 1. Some mocks data are available in sql/mock-data.sql
 2. Schema is in sql/schema.sql 

## Available data for rendering

 * Metrics available in volumetry table
```
+---------------+
| name          |
+---------------+
| biblio        |
| borrowers     |
| old_issues    |
| aqorders      |
| subscription  |
| auth_header   |
| old_reserves  |
| old_reserves  |
+---------------+
```

 * System preferences recorded: a lot, see the Koha code (or patches on the bug tracker)
```
+------------+--------------+------+-----+---------+-------+
| Field      | Type         | Null | Key | Default | Extra |
+------------+--------------+------+-----+---------+-------+
| koha_id    | varchar(32)  | NO   |     | NULL    |       |
| name       | varchar(255) | NO   |     | NULL    |       |
| value      | text         | YES  |     | NULL    |       |
+------------+--------------+------+-----+---------+-------+
```

 * Installation table
```
+-------------------+--------------+------+-----+-------------------+-----------------------------+
| Field             | Type         | Null | Key | Default           | Extra                       |
+-------------------+--------------+------+-----+-------------------+-----------------------------+
| koha_id           | varchar(32)  | NO   | PRI | NULL              |                             |
| name              | varchar(255) | YES  |     | NULL              |                             |
| url               | varchar(255) | YES  |     | NULL              |                             |
| country           | varchar(255) | NO   |     |                   |                             |
| geolocation       | varchar(64)  | NO   |     |                   |                             |
| library_type      | varchar(255) | NO   |     |                   |                             |
| creation_time     | timestamp    | YES  |     | NULL              |                             |
| modification_time | timestamp    | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |
+-------------------+--------------+------+-----+-------------------+-----------------------------+
```

 * Library table
```
+-------------+--------------+------+-----+---------+----------------+
| Field       | Type         | Null | Key | Default | Extra          |
+-------------+--------------+------+-----+---------+----------------+
| library_id  | int(11)      | NO   | PRI | NULL    | auto_increment |
| koha_id     | varchar(32)  | NO   | MUL | NULL    |                |
| name        | varchar(255) | YES  |     | NULL    |                |
| url         | varchar(255) | YES  |     | NULL    |                |
| country     | varchar(255) | NO   |     |         |                |
| geolocation | varchar(64)  | NO   |     |         |                |
+-------------+--------------+------+-----+---------+----------------+

```

