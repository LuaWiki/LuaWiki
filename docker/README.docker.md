构建图像：
```sh
docker build -t luawiki:latest .
```

启动容器：
```sh
docker compose up -d
```

备注：目前容器的数据库尚无法自动生成，下列方式可供您参考

1. 预先建立卷 `luawiki-mysql-data`（备注：卷名可能按照启动实例有所不同，如果不清楚可以启动一次后用 `docker volume ls` 查看）
```sh
docker volume create luawiki_luawiki-mysql-data
```
2. 导入 sql
```sh
docker run -it --rm -v luawiki_luawiki-mysql-data:/var/lib/mysql -v `pwd`:/opt/luawiki -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes mariadb:10.10.3 /opt/luawiki/docker/init-database.sh mywiki
```