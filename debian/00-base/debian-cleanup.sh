#! /bin/bash
find /usr/share/doc -depth -type f ! -name copyright -delete
find /usr/share/doc -empty -delete
rm -rf /usr/share/man
rm -rf /usr/share/groff
rm -rf /usr/share/info
rm -rf /usr/share/lintian
rm -rf /usr/share/linda
rm -fr /var/cache/man
rm /var/lib/apt/lists/*dists*
rm /get-package-list.sh /debian-cleanup.sh
