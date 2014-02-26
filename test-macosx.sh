#!/bin/bash

# install ukrun first
sudo xcodebuild -target ukrun -configuration Release clean install

# This is used in the "Run Script" phase of each of the targets we build,
# if it is set to 1, the resulting binary is run as part of the xcodebuild
export TEST_AUTORUN=1 

xcodebuild -project UnitKit.xcodeproj -scheme TestUnitKit
teststatus=$?

# printstatus 'message' status
function printstatus {
  if [[ $2 == 0 ]]; then
    echo "(PASS) $1"
  else
    echo "(FAIL) $1"
  fi
}

echo "UnitKit Tests Summary"
echo "====================="
printstatus UnitKit $teststatus

exitstatus=$(( teststatus ))
exit $exitstatus
