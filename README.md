# Docker Bugzilla 

透過Docker安裝Bugzilla服務



## Require

* Docker version > 20.4
* Docker-compose



## Feature

* 支援使用外部DB並透過ENV修改

  * 使用Magic DNS (host.docker.internal) 

  * 其他容器的DB可使用compose設定網路

* 支援不同版本Bugzilla

  **注意! Bugzilla databse 對不同版本間切換有一定程度上的相容性問題**



## Installtion


1. Clone this repo.

2. Setup database config on host.

   1. Add bugzilla user  (Container connect to host so bugzilla user should not limit address.)

      ```sql
      CREATE USER bugzilla@'%' IDENTIFIED BY "password";
      ```

   2. Create Database or config exists db.

      ```sql
      CREATE DATABASE bugzilla_db;
      ```

      ```sql
      GRANT ALL PRIVILEGES ON bugzilla_db.* TO bugzilla@'%';
      FLUSH PRIVILEGES;
      ```
      
   3. Configuring MariaDB for Remote Client Access

      [MariaDB](https://mariadb.com/kb/en/configuring-mariadb-for-remote-client-access/)

3. Set db connection

   ```bash
   cp .env.example .env
   nano .env
   ```

   Database config , admin config.

   ```
   DB_DRIVER=mysql
   DB_HOST=host.docker.internal
   DB_NAME=bugzilla_db
   DB_USER=bugzilla
   DB_PASS=bugzilla
   # Zero is default db port.
   DB_PORT=0
   
   
   ADMIN_EMAIL=xxxx@xxx.xxx
   # Least 6 characters at password.
   ADMIN_PASSWORD=xxxxxxx
   # IF value have space, add "\" to aviod error. (Docker env not friendly.)
   ADMIN_REALNAME=TAKI\ DOG\ WOW
   ```

    

4. Start docker-compose (Don't use -d mode )

   `docker-compose up`

   
   
5. Done.

