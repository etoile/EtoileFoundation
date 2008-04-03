include $(GNUSTEP_MAKEFILES)/common.make

# We reset PROJECT_DIR provided by etoile.make to match the subproject since 
# etoile.make doesn't detect and handle such embedded project
PROJECT_DIR = $(CURDIR)

FRAMEWORK_NAME = EtoileThread
DOCUMENT_NAME = $(FRAMEWORK_NAME)

$(FRAMEWORK_NAME)_OBJCFLAGS += -std=c99

$(FRAMEWORK_NAME)_OBJC_FILES = \
	ETThread.m \
	ETThreadProxyReturn.m \
	ETThreadedObject.m \
	NSObject+Threaded.m \
	NSObject+Futures.m

$(FRAMEWORK_NAME)_HEADER_FILES = \
	ETThread.h \
	ETThreadProxyReturn.h \
	ETThreadedObject.h \
	NSObject+Threaded.h \
	NSObject+Futures.h

$(DOCUMENT_NAME)_AGSDOC_FILES = $(⁽FRAMEWORK_NAME)_HEADER_FILES)

include $(GNUSTEP_MAKEFILES)/documentation.make
-include ../../../etoile.make
include $(GNUSTEP_MAKEFILES)/framework.make
