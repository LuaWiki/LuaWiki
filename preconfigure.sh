#!/bin/bash

git clone git@github.com:AlexanderMisel/LPeg.git lpeg

openresty_ver="1.19.9.1"
luarocks_ver="3.7.0"

wget "https://openresty.org/download/openresty-$openresty_ver.tar.gz"
tar zxf "openresty-$openresty_ver.tar.gz"
cd "openresty-$openresty_ver" || exit
./configure --prefix="$(realpath ../openresty)" -j4
make -j4
make install
cd ..

wget "https://luarocks.org/releases/luarocks-$luarocks_ver.tar.gz"
tar zxf "luarocks-$luarocks_ver.tar.gz"
cd "luarocks-$luarocks_ver" || exit
./configure --prefix="$(realpath ../openresty)/luajit" \
    --with-lua="$(realpath ../openresty)/luajit/" \
    --lua-suffix=jit \
    --force-config \
    --lua-version=5.1 \
    --with-lua-include="$(realpath ../openresty)/luajit/include/luajit-2.1"
make -j4
make install
cd ..

./openresty/luajit/bin/luarocks install lpeg
./openresty/luajit/bin/luarocks install inspect

mkdir logs
