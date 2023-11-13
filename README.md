# cwte-linux

You can add this Git repository to be available from emerge:

Add this as `/etc/portage/repos.conf/cwte-linux-repo.conf`, and then you can update it with `emaint sync -r cwte-linux-repo`
```
[cwte-linux-repo]
location = /var/db/repos/cwte-linux-repo
sync-type = git
sync-uri = https://github.com/XerneraC/cwte-linux.git
```

From there you can install the cwte kernel by emerging `sys-kernel/cwte-linux`
