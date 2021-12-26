PASS_FILE="--password-file=./pass.txt"
REPO_DIR_RUFUS="/Users/drio/restic-repo"
REPO_DIR_WD="/Users/drio/wd_elements/restic-repo"
EXCLUDE=--exclude-file=exclude.txt
INCLUDE=/Users/drio

# restic forget -r <repo_name> --keep-weekly 10
# restic check -r <repo_name>

all: init backup

init: init-rufus init-rufus-wd

backup: backup-rufus backup-rufus-wd

backup-rufus:
	@restic \
  --verbose \
	-r sftp:drio@rufus:$(REPO_DIR_RUFUS) \
	backup \
	$(INCLUDE) \
	$(PASS_FILE) \
	$(EXCLUDE)

backup-rufus-wd:
	@restic \
	--verbose	\
	-r sftp:drio@rufus:$(REPO_DIR_WD) \
	backup \
	$(INCLUDE) \	
	$(PASS_FILE) \
	$(EXCLUDE)

init-rufus:
	@restic -r sftp:drio@rufus:$(REPO_DIR_RUFUS) snapshots $(PASS_FILE); \
	exists=$$?; \
	[ $$exists -ne 0 ] && \
		restic -r sftp:drio@rufus:$(REPO_DIR_RUFUS) init $(PASS_FILE) || \
		echo "repo ($(REPO_DIR_RUFUS)) already exists no need to run"

init-rufus-wd:
	@restic -r sftp:drio@rufus:$(REPO_DIR_WD) snapshots $(PASS_FILE); \
	exists=$$?; \
	[ $$exists -ne 0 ] && \
		restic -r sftp:drio@rufus:$(REPO_DIR_WD) init $(PASS_FILE) || \
		echo "repo ($(REPO_DIR_WD)) already exists no need to run"

clean-repos-rufus: 
	@echo 'ssh rufus "rm -rf $(REPO_DIR_RUFUS) $(REPO_DIR_WD)"'
