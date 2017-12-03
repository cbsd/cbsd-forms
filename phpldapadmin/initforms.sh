#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="phpldapadmin"

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
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"ldap_host",'LDAP server, eg: localhost','localhost','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,3,"ldap_suffix",'LDAP Suffix (eg: dc=example,dc=com)','dc=example,dc=com','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,2,"ldap_bind_id",'Ldap Bind User, cn (eg: cn=admin,dc=example,dc=com)','cn=admin,dc=example,dc=com','','',1, "maxlen=60", "inputbox", "", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link,groupname ) VALUES ( "forms", 1,1,"ldap_bind_password",'Ldap Bind password for Bind User','password','','',1, "maxlen=60", "inputbox", "", "" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "phpldapadmin", "201607", "phpldapadmin-server", "service slapd restart" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
phpLDAPadmin is a web-based LDAP client. It provides easy, \
anywhere-accessible, multi-language administration for your LDAP \
server. Its hierarchical tree-viewer and advanced search functionality \
make it intuitive to browse and administer your LDAP directory. Since \
it is a web application, this LDAP browser works on many platforms, \
making your LDAP server easily manageable from any \
location. phpLDAPadmin is the perfect LDAP browser for the LDAP \
professional and novice alike. Its user base consists mostly of LDAP \
administration professionals. \
';
COMMIT;
EOF
