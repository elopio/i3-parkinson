#
# Makefile
#
# Requires : shellcheck
#

#
# This Makefile is best invoked via a custom script called 'i3-make'
# that assigns values to these custom variables where necessary:
#

# Local git repo directory.
I3FILES=$(shell  readlink -f `pwd`)

# The i3 config file to be installed.
I3CFG=$(HOME)/.config/i3/config

# A running i3wm references the file it used at startup, so it is
# prudent to keep old and new in sync after relocating the file.
I3ALTCFG=$(HOME)/.i3/config

# The i3status config file to be installed.
I3STATUSCFG=$(HOME)/.config/i3status/config

# The compton config file to be installed.
COMPTONCFG=$(HOME)/.config/compton.conf

# Directory where i3 helper scripts will be installed.
# Ensure that this directory is on your ${PATH}.
I3BIN=$(HOME)/bin

# Helpfiles.
#
# 1, Create one line from file for sed.
# 2. Replace line continuations with a token.
# 3. Replace ordinary line end with linefeed.
# 4A. Grep for bindsyms inside modes,
# 4B. Grep for mode "headers",
# 4C. Grep for numpad bindsyms in default mode.
# 5. Restore the line continuations marked with tokens.
#
I3BINDINGS=/tmp/i3/bindings

# Install permissions for: directories, executables, configurations.
DIRMODE=755
EXEMODE=755
CFGMODE=644

# Audio feedback. Substitute 'true' for silence.
BINGBONG="play -q /usr/share/sounds/freedesktop/stereo/complete.oga"

# Nothing is installed unless this is set to "true".
# Maintainers: Use 'make CONFIGURED=true'.
CONFIGURED=false

#
# Do not customise anything below here.
#

all:  .configured .custom .checks .install .restart .reload .done

help:
	@echo "Please read the Makefile."
	@echo I3FILES=$(I3FILES)
	@echo I3CFG=$(I3CFG)
	@echo I3ALTCFG=$(I3ALTCFG)
	@echo I3STATUSCFG=$(I3STATUSCFG)
	@echo COMPTONCFG=$(COMPTONCFG)
	@echo I3BIN=$(I3BIN)
	@echo I3BINDINGS=$(I3BINDINGS)
	@echo modes: $(DIRMODE) $(EXEMODE) $(CFGMODE)
	@echo audio: `basename $(BINGBONG)`
	@echo CONFIGURED=$(CONFIGURED)

.configured:
	@$(CONFIGURED)

.install:  \
    $(I3CFG) \
    $(I3ALTCFG) \
    $(I3STATUSCFG) \
    $(COMPTONCFG) \
    $(I3BIN)/i3-apps \
    $(I3BIN)/i3-display \
    $(I3BIN)/i3-keyboard \
    $(I3BIN)/i3-mode \
    $(I3BIN)/i3-mouse \
    $(I3BIN)/i3-wrapper \
    $(I3BINDINGS)

.checks: \
    $(I3FILES)/.i3-apps.log \
    $(I3FILES)/.i3-display.log \
    $(I3FILES)/.i3-keyboard.log \
    $(I3FILES)/.i3-mode.log \
    $(I3FILES)/.i3-mouse.log \
    $(I3FILES)/.i3-wrapper.log

.custom: \
    $(I3FILES)/.i3-custom.save

$(I3CFG): $(I3FILES)/dot-config-i3-config
	@install -m $(DIRMODE) -d `dirname  $(I3CFG)`
	@install -m $(CFGMODE) -T $(I3FILES)/dot-config-i3-config $(I3CFG)
	@touch $(I3FILES)/RELOAD

$(I3ALTCFG): $(I3FILES)/dot-config-i3-config
	@install -m $(DIRMODE) -d `dirname  $(I3ALTCFG)`
	@install -m $(CFGMODE) -T $(I3FILES)/dot-config-i3-config $(I3ALTCFG)

$(I3STATUSCFG): $(I3FILES)/dot-config-i3status-config
	@install -m $(DIRMODE) -d `dirname  $(I3STATUSCFG)`
	@install -m $(CFGMODE) -T $(I3FILES)/dot-config-i3status-config $(I3STATUSCFG)
	@touch $(I3FILES)/RESTART

$(COMPTONCFG): $(I3FILES)/compton.conf
	@install -m $(DIRMODE) -d `dirname  $(COMPTONCFG)`
	@install -m $(CFGMODE) -T $(I3FILES)/compton.conf $(COMPTONCFG)

$(I3BIN)/i3-apps: $(I3FILES)/i3-apps
	@install -m $(DIRMODE) -d $(I3BIN)
	@install -m $(EXEMODE) $(I3FILES)/i3-apps $(I3BIN)

$(I3BIN)/i3-display: $(I3FILES)/i3-display
	@install -m $(DIRMODE) -d $(I3BIN)
	@install -m $(EXEMODE) $(I3FILES)/i3-display $(I3BIN)

$(I3BIN)/i3-keyboard: $(I3FILES)/i3-keyboard
	@install -m $(DIRMODE) -d $(I3BIN)
	@install -m $(EXEMODE) $(I3FILES)/i3-keyboard $(I3BIN)

$(I3BIN)/i3-mode: $(I3FILES)/i3-mode
	@install -m $(DIRMODE) -d $(I3BIN)
	@install -m $(EXEMODE) $(I3FILES)/i3-mode $(I3BIN)

$(I3BIN)/i3-mouse: $(I3FILES)/i3-mouse
	@install -m $(DIRMODE) -d $(I3BIN)
	@install -m $(EXEMODE) $(I3FILES)/i3-mouse $(I3BIN)

$(I3BIN)/i3-wrapper: $(I3FILES)/i3-wrapper
	@install -m $(DIRMODE) -d $(I3BIN)
	@install -m $(EXEMODE) $(I3FILES)/i3-wrapper $(I3BIN)

$(I3BINDINGS): $(I3FILES)/dot-config-i3-config $(I3FILES)/Makefile
	@mkdir -p `dirname $(I3BINDINGS)`
	@cat $(I3FILES)/dot-config-i3-config | awk 1 ORS='@' | \
	sed 's/\\@/%%%/g' | sed 's/@/\n/g' | \
	egrep '([^.]bindsym|^mode|bindsym KP|^bindsym Mod)' | \
	sed 's/%%%/\\\n/g'  > $(I3BINDINGS)

#
# Checks.
#

$(I3FILES)/.i3-apps.log: $(I3FILES)/i3-apps
	@rm -f $@
	@shellcheck $(I3FILES)/i3-apps > $<.log
	@mv $<.log $@

$(I3FILES)/.i3-display.log: $(I3FILES)/i3-display
	@rm -f $@
	@shellcheck $(I3FILES)/i3-display > $<.log
	@mv $<.log $@

$(I3FILES)/.i3-keyboard.log: $(I3FILES)/i3-keyboard
	@rm -f $@
	@shellcheck $(I3FILES)/i3-keyboard > $<.log
	@mv $<.log $@

$(I3FILES)/.i3-mode.log: $(I3FILES)/i3-mode
	@rm -f $@
	@shellcheck $(I3FILES)/i3-mode > $<.log
	@mv $<.log $@

$(I3FILES)/.i3-mouse.log: $(I3FILES)/i3-mouse
	@rm -f $@
	@shellcheck $(I3FILES)/i3-mouse > $<.log
	@mv $<.log $@

$(I3FILES)/.i3-wrapper.log: $(I3FILES)/i3-wrapper
	@rm -f $@
	@shellcheck $(I3FILES)/i3-wrapper > $<.log
	@mv $<.log $@

#
# Customisations.
#

$(I3FILES)/.i3-custom.save: $(I3FILES)/i3-wrapper
	@[ `git diff $(I3FILES)/i3-wrapper | wc -l` -ne 0 ] && \
	awk '/i3-custom-opening-tag/,/i3-custom-closing-tag/' \
	$(I3FILES)/i3-wrapper > "$@" || touch "$@"

# The WM restarts and clears the flag after the flag has been set by
# changes that require a restart.
.restart:
	@test -e $(I3FILES)/RESTART && \
	i3-msg unmark && \
	test `i3-msg restart 2>&1 | grep [E]RROR | wc -l` -eq 0 && \
	rm -f $(I3FILES)/RESTART || \
	test ! -e $(I3FILES)/RESTART

# The WM reloads its configuration and clears the flag after the flag
# has been set by configuration file changes.
.reload:
	@test -e $(I3FILES)/RELOAD && \
	test `i3-msg reload 2>&1 | grep [E]RROR | wc -l` -eq 0 && \
	rm -f $(I3FILES)/RELOAD || \
	test ! -e $(I3FILES)/RELOAD

# I like audio feedback to confirm success.
.done:
	@eval $(BINGBONG)

#
# Done.
#
