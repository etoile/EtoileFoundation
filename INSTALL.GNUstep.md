UnitKit
=======

Required software
-----------------

You need to have the GNUstep core libraries installed in order to
compile and use UnitKit. The core packages are, at a minimum:

   * gnustep-make (recent release no older than a year)

   * gnustep-base (recent release no older than a year)

See <http://www.gnustep.org/> for further information.


Build and Install
-----------------

Square brackets "[ ]" are used to indicate optional parameters.

Steps to build:

	make

	[sudo [-E]] make install


Test suite (to test UnitKit with itself)
----------------------------------------

Square brackets "[ ]" are used to indicate optional parameters.

To produce a test bundle and run the test suite:

	make test=yes 
	
	ukrun [-q] Source/TestSource/UnitKitTests/UnitKitTestBundle.bundle


Trouble
-------

Give us feedback! Tell us what you like; tell us what you think
could be better. Send bug reports and patches to <etoile-track@gna.org>.
