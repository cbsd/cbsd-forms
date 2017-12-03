#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="redminestandalone"

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
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,0,"-","Redmine params:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"redmine_db",'redmine database name (eg: redmine)','redmine','','',1, "maxlen=60", "inputbox", "redmine_db_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"redmine_db_user",'redmine database user (eg: redmine)','redmine','','',1, "maxlen=60", "inputbox", "redmine_db_user_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"redmine_db_password",'redmine database password for redmine user','','','',1, "maxlen=60", "password", "", "" );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,10,"-","Container params:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,11,"fqdn","FQDN of container",'localhost','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,12,"mysql_server_root_password","MySQL Root password (e.g: strongpassword)",'','','',1, "maxlen=60", "password", "", "" );

COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema redmine_db_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema redmine_db_user_autocomplete

/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema redmine_bind_id_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema openredmine_log_level

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO redmine_db_autocomplete ( text, order_id ) VALUES ( 'redmine', 1 );
INSERT INTO redmine_db_autocomplete ( text, order_id ) VALUES ( 'redmine_db', 2 );
INSERT INTO redmine_db_user_autocomplete ( text, order_id ) VALUES ( 'redmine', 1 );
INSERT INTO redmine_db_user_autocomplete ( text, order_id ) VALUES ( 'redmine_user', 2 );
COMMIT;
EOF

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "redminestandalone", "201607", "", "" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
Redmine + Nginx + Passenger + MySQL \
for standalone installation \
';
COMMIT;
EOF
