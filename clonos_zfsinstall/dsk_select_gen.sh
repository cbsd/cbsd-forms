#!/bin/sh

export PATH=$PATH:/usr/local/bin:/usr/local/sbin

cat << EOF
BEGIN TRANSACTION;
CREATE TABLE dsk_select ( id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT DEFAULT NULL, order_id INTEGER DEFAULT 0 );
EOF


num=1

for i in $( /usr/jails/misc/disks-list |/usr/bin/cut -d : -f 1 ); do
cat <<EOF
INSERT INTO dsk_select ( text, order_id ) VALUES ( "${i}", $num );
EOF
num=$(( num + 1 ))
done

cat <<EOF
COMMIT;
EOF
