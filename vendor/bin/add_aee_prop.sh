#!/vendor/bin/sh
db=`getprop  vendor.debug.mtk.aeev.db | cut -f2 -d:`
if test -d "$db"; then
	getprop > $db/properties
	cp /sys/fs/pstore/console-ramoops-0 $db/
fi
