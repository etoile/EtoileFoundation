include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import 
ADDITIONAL_LIB_DIRS = -L../FrameworkSource/$(GNUSTEP_OBJ_DIR)
ADDITIONAL_INCLUDE_DIRS = -I../

TOOL_NAME = ukrun

ukrun_TOOL_LIBS = -L../FrameworkSource/UnitKit.framework/ -lUnitKit -lgnustep-gui

ukrun_OBJC_FILES = main.m

include $(GNUSTEP_MAKEFILES)/tool.make

