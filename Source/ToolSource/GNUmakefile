include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import 

TOOL_NAME = ukrun

ukrun_OBJC_FILES = main.m

ukrun_TOOL_LIBS = -lUnitKit -lgnustep-gui
ADDITIONAL_LIB_DIRS = -L../FrameworkSource/$(GNUSTEP_OBJ_DIR)
ukrun_INCLUDE_DIRS = -I../

include $(GNUSTEP_MAKEFILES)/tool.make

