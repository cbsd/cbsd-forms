generate_manifest()
{

	cat <<EOF
Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin" }
\$provider = "pkgng"
EOF

	cat <<EOF
#	class { "redis::install": }

class { "redis":
EOF

	for i in ${param}; do
		_T=""
		eval _T=\${${i}}

		case "$i" in
			-)
				continue
				;;
			slaveof|requirepass)
				[ -z "${_T}" ] && _T="" && continue
				;;
		esac

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
