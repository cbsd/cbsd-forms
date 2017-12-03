#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="openldap"

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
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"ldap_suffix",'LDAP Suffix (eg: dc=example,dc=com)','dc=example,dc=com','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"ldap_bind_id",'Ldap Bind User, cn (eg: cn=admin,dc=example,dc=com)','cn=admin,dc=example,dc=com','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"ldap_bind_password",'Ldap Bind password for Bind User','password','','',1, "maxlen=60", "inputbox", "", "" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "openldap", "201607", "openldap-server", "service slapd restart" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
OpenLDAP is a suite of Lightweight Directory Access Protocol (v3) servers, \
clients, utilities and development tools. \
';
COMMIT;
EOF
