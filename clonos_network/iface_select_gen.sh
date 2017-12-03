#!/bin/sh

export PATH=$PATH:/usr/local/bin:/usr/local/sbin

cat << EOF
BEGIN TRANSACTION;
CREATE TABLE iface_select ( id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT DEFAULT NULL, order_id INTEGER DEFAULT 0 );
EOF


num=1

for i in $( /usr/local/cbsd/misc/nics-list -s "lo bridge tap" ); do
cat <<EOF
INSERT INTO iface_select ( text, order_id ) VALUES ( "${i}", $num );
EOF
num=$(( num + 1 ))
done

cat <<EOF
COMMIT;
EOF
