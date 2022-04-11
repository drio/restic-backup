PASS_FILE="--password-file=./pass.txt"
REPO_DIR_RUFUS="/Users/drio/restic-repo"
REPO_DIR_WD="/Users/drio/wd_elements/restic-repo"
EXCLUDE=--exclude-file=exclude.txt
INCLUDE=--files-from=include.txt
HOST?=sftp:drio@rufusts
B2_BUCKET=drio-restic-backup
B2_ID=003106374dd93dd0000000001
B2_KEY=$(shell cat ./b2-key.txt)
B2_VARS=B2_ACCOUNT_ID=$(B2_ID) B2_ACCOUNT_KEY=$(B2_KEY)
B2_URL=b2:$(B2_BUCKET):b2_drio_repo
# restic forget -r <repo_name> --keep-weekly 10
# restic check -r <repo_name>

notification: backup
	osascript -e 'display notification "Backup done" with title "Backup" sound name "Purr.aiff"'

check: check-rufus check-rufus-wd

snapshots: snapshots-rufus snapshots-rufus-wd

backup: backup-rufus backup-rufus-wd backup-b2

check-rufus:
	@restic --verbose -r $(HOST):$(REPO_DIR_RUFUS) check $(PASS_FILE)

check-rufus-wd:
	@restic --verbose -r $(HOST):$(REPO_DIR_WD) check $(PASS_FILE)

verify-rufus: snapshots-rufus
	THE_ID=$$(restic --verbose -r $(HOST):$(REPO_DIR_RUFUS) snapshots "--password-file=./pass.txt" | tail -3 | head -1 | awk '{print $$1}');\
	echo $$THE_ID;\
	restic \
		-r $(HOST):$(REPO_DIR_RUFUS) \
		restore $$THE_ID \
		$(PASS_FILE)  \
		--target /tmp/restore-work \
		--include /Users/drio/dev/restic-backup;
	diff -r . /tmp/restore-work/Users/drio/dev/restic-backup;\
	rm -rf /tmp/restore-work;\

verify-rufus-wd: snapshots-rufus-wd
	THE_ID=$$(restic --verbose -r $(HOST):$(REPO_DIR_WD) snapshots "--password-file=./pass.txt" | tail -3 | head -1 | awk '{print $$1}');\
	echo $$THE_ID;\
	restic \
		-r $(HOST):$(REPO_DIR_WD) \
		restore $$THE_ID \
		$(PASS_FILE)  \
		--target /tmp/restore-work \
		--include /Users/drio/dev/restic-backup;\
	diff -r . /tmp/restore-work/Users/drio/dev/restic-backup;\
	rm -rf /tmp/restore-work;\


snapshots-rufus:
	@restic --verbose -r $(HOST):$(REPO_DIR_RUFUS) snapshots $(PASS_FILE)

snapshots-rufus-wd:
	@restic --verbose -r $(HOST):$(REPO_DIR_WD) snapshots $(PASS_FILE)

backup-rufus:
	@restic -r $(HOST):$(REPO_DIR_RUFUS) backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

backup-rufus-wd:
	@restic -r $(HOST):$(REPO_DIR_WD) backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

backup-b2:
	@$(B2_VARS) restic -r $(B2_URL) backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

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

init-b2:
	$(B2_VARS) restic -r $(B2_URL) init $(PASS_FILE)

clean-repos-rufus: 
	@echo 'ssh rufus "rm -rf $(REPO_DIR_RUFUS) $(REPO_DIR_WD)"'
