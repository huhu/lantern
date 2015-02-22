#!/bin/bash

function die() {
  echo $*
  exit 1
}

if [ $# -lt "1" ]
then
    die "$0: Version required"
fi

echo "Installing svgexport tool if necessary (requires nodejs)"
which svgexport || npm install -g svgexport

echo "Installing appdmg tool if necessary (requires nodejs)"
which appdmg || npm install -g appdmg

binary="lantern_darwin_amd64"
dmg="Lantern.dmg"

if [ ! -f $binary ]
then
    die "Please compile lantern using ./crosscompile.bash or ./tagandbuild.bash before running package_osx.bash"
fi

if [ -e "Lantern.app" ]
then
	rm -Rf Lantern.app || die "Could not remove existing Lantern.app"
fi
cp -R Lantern.app_template Lantern.app || die "Could not create Lantern.app"
cp -f $binary Lantern.app/Contents/MacOS/lantern || die "Could not move lantern into Lantern.app"
codesign -s "Developer ID Application: Brave New Software Project, Inc" Lantern.app || echo "Unable to sign Lantern.app!!!"

echo "About to chown Lantern.app to root:wheel, you may need to enter your password"

if [ -e $dmg ]
then
	rm -Rf lantern.dmg || die "Could not remove existing lantern.dmg"
fi

echo "Generating background image"
sed "s/__VERSION__/$1/g" dmgbackground.svg > dmgbackground_versioned.svg
svgexport dmgbackground_versioned.svg dmgbackground.png 600:400

appdmg lantern.dmg.json $dmg || "Could not package Lantern.app into dmg"