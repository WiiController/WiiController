#!/usr/bin/osascript

tell application "Finder"
	tell disk "WiiController"
		open
		tell container window
			set current view to icon view
			set toolbar visible to false
			set statusbar visible to false
			set the bounds to {120, 141, 612, 380}
		end tell
		set opts to icon view options of container window
		tell opts
			set arrangement to not arranged
			set shows item info to false
			set icon size to 128
			set text size to 12
		end tell
		set background picture of opts to file ".images:background.png"
		set extension hidden of item "WiiController.app" to true
		set position of item "WiiController.app" to {100, 80}
		set position of item "Applications" to {380, 80}
		close
		open
		update without registering applications
	end tell
	delay 5
end tell
