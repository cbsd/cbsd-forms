#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="ldapstandalone"

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
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,0,"-","OpenLDAP params:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"ldap_suffix",'LDAP Suffix (eg: dc=example,dc=com)','dc=example,dc=com','','',1, "maxlen=60", "inputbox", "ldap_suffix_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"ldap_bind_id",'Ldap Bind User, cn (eg: cn=admin,dc=example,dc=com)','cn=admin,dc=example,dc=com','','',1, "maxlen=60", "inputbox", "ldap_bind_id_autocomplete", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"ldap_bind_password",'Ldap Bind password for Bind User','password','','',1, "maxlen=60", "password", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,4,"openldap_log_level",'OpenLdap LogLevel','openldap_log_level','0','',1, "maxlen=60", "inputbox", "", "" );

INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,10,"-","Container params:",'-','','',1, "maxlen=128", "delimer", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,11,"fqdn","FQDN of container",'localhost','','',1, "maxlen=60", "inputbox", "", "" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema ldap_suffix_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema ldap_bind_id_autocomplete
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_yesno.schema openldap_log_level

# Autocomplete
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO ldap_suffix_autocomplete ( text, order_id ) VALUES ( 'dc=example,dc=com', 1 );
INSERT INTO ldap_bind_id_autocomplete ( text, order_id ) VALUES ( 'cn=admin,dc=example,dc=com', 2 );
COMMIT;
EOF

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "ldapstandalone", "201607", "", "" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
OpenLdap + PHP + Nginx + \
Ldap Account Mananger for standalone installation \
';
COMMIT;
EOF
