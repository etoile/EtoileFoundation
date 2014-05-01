EtoileFoundation GNUstep INSTALL
================================

You need to have the GNUstep core libraries installed in order to compile and 
use EtoileFoundation, see <http://www.gnustep.org/>. The core packages are, at a 
minimum:

  - clang 3.3 or higher
  - libobjc2 trunk
  - gnustep-make 2.6.6 or higher
  - gnustep-base trunk


Build and Install
-----------------

Square brackets "[ ]" are used to indicate optional parameters.

To build and install the EtoileFoundation and EtoileXML frameworks (use gmake 
on non-GNU systems):

	make
	
	[sudo [-E]] make install


Test suite
---------- 

UnitKit is required, see <https://github.com/etoile/UnitKit>

**Note:** If you have the entire (Etoile repository)[https://github.com/etoile/Etoile], 
UnitKit is built together with CoreObject, by running 'make' in Frameworks or 
any other parent directories.

Square brackets "[ ]" are used to indicate optional parameters.

To produce a test bundle and run the test suite:

	make test=yes 
	
	ukrun [-q]


Trouble
-------

Give us feedback! Tell us what you like; tell us what you think could be better. 
Send bug reports and patches to <https://github.com/etoile/EtoileFoundation>.
