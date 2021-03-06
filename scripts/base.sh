#!/bin/sh

set -ex

echo HTTP_PROXY=$HTTP_PROXY

if [ -z "$HTTP_PROXY" ]; then
  unset HTTP_PROXY
fi

hostname ${VAGRANTBOX_NAME}.vagrantup.com
sysrc hostname=$(hostname)

cat <<EOF >/root/vagrantbox-version
${VAGRANTBOX_URL}
${VAGRANTBOX_VERSION}
EOF

cat >>/etc/fstab <<EOF
proc    /proc   procfs  rw  0 0
fdesc   /dev/fd fdescfs rw  0 0
EOF
mount -a

sed -i '' -e 's#^ServerName .*$#ServerName update.freebsd.org#' /etc/freebsd-update.conf

freebsd-update -v debug --not-running-from-cron fetch install || true

mkdir -p /usr/local/etc/pkg/repos
cat <<'EOF' >/usr/local/etc/pkg/repos/FreeBSD.conf
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
}
EOF

env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg update
pkg upgrade -y

sysrc sendmail=NONE
