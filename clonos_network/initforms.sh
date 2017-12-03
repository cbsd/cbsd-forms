#!/bin/sh
MYDIR="$( /usr/bin/dirname $0 )"
MYPATH="$( /bin/realpath ${MYDIR} )"
HELPER="clonos_network"

. /etc/rc.conf

workdir="${cbsd_workdir}"

set -e
. ${workdir}/cbsd.conf
. ${subr}
set +e

MYPATH="${workdir}/formfile"

[ ! -d "${MYPATH}" ] && err 1 "No such ${MYPATH}"
[ -f "${MYPATH}/${HELPER}.sqlite" ] && /bin/rm -f "${MYPATH}/${HELPER}.sqlite"

${moduledir}/forms.d/${HELPER}/iface_select_gen.sh > /tmp/iface_select.sql

/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms.schema forms

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,1,"-","Network settings",'-','','',1, "maxlen=128", "delimer", "" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,2,"hostname","Please choose a hostname for this machine",'clonos1.my.domain','clonos1.my.domain','',1, "maxlen=128", "inputbox", "hostname" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,2,"uplink_interface","Primary/Uplink network interface",'','','',1, "maxlen=128", "select", "iface_select" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,3,"ip4_addr","IP4 Address without mask",'','','',1, "maxlen=128", "inputbox", "ip4_addr" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,3,"ip4_mask","",'','','',0, "maxlen=128", "inputbox", "netmask" );
INSERT INTO forms ( mytable,group_id,order_id,param,desc,def,cur,new,mandatory,attr,type,link ) VALUES ( "forms", 1,4,"ip4_gateway","Gateway",'','','',1, "maxlen=128", "inputbox", "gateway" );
COMMIT;
EOF

# Put version
/usr/local/bin/cbsd ${miscdir}/updatesql ${MYPATH}/${HELPER}.sqlite /usr/local/cbsd/share/forms_system.schema system

# Put boolean for timezone_select
/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite < /tmp/iface_select.sql

# Put boolean for lang_select
#/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite < ${moduledir}/forms.d/${HELPER}/lang_select.sql

/usr/local/bin/sqlite3 ${MYPATH}/${HELPER}.sqlite << EOF
BEGIN TRANSACTION;
INSERT INTO system ( helpername, version, packages, have_restart, title ) VALUES ( "clonos_network", "201607", "", "", "Configure network settings" );
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
