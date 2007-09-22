include $(GNUSTEP_MAKEFILES)/common.make

#
# kqueue support check
#
ifneq ($(findstring freebsd, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

ifneq ($(findstring netbsd, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

kqueue_supported ?= no

FRAMEWORK_NAME = EtoileFoundation
VERSION = 0.1

EtoileFoundation_SUBPROJECTS = Source

EtoileFoundation_HEADER_FILES_DIR = Headers

EtoileFoundation_HEADER_FILES = \
		EtoileFoundation.h\
        EtoileCompatibility.h \
		ETCArray.h\
		Macros.h\
        NSFileManager+NameForTempFile.h \
        UKMainThreadProxy.h \
        UKPluginsRegistry.h \
        UKPushbackMessenger.h \
        UKThreadMessenger.h \
        OSBundleExtensionLoader.h

ifeq ($(kqueue_supported), yes)

EtoileFoundation_HEADER_FILES += \
        UKKQueue.h \
        UKFileWatcher.h

endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include ../../etoile.make
include $(GNUSTEP_MAKEFILES)/framework.make

