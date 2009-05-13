include $(GNUSTEP_MAKEFILES)/common.make

# We reset PROJECT_DIR provided by etoile.make to match the subproject since 
# etoile.make doesn't detect and handle such embedded project
PROJECT_DIR = $(CURDIR)

ifeq ($(test), yes)
BUNDLE_NAME = EtoileThread
$(BUNDLE_NAME)_LDFLAGS += -lUnitKit
else
FRAMEWORK_NAME = EtoileThread
DOCUMENT_NAME = $(FRAMEWORK_NAME)
$(FRAMEWORK_NAME)_VERSION = 0.2
$(DOCUMENT_NAME)_AGSDOC_FILES = $($(FRAMEWORK_NAME)_HEADER_FILES)
endif

ifeq ($(GNUSTEP_TARGET_CPU), ix86)
 ADDITIONAL_OBJCFLAGS += -march=i586
endif

# -lm for FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

EtoileThread_OBJCFLAGS += -std=c99

EtoileThread_OBJC_FILES = \
	ETThread.m \
	ETThreadProxyReturn.m \
	ETThreadedObject.m \
	NSObject+Threaded.m \
	NSObject+Futures.m
ifeq ($(test), yes)
EtoileThread_OBJC_FILES += \
	TestThread.m
endif

EtoileThread_HEADER_FILES = \
	ETThread.h \
	ETThreadProxyReturn.h \
	ETThreadedObject.h \
	NSObject+Threaded.h \
	NSObject+Futures.h


ifeq ($(test), yes)
include $(GNUSTEP_MAKEFILES)/bundle.make
-include ../../../etoile.make
else
include $(GNUSTEP_MAKEFILES)/documentation.make
-include ../../../etoile.make
include $(GNUSTEP_MAKEFILES)/framework.make
endif
