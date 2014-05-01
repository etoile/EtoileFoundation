EtoileFoundation Mac OS X and iOS INSTALL
=========================================

Required software
-----------------

In addition to Xcode 4 or higher, you need Mac OS X 10.6 or higher to compile 
EtoileFoundation and EtoileXML.


Build and Install
-----------------

For a simple build, open EtoileFoundation.xcodeproj and choose EtoileFoundation, 
EtoileFoundation (iOS) or EtoileXML in the Scheme menu.

To install in /Library/Frameworks on Mac OS X, do the build in the shell: 

	sudo xcodebuild -scheme EtoileFoundation -configuration Release clean install DSTROOT=/Library INSTALL_PATH=/Frameworks
	sudo xcodebuild -scheme EtoileXML -configuration Release clean install DSTROOT=/Library INSTALL_PATH=/Frameworks

**Note:** By default, INSTALL_PATH is set to @rpath and DSTROOT to the project 
directory.


iOS support
-----------

To use the resulting library in your own project, the EtoileFoundation headers 
and library have to be made visible in the project search paths as explained 
below.

First, create a symbolic link inside your project directory (the one that 
contains the Xcode project) pointing on the EtoileFoundation directory :

	ln -s path/to/EtoileFoundation path/to/your/project

You must then tweak your project build setting $HEADER_SEARCH_PATHS (in the 
Search Paths section) to include the line below:

	$(PROJECT_DIR)/EtoileFoundation/build/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)

Finally link the library, and include the EtoileFoundation/Resources directory 
content among your project resources. You are now ready to use EtoileFoundation 
in your project by importing EtoileFoundation.h as you would usually:

	#import <EtoileFoundation/EtoileFoundation.h>


Test suite
----------

UnitKit is required, see <https://github.com/etoile/UnitKit>

**Note:** If you have the entire (Etoile repository)[https://github.com/etoile/Etoile], 
UnitKit is built together with EtoileFoundation (as a workspace subproject).

To produce a test bundle and run the test suite, open EtoileFoundation.xcodeproj 
and choose TestEtoileFoundation or TestEtoileFoundation (iOS) in the Scheme menu.


Trouble
-------

Give us feedback! Tell us what you like; tell us what you think could be better. 
Send bug reports and patches to <https://github.com/etoile/EtoileFoundation>. 
