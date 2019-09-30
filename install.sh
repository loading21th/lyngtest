ngx_version=1.15.6
pcre_version=8.42
openssl_version=1.1.1
luajit_v=2.1-20180420
luafilesystem_v=1_6_3
lua_cjson_v=2.1.0.6
resty_signal_v=0.02

# 修改此安装位置
install_dir=/usr/home/liyao5/work/bin/lyngtest

# 清空安装目录，临时解压目录
rm -rf ${install_dir}
rm -rf nginx-${ngx_version}

tar zxf nginx-${ngx_version}.tar.gz
cd nginx-${ngx_version}
echo "******nginx"

cp ../3party . -r
cd 3party
find ./ -name "*.tar.gz" -exec tar zxf  {} \; 
find ./ -name "*.tar.bz2" -exec tar jxf  {} \; 
rm -rf *tar.gz
rm -rf *tar.bz2
cd ..
echo "******3party"

cp ../modules . -r
cd modules
find ./ -name "*.tar.gz" -exec tar zxf  {} \; 
find ./ -name "*.tar.bz2" -exec tar jxf  {} \; 
rm -rf *tar.gz
rm -rf *tar.bz2
cd ..
echo "******module"

cp ../restylib . -r
cd restylib
find ./ -name "*.tar.gz" -exec tar zxf  {} \; 
find ./ -name "*.tar.bz2" -exec tar jxf  {} \; 
rm -rf *tar.gz
rm -rf *tar.bz2
cd ..
mkdir -p tmplib
rm -rf lib
cp -r restylib/*/lib/* tmplib/
rm -rf restylib
mv tmplib lib
echo "******restylib"

patch -p1 <  ../patches/lua-nginx-module-0.10.15.patch
patch -p1 <  ../patches/nginx-${ngx_version}-socket_cloexec.patch

cd 3party/luajit2-${luajit_v}
make -j4 install DESTDIR=${install_dir} PREFIX=/luajit-${luajit_v}
export LUAJIT_LIB=${install_dir}/luajit-${luajit_v}/lib
export LUAJIT_INC=${install_dir}/luajit-${luajit_v}/include/luajit-2.1
cd ../..
echo "******luajit"

cd 3party/lua-resty-signal-${resty_signal_v}
make LUA_INCLUDE_DIR=${LUAJIT_INC} || exit 1
make install LUA_LIB_DIR=${install_dir}/lib || exit 1
cd ../..
echo "******resty_signal"

cd 3party/lua-cjson-${lua_cjson_v}
make LUA_INCLUDE_DIR=${LUAJIT_INC} || exit 1
make install LUA_CMODULE_DIR=${install_dir}/lib || exit 1
cd ../..
echo "******cjson"

cd 3party/luafilesystem-v_${luafilesystem_v}
sed -i "s,LUA_LIBDIR=.*$,LUA_LIBDIR=${install_dir}/lib,g" config
sed -i "s,LUA_INC=.*$,LUA_INC=${LUAJIT_INC},g" config
make && make install 
cd ../..
echo "******lfs"

CFLAGS="-pipe -O3 -W -Wall -Wpointer-arith -Wno-unused-parameter -Wunused-function -Wunused-variable -Wunused-value -Werror" 
./configure \
    --prefix=${install_dir} \
    --with-pcre=./3party/pcre-${pcre_version} \
    --with-pcre-jit \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-openssl=./3party/openssl-$openssl_version \
    --with-openssl-opt="enable-tls1_3" \
    --add-module=modules/headers-more-nginx-module-0.33 \
    --add-module=modules/ngx_devel_kit-0.3.0 \
    --add-module=modules/lua-nginx-module-0.10.15 \
    --with-ld-opt="-lstdc++ -Wl,-rpath,${LUAJIT_LIB}"

make -j12 || exit

make install

# 安装app程序。安装包下conf和html为测试使用
cp ../app ${install_dir}/ -r
cp ../conf/* ${install_dir}/conf/ -r
cp ../html/* ${install_dir}/html/ -r

# 解压后的nginx/lib下为主要的resty lib库
cp lib/* ${install_dir}/lib/ -r
