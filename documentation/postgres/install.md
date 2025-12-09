# Installation postgres+postgis

Source <https://documentation.ubuntu.com/server/how-to/databases/install-postgresql/>

```bash
sudo apt update
sudo apt install postgresql # 16+257build1.1
sudo apt install postgis 
```
Configure listener
```bash
sudo vi /etc/postgresql/*/main/postgresql.conf # change listen_adresses to '*'
```
Set master password
```bash
sudo -u postgres psql template1
ALTER USER postgres with encrypted password '*****';
```

Set pg_hba, see also https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
```bash
sudo vi /etc/postgresql/*/main/pg_hba.conf
# add rule
host    all             all             .kalro.org            md5
```

Enable postgis on a database
```bash
psql --host localhost --username postgres --password --dbname template1
-> CREATE EXTENSION postgis;
```

Read more at <https://www.postgresql.org/docs/current/admin.html>

## pgadmin

[pgadmin](https://www.pgadmin.org/) is a webbased tool to interact with the database, you can install it locally, on the server or access it via docker:

```bash
docker run -e PGADMIN_DEFAULT_EMAIL=info@example.com -e PGADMIN_DEFAULT_PASSWORD=example -p80:80 dpage/pgadmin4
```


