#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="sudo"

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
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms.schema additional_cfg

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 0,1,"-","Global settings:",'Global settings:','PP','',1, "maxlen=60", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 0,2,"config_file_replace","Purge sudoers.d directory",'1','1','',1, "maxlen=60", "radio", "truefalse", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 0,3,"purge","Replace current sudo config by module",'1','1','',1, "maxlen=60", "radio", "truefalse", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 0,4,"-","Additional configuration:",'Additional configuration:','','',1, "maxlen=60", "delimer", "", "usergroup" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 0,5,"Expand","Expand users group",'','','',0, "maxlen=60", "group_add", "", "usergroup" );
COMMIT;
EOF


/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema truefalse
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema content_autocomplete	# auto complete for content


# Put boolean for truefalse
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO truefalse ( text, order_id ) VALUES ( "true", 1 );
INSERT INTO truefalse ( text, order_id ) VALUES ( "false", 2 );
COMMIT;
EOF

# Put boolean for auto complete for content
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO content_autocomplete ( text, order_id ) VALUES ( "%wheel ALL=(ALL) ALL", 1 );
INSERT INTO content_autocomplete ( text, order_id ) VALUES ( "%wheel ALL=(ALL) NOPASSWD: ALL", 2 );
COMMIT;
EOF

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "sudo", "201607", "security/sudo", "" );
COMMIT;
EOF

# CREATE VIEW
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
CREATE VIEW FORM_VIEW AS SELECT * FROM forms UNION SELECT * FROM additional_cfg;
COMMIT;
EOF


# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
sudo module \
';
COMMIT;
EOF
