from alpine

run apk add curl openssl openssh git linux-headers perl pcre
run apk add pcre-dev openssl-dev make gcc libzip-dev libaio-dev musl-dev

# OpenResty
workdir /tmp
copy https://openresty.org/download/openresty-1.15.8.2.tar.gz openresty-1.15.8.2.tar.gz
run tar -xzf openresty-*.tar.gz
workdir openresty-1.15.8.2
run ./configure \
	--with-pcre-jit \
	--with-http_v2_module \
	--with-http_ssl_module \
	--with-mail \
	--with-stream \
	--with-threads \
	--with-file-aio \
	--with-http_realip_module \
	--with-stream_ssl_module \
	--with-stream \
	--with-stream_ssl_module \
	--with-stream \
	--with-stream_ssl_module \
	--with-http_stub_status_module \
&& make -j $(nproc) && make install \
&& ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin
# cleanup
run rm -rf /tmp/*

# LuaJIT
workdir /tmp
copy http://luajit.org/download/LuaJIT-2.0.4.tar.gz LuaJIT-2.0.4.tar.gz
run tar -xzf LuaJIT-*.tar.gz
workdir LuaJIT-2.0.4
run make -j $(nproc) && make install
# cleanup
run rm -rf /tmp/*

# Luarocks
workdir /tmp
run apk add unzip
copy http://luarocks.github.io/luarocks/releases/luarocks-3.2.1.tar.gz luarocks-3.2.1.tar.gz
run tar -xzf luarocks-*.tar.gz
workdir luarocks-3.2.1
run ./configure && make bootstrap
# cleanup
run rm -rf /tmp/*

# Restia
workdir /tmp
run apk add yaml-dev
run luarocks install restia --dev

#	# Build a minimal restia image
#	from alpine
#	# Necessary requirements
#	run apk add curl openssh git linux-headers perl pcre libgcc openssl yaml
#	# Pull openresty, luarocks, restia, etc. from the restia image
#	copy --from=restia /usr/local /usr/local
#	# Copy the restia application
#	copy application /etc/application
#	workdir /etc/application
#	cmd restia run
