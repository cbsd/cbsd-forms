#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="clonos_zfsinstall"

. /etc/rc.conf

workdir="${cbsd_workdir}"

set -e
. ${workdir}/cbsd.conf
. ${subr}
set +e

MYPATH="${workdir}/formfile"

[ ! -d "${MYPATH}" ] && err 1 "No such ${MYPATH}"
[ -f "${MYPATH}/${HELPER}.sqlite" ] && /bin/rm -f "${MYPATH}/${HELPER}.sqlite"

${moduledir}/forms.d/${HELPER}/dsk_select_gen.sh > /tmp/dsk_select.sql

/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms.schema forms

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,1,"-","disk settings",'-','','',1, "maxlen=128", "delimer", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,1,"dsk","Select dsk for install",'','','',1, "maxlen=128", "checkbox", "dsk_select" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# Put boolean for timezone_select
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite < /tmp/dsk_select.sql
/bin/rm -f /tmp/dsk_select.sql

# Put boolean for lang_select
#/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite < ${moduledir}/forms.d/${HELPER}/lang_select.sql

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart ) VALUES ( "${HELPER}", "201607", "", "" );
COMMIT;
EOF

# long description
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
UPDATE system SET longdesc='\
clonos FreeBSD base module \
';
COMMIT;
EOF
