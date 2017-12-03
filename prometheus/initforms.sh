#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="prometheus"

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
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"-",'Global prometheus params:','-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"web_listen_address",'default is: :9090',':9090','','',0, "maxlen=30", "inputbox", "web_listen_address_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"scrape_interval",'default is: 5s','5s','','',0, "maxlen=30", "inputbox", "interval_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,4,"scrape_timeout",'default is: 5s','5s','','',0, "maxlen=30", "inputbox", "interval_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,5,"evaluation_interval",'default is: 5s','5s','','',0, "maxlen=30", "inputbox", "interval_autocomplete", "" );
COMMIT;
EOF

# autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema web_listen_address_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema interval_autocomplete

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO web_listen_address_autocomplete ( text, order_id ) VALUES ( ':9090', 1 );
INSERT INTO web_listen_address_autocomplete ( text, order_id ) VALUES ( '127.0.0.1:9090', 2 );
COMMIT;
EOF

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO interval_autocomplete ( text, order_id ) VALUES ( '5s', 1 );
INSERT INTO interval_autocomplete ( text, order_id ) VALUES ( '10s', 2 );
INSERT INTO interval_autocomplete ( text, order_id ) VALUES ( '15s', 3 );
INSERT INTO interval_autocomplete ( text, order_id ) VALUES ( '20s', 4 );
INSERT INTO interval_autocomplete ( text, order_id ) VALUES ( '25s', 5 );
INSERT INTO interval_autocomplete ( text, order_id ) VALUES ( '30s', 6 );
COMMIT;
EOF


/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "prometheus", "201607", "net-mgmt/prometheus", "service prometheus restart" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
Prometheus is a systems and service monitoring system. It collects metrics \
from configured targets at given intervals, evaluates rule expressions, \
displays the results, and can trigger alerts if some condition is observed \
to be true. \
';
COMMIT;
EOF
