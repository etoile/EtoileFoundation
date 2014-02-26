include $(GNUSTEP_MAKEFILES)/common.make

PRINT_PROJECT_NAME = NO

TOOL_NAME = ukrun

# For UnitKit, etoile.make after-all:: is not executed before all subprojects 
# are built. Hence UnitKit.framework is not present in the Build directory at 
# 'ukrun' build time.
ukrun_INCLUDE_DIRS = -I..
ukrun_LIB_DIRS = -L../UnitKit.framework
ukrun_TOOL_LIBS = -lUnitKit $(FND_LIBS)

ukrun_OBJC_FILES = main.m

include $(GNUSTEP_MAKEFILES)/tool.make
-include ../../../etoile.make
