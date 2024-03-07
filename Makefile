.POSIX:
.SUFFIXES:


#
# PUBLIC MACROS
#

CLI     = ting-cli
DESTDIR = ./dist
LINT    = shellcheck
TEST    = ./unittest


#
# INTERNAL MACROS
#

TEST_SRC=https://github.com/macie/unittest.sh/releases/latest/download/unittest


#
# DEVELOPMENT TASKS
#

.PHONY: all
all: test check

.PHONY: clean
clean:
	@echo '# Delete test runner:' >&2
	rm -f $(TEST)
	@echo '# Delete bulid directory' >&2
	rm -rf $(DESTDIR)

.PHONY: info
info:
	@printf '# OS info: '
	@uname -rsv;
	@echo '# Development dependencies:'
	@echo; $(LINT) -V || true
	@echo; $(TEST) -v || true
	@echo '# Environment variables:'
	@env || true

.PHONY: check
check: $(LINT)
	@printf '# Static analysis: $(LINT) $(CLI) ./tests/*.sh' >&2
	@$(LINT) $(CLI) ./tests/*.sh

.PHONY: test
test: $(TEST)
	@echo '# Unit tests: $(TEST)' >&2
	@$(TEST)

.PHONY: install
install:
	@echo '# Install in /usr/local/bin' >&2
	@mkdir -p /usr/local/bin; cp $(CLI) /usr/local/bin/

.PHONY: dist
dist:
	@echo '# Copy CLI executable to $(DESTDIR)/$(CLI)' >&2
	@mkdir -p $(DESTDIR); cp $(CLI) $(DESTDIR)/
	@echo '# Add executable checksum to: $(DESTDIR)/$(CLI).sha256sum' >&2
	@cd $(DESTDIR); sha256sum $(CLI) >> $(CLI).sha256sum


#
# DEPENDENCIES
#

$(LINT):
	@printf '# $@ installation path: ' >&2
	@command -v $@ >&2 || { echo "ERROR: Cannot find $@" >&2; exit 1; }

$(TEST):
	@echo '# Prepare $@:' >&2
	@if [ "$$(uname -s)" = "OpenBSD" ]; then \
		ftp -V $(TEST_SRC); \
		ftp -V $(TEST_SRC).sha256sum; \
		sha256 -c $@.sha256sum; \
	else \
		curl -fLO $(TEST_SRC); \
		curl -fLO $(TEST_SRC).sha256sum; \
		sha256sum -c $@.sha256sum; \
	fi
	chmod +x $@
