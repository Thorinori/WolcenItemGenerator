# Wolcen Item Generator
An item generator for the game Wolcen, written in Lua

DISCLAIMER: I do not own the contents of GameFiles, these are files pulled directly from the game that are used to generate valid items. All credit to the Developers of Wolcen (Wolcen Studio) for their game files.

REQUIREMENTS:
Lua 5.1 or higher

IMPORTANT INFORMATION FOR RUNNING ON WINDOWS
You you will need get Lua on Windows, I would recommend the latest release here: https://github.com/rjpcomputing/luaforwindows/releases with a standard install.


Instructions:
1) Install Lua
2) Download as Zip (or clone the repo if you want)
3) Run the program:
    a) UNIX: Run Launch.sh or lua ItemGen.lua
    b) Windows: Double Click "Wolcen Item Generator.vbs" for no console window, run Launch.bat if you DO want the console.
    
    
USING THE OUTPUT

On the right side of the program, you will see a box that says "Item Preview", once there is text in there and you have made the item you wanted. Click into the box, and hit Ctrl + A to select it all, then Ctrl + C to copy it.

The items are currently formatted to go into your inventory directly, so to add the item to your character, go to your savefile at
```
%UserProfile%\Saved Games\wolcen\savegames\characters
```
and open up the character file that you want to give the item.

Then scroll down until you see
```
		}],
	"InventoryBelt":	[],
```
Insert a ',' between }] so it looks like },], then paste the item after the ','
