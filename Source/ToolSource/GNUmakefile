include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_OBJCFLAGS = -Wall -Wno-import 

TOOL_NAME = ukrun

ukrun_OBJC_FILES = main.m

ukrun_OBJC_LIBS = -lUnitKit
ukrun_LIB_DIRS = -L../FrameworkSource/$(GNUSTEP_OBJ_DIR) -L../FrameworkSource/UnitKit.framework/Versions/Current
ukrun_INCLUDE_DIRS = -I../

include $(GNUSTEP_MAKEFILES)/tool.make

