
default:	build

clean:
	rm -rf Makefile objs

build:
	$(MAKE) -f objs/Makefile

install:
	$(MAKE) -f objs/Makefile install

modules:
	$(MAKE) -f objs/Makefile modules

upgrade:
	/usr/home/liyao5/work/bin/lyngtest-dev/sbin/nginx -t

	kill -USR2 `cat /usr/home/liyao5/work/bin/lyngtest-dev/logs/nginx.pid`
	sleep 1
	test -f /usr/home/liyao5/work/bin/lyngtest-dev/logs/nginx.pid.oldbin

	kill -QUIT `cat /usr/home/liyao5/work/bin/lyngtest-dev/logs/nginx.pid.oldbin`
