include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = Source/FrameworkSource Source/ToolSource

ifneq (,$(filter clean distclean,$(MAKECMDGOALS)))
	testsource ?= yes
endif

ifeq ($(test), yes)
	testsource ?= yes
endif

ifeq ($(testsource), yes)
SUBPROJECTS += \
	Source/TestSource/TestFramework \
	Source/TestSource/TestBundle \
	Source/TestSource/UnitKitTests
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble
