include .env

notification: backup
	osascript -e 'display notification "Backup done" with title "Backup" sound name "Purr.aiff"'

check: check-teewinot-wd

snapshots: snapshots-teewinot-wd

backup: backup-teewinot-wd backup-b2

check-teewinot-wd:
	@restic --verbose -r $(HOST):$(REPO_DIR_WD) check $(PASS_FILE)

verify-teewinot-wd: snapshots-teewinot-wd
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

snapshots-b2:
	@$(B2_VARS) restic -r $(B2_URL) snapshots $(PASS_FILE)

snapshots-teewinot-wd:
	@restic --verbose -r $(HOST):$(REPO_DIR_WD) snapshots $(PASS_FILE)

backup-teewinot-wd:
	@restic -r $(HOST):$(REPO_DIR_WD) backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

backup-b2:
	@$(B2_VARS) restic -r $(B2_URL) backup $(INCLUDE) $(PASS_FILE) $(EXCLUDE) || true

init: init-teewinot init-teewinot-wd

init-teewinot-wd:
	@restic -r $(HOST):$(REPO_DIR_WD) snapshots $(PASS_FILE) 2>/dev/null; \
	exists=$$?; \
	[ $$exists -ne 0 ] && \
		restic -r $(HOST):$(REPO_DIR_WD) init $(PASS_FILE) || \
		echo "repo ($(REPO_DIR_WD)) already exists no need to run"

init-b2:
	$(B2_VARS) restic -r $(B2_URL) init $(PASS_FILE)

restore-test-from-wd:
	@echo "Restoring /Users/drio/.config in /tmp/foo ..."
	@restic -r $(HOST):$(REPO_DIR_WD) \
      restore latest \
      --include /Users/drio/.config  \
      --target=/tmp/foo \
			$(PASS_FILE)

restore-test-from-b2:
	@echo "Restoring /Users/drio/.config in /tmp/foo ..."
	@$(B2_VARS) restic -r $(B2_URL) \
      restore latest \
      --include /Users/drio/.config  \
      --target=/tmp/foo \
      "--password-file=./pass.txt"
