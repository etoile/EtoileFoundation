include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = FrameworkSource ToolSource

ifneq (,$(filter clean distclean,$(MAKECMDGOALS)))
	testsource ?= yes
endif

ifeq ($(test), yes)
	testsource ?= yes
endif

ifeq ($(testsource), yes)
SUBPROJECTS += \
	TestSource/TestFramework \
	TestSource/TestBundle \
	TestSource/UnitKitTests
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble
