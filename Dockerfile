FROM debian:bullseye
WORKDIR /opt/luawiki

COPY . .
COPY docker/nginx.conf conf/nginx.conf
COPY docker/local_settings.lua luawiki/local_settings.lua

RUN mkdir lib logs

RUN apt-get update && \
	apt-get -y install --no-install-recommends curl gnupg ca-certificates git build-essential lua5.1 liblua5.1

RUN curl -o- https://openresty.org/package/pubkey.gpg | apt-key add - && \
	echo "deb http://openresty.org/package/debian bullseye openresty" | tee /etc/apt/sources.list.d/openresty.list && \
	apt-get update && \
	apt-get -y install --no-install-recommends openresty

RUN git clone --depth 1 https://github.com/kikito/inspect.lua --branch v3.1.3 /tmp/inspect && \
	cp /tmp/inspect/inspect.lua /opt/luawiki/inspect.lua && \
	rm -rf /tmp/inspect

RUN git clone --depth 1 https://github.com/AlexanderMisel/LPeg /tmp/lpeg && \
	make --directory=/tmp/lpeg LUADIR="/usr/include/lua5.1" && \
	cp /tmp/lpeg/lpeg.so /opt/luawiki/lib && \
	rm -rf /tmp/lpeg

COPY docker/entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]

STOPSIGNAL SIGQUIT

EXPOSE 80/tcp
CMD [ "openresty", "-p", "/opt/luawiki", "-g", "daemon off;" ]
