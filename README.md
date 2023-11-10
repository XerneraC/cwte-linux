# cwte-linux

You can add this Git repository to be available from emerge:

Add this to your `/etc/portage/repos.conf/eselect-repo.conf` file, and then you can select it with `eselect repo`
```
[cwte-linux]
location = /var/db/repos/cwte-linux
sync-type = git
sync-uri = https://github.com/XerneraC/cwte-linux.git
```

From there you can install the cwte kernel by emerging `sys-kernel/cwte-linux`
