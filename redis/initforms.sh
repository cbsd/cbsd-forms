#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="redis"

. /etc/rc.conf

workdir="${cbsd_workdir}"

set -e
. ${workdir}/cbsd.conf
. ${subr}
set +e

MYPATH="${workdir}/formfile"

[ ! -d "${MYPATH}" ] && err 1 "No such ${MYPATH}"
[ -f "${MYPATH}/${HELPER}.sqlite" ] && /bin/rm -f "${MYPATH}/${HELPER}.sqlite"

/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms.schema forms

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"bind","Bind: default is 0.0.0.0",'0.0.0.0','','',1, "maxlen=60", "inputbox", "bind_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"port","Port: default is 6379. 0 - not listen on a TCP socket",'6379','','',1, "maxlen=60", "inputbox", "port_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"requirepass","Requirepass: Require clients to issue AUTH <PASSWORD>",'','','',0, "maxlen=30", "password", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,4,"maxmemory","MaxMemory: Don't use more memory than the specified amount of byte",'1g','','',1, "maxlen=128", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,5,"maxmemory_policy","maxmemory policy",'1','1','',1, "maxlen=128", "select", "memory_policy_select", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,6,"tcp_keepalive","tcp_keepalive",'0','','',1, "maxlen=128", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,7,"log_level","log_level; default is: warning",'4','','',1, "maxlen=128", "radio", "log_level", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,8,"syslog_enabled","syslog_enabled",'2','2','',1, "maxlen=128", "radio", "syslog_noyes", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,9,"timeout","timeout",'300','','',1, "maxlen=128", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,10,"-","Replication:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,11,"slave_priority","slave-priority",'100','','',1, "maxlen=128", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,12,"slaveof","slaveof: ip port",'','','',0, "maxlen=128", "inputbox", "", "" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# syslog_noyes
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema syslog_noyes

# autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema bind_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema port_autocomplete

/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema log_level

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO bind_autocomplete ( text, order_id ) VALUES ( '0.0.0.0', 1 );
INSERT INTO bind_autocomplete ( text, order_id ) VALUES ( '127.0.0.1', 2 );
COMMIT;
EOF

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO port_autocomplete ( text, order_id ) VALUES ( '6379', 1 );
INSERT INTO port_autocomplete ( text, order_id ) VALUES ( '0', 2 );
COMMIT;
EOF

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO log_level ( text, order_id ) VALUES ( 'debug', 1 );
INSERT INTO log_level ( text, order_id ) VALUES ( 'verbose', 2 );
INSERT INTO log_level ( text, order_id ) VALUES ( 'notice', 3 );
INSERT INTO log_level ( text, order_id ) VALUES ( 'warning', 4 );
COMMIT;
EOF

# Put boolean for syslog_noyes
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO syslog_noyes ( text, order_id ) VALUES ( "no", 1 );
INSERT INTO syslog_noyes ( text, order_id ) VALUES ( "yes", 0 );
COMMIT;
EOF

# Put boolean for syslog_noyes
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
CREATE TABLE memory_policy_select ( id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT DEFAULT NULL, order_id INTEGER DEFAULT 0 );
INSERT INTO memory_policy_select ( text, order_id ) VALUES ( "volatile-lru", 5 );
INSERT INTO memory_policy_select ( text, order_id ) VALUES ( "allkeys-lru", 4 );
INSERT INTO memory_policy_select ( text, order_id ) VALUES ( "volatile-random", 3 );
INSERT INTO memory_policy_select ( text, order_id ) VALUES ( "allkeys-random", 2 );
INSERT INTO memory_policy_select ( text, order_id ) VALUES ( "volatile-ttl", 1 );
INSERT INTO memory_policy_select ( text, order_id ) VALUES ( "noeviction", 0 );
COMMIT;
EOF

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "redis", "201607", "databases/redis", "service redis restart" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
Redis is an open source, advanced key-value store.  It is often referred \
to as a data structure server since keys can contain strings, hashes, \
lists, sets and sorted sets. \
';
COMMIT;
EOF
