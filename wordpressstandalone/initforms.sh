#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="wordpressstandalone"

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
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,0,"-","Wordpress params:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"wp_version",'wordpress version (eg: latest, 4.7.3)','latest','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"wp_install_dir",'wordpress install_dir (eg: /usr/local/www/wordpress)','/usr/local/www/wordpress','','',1, "maxlen=60", "inputbox", "", "" );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"wp_owner",'wp owner user (eg: www)','www','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"wp_group",'wp owner group (eg: www)','www','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,4,"wp_db_name",'wp mysql database (eg: wordress)','wordpress','','',1, "maxlen=60", "inputbox", "wp_db_name_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,5,"wp_db_user",'wp mysql database user (eg: wordress)','wordpress','','',1, "maxlen=60", "inputbox", "wp_db_user_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,6,"wp_db_password",'wp mysql database password (eg: strongpassword)','','','',1, "maxlen=60", "password", "", "" );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,50,"-","Wordpress debug:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,51,"wp_debug_display",'wordpress debug display (eg: false)','1','','',1, "maxlen=60",  "radio", "truefalse", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,52,"wp_debug_log",'wordpress debug log (eg: false)','1','','',1, "maxlen=60",  "radio", "truefalse", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,53,"wp_debug",'wordpress debug (eg: false)','1','','',1, "maxlen=60",  "radio", "truefalse", "" );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,100,"-","Container params:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,101,"fqdn","FQDN of container",'localhost','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,102,"mysql_server_root_password","MySQL Root password (e.g: strongpassword)",'','','',1, "maxlen=60", "password", "", "" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema wp_db_name_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema wp_db_user_autocomplete

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO wp_db_name_autocomplete ( text, order_id ) VALUES ( 'wordpress', 1 );
INSERT INTO wp_db_name_autocomplete ( text, order_id ) VALUES ( 'wordpress_db', 2 );
INSERT INTO wp_db_user_autocomplete ( text, order_id ) VALUES ( 'wordpress', 1 );
INSERT INTO wp_db_user_autocomplete ( text, order_id ) VALUES ( 'wordpress_user', 2 );
COMMIT;
EOF

# truefalse
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema truefalse

# Put boolean for truefalse
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO truefalse ( text, order_id ) VALUES ( "true", 0 );
INSERT INTO truefalse ( text, order_id ) VALUES ( "false", 1 );
COMMIT;
EOF


/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "wordpressstandalone", "201607", "", "" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
wordpress + Nginx + PHP + MySQL \
for standalone installation \
';
COMMIT;
EOF
