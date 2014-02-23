#!/bin/bash

# Install UnitKit

git clone https://github.com/etoile/UnitKit.git
cd UnitKit
sudo xcodebuild -target ukrun -configuration Release clean install
cd ..

# build & run the tests
./test-macosx.sh
