### What to backup?

~/*
~/.*
~/.config
~/dev
~drio/Dropbox
~drio/Pictures

exclude: node_modules

# TO restore:

Restore the latest version of the /Users/drio .config dir to /tmp/foo:

`restic -r sftp:drio@rufusts:"/Users/drio/restic-repo" restore latest --include /Users/drio/.config  --target=/tmp/foo "--password-file=./pass.txt"`

Notice you will have /tmp/foo/Users/drio/.config
