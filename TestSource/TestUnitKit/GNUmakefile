include $(GNUSTEP_MAKEFILES)/common.make

PRINT_PROJECT_NAME = NO

BUNDLE_NAME = TestUnitKit

# For running the test suite without installing TestFramework
$(BUNDLE_NAME)_LDFLAGS = -Wl,-rpath=$(BUILD_DIR)
$(BUNDLE_NAME)_NEEDS_GUI = no

$(BUNDLE_NAME)_BUNDLE_LIBS = -lUnitKit -lTestFramework $(FND_LIBS)

$(BUNDLE_NAME)_OBJC_FILES = $(wildcard *.m)

include $(GNUSTEP_MAKEFILES)/bundle.make
-include ../../../../etoile.make

export TEST_BUNDLE_PATH = $(PROJECT_DIR)/TestSource/TestBundle/TestBundle.bundle 
export TEST_BUNDLE_LINK_PATH = $(PROJECT_DIR)/TestSource/TestUnitKit/TestBundle.bundle 

after-all::
	$(ECHO_NOTHING) \
	if [ ! -e $(TEST_BUNDLE_LINK_PATH) ]; then \
		ln -s $(TEST_BUNDLE_PATH) $(TEST_BUNDLE_LINK_PATH); \
	fi; \
	$(END_ECHO)

after-clean::
	rm -f $(TEST_BUNDLE_LINK_PATH)
