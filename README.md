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


---

# Custom Config
You can load or modify the config by exporting
```bash
export CWTE_CUSTOM_CONFIG=1
```

This will make the ebuild pop up the menuconfig dialogue before compiling
From there you can load the old config `.config` and modify it, or just load a different config alltogether
The edited config must replace the `.config` config
