include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_CPPFLAGS += -std=c99
ADDITIONAL_OBJCFLAGS += -I.  -Wall -W -Wunreachable-code -Winline -Werror -Wno-unused -Wno-format

TOOL_NAME = ThreadTest

$(TOOL_NAME)_OBJC_FILES = ETThreadTestEric.m
$(TOOL_NAME)_LDFLAGS = -lEtoileFoundation  -lgnustep-gui

include $(GNUSTEP_MAKEFILES)/tool.make
