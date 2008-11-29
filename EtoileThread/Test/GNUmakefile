include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_CPPFLAGS += -std=c99
ADDITIONAL_OBJCFLAGS += -I.  -Wall -W -Wunreachable-code -Winline -Werror -Wno-unused -Wno-format

APP_NAME = ThreadTest

$(APP_NAME)_OBJC_FILES = ETThreadTestEric.m
$(APP_NAME)_GUI_LIBS = -lEtoileFoundation 

include $(GNUSTEP_MAKEFILES)/application.make
