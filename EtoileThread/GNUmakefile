include $(GNUSTEP_MAKEFILES)/common.make

CFLAGS += -g 

DOCUMENT_NAME = ETThread
FRAMEWORK_NAME = ETThread

ETThread_OBJC_FILES = \
	ETThread.m \
	ETThreadProxyReturn.m \
	ETThreadedObject.m \
	NSObject+Threaded.m \
	NSObject+Futures.m

ETThread_HEADER_FILES = \
	ETThread.h \
	ETThreadProxyReturn.h \
	ETThreadedObject.h \
	NSObject+Threaded.h \
	NSObject+Futures.h

ETThread_AGSDOC_FILES = $(ETThread_HEADER_FILES)

include $(GNUSTEP_MAKEFILES)/documentation.make
-include ../../../etoile.make
include $(GNUSTEP_MAKEFILES)/framework.make
