generate_manifest()
{

	cat <<EOF
Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin" }
\$provider = "pkgng"
EOF


# timesone
	cat <<EOF

class { 'clonos_userspw':
EOF

	for i in ${param}; do
		_T=""
		eval _T=\${${i}}

		[ -z "${_T}" ] && continue

		cat <<EOF
 $i => "${_T}",
EOF
done

	cat <<EOF
}
EOF

}


generate_hieradata()
{

}
