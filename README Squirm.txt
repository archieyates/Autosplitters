For the Squirm autosplitter to work a few things must be checked.

The game must be Version 3.0 (latest) version as the autosplitter relies on the save file changes made in that version.

The autosplitter determines what part of the save to read based on your category and split number. To this end your splits need to follow the standard split setup which will be detailed below.

Any%
- Ludo's Key (can configure settings to use killing Ludo instead)
- Killing Skelord (can configure settings to use getting Skelord key instead)
- Fatty's Key (can configure settings to use killing Fatty instead)
- Castle Key
- Tower Key
- Cotton's Key
- Reaching Crackers
- Final split

100%
- First Star 
- Ludo's Key
- Spook Star
- Skelord's Key
- Ice Star
- Fatty's Key
- Castle Star
- Castle Key
- Tower Star
- Tower Key
- Space Star
- Space Key
- Reaching Crackers
- Post-Float Screen

NOTE: Final split for talking to heart is not supported

You must have an environment variable set up called "squirm" that points at the SQUIRM folder in your steam directory.

on Windows you can do this by:
- Make sure LiveSplit is closed first
- hitting Windows Key & R to bring up the Run prompt
- entering "sysdm.cpl" and hitting "OK"
- On the System Properties windo click the "Advanced" tab
- Select the "Environment Variables" button
- Click "New" under the "User variables" section
- Call your new variable "squirm" (all lower case)
- The path of the variable should be to your SQUIRM folder in the steam directory
- e.g. E:\Program Files (x86)\Steam\steamapps\common\SQUIRM
- Once this is done you can re-open Livesplit

An illustrated guide can be found here: https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html#:~:text=Environment%20variables%2C%20as%20the%20name,folders%20that%20might%20contain%20executables. contains a guide on setting these up.

