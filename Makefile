PASS_FILE="--password-file=./pass.txt"
REPO_DIR_RUFUS="/Users/drio/restic-repo"
REPO_DIR_WD="/Users/drio/wd_elements/restic-repo"
EXCLUDE=--exclude-file=exclude.txt
INCLUDE=/Users/drio
HOST?=sftp:drio@rufus

# restic forget -r <repo_name> --keep-weekly 10
# restic check -r <repo_name>

all: init backup

check: check-rufus check-rufus-wd

snapshots: snapshots-rufus snapshots-rufus-wd

backup: backup-rufus backup-rufus-wd

check-rufus:
	@restic --verbose -r $(HOST):$(REPO_DIR_RUFUS) check $(PASS_FILE) 

check-rufus-wd:
	@restic --verbose -r $(HOST):$(REPO_DIR_WD) check $(PASS_FILE) 

restore-rufus: snapshots-rufus
	@echo "mkdir /tmp/restore-work; \
	restic -r $(HOST):$(REPO_DIR_RUFUS) \
	restore ####### \
 	$(PASS_FILE)  \
	--target /tmp/restore-work \
	--include /Users/drio/dev/restic-backup"

snapshots-rufus:
	@restic --verbose -r $(HOST):$(REPO_DIR_RUFUS) snapshots $(PASS_FILE) 

snapshots-rufus-wd:
	@restic --verbose -r $(HOST):$(REPO_DIR_WD) snapshots $(PASS_FILE) 

backup-rufus:
	@restic -r $(HOST):$(REPO_DIR_RUFUS)  backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

backup-rufus-wd:
	@restic -r $(HOST):$(REPO_DIR_WD) backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

init: init-rufus init-rufus-wd

init-rufus:
	@restic -r $(HOST):$(REPO_DIR_RUFUS) snapshots $(PASS_FILE) 2>/dev/null; \
	exists=$$?; \
	[ $$exists -ne 0 ] && \
		restic -r $(HOST):$(REPO_DIR_RUFUS) init $(PASS_FILE) || \
		echo "repo ($(REPO_DIR_RUFUS)) already exists no need to run"

init-rufus-wd:
	@restic -r $(HOST):$(REPO_DIR_WD) snapshots $(PASS_FILE) 2>/dev/null; \
	exists=$$?; \
	[ $$exists -ne 0 ] && \
		restic -r $(HOST):$(REPO_DIR_WD) init $(PASS_FILE) || \
		echo "repo ($(REPO_DIR_WD)) already exists no need to run"

clean-repos-rufus: 
	@echo 'ssh rufus "rm -rf $(REPO_DIR_RUFUS) $(REPO_DIR_WD)"'
