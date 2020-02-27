# Wolcen Item Generator
An item generator for the game Wolcen, written in Lua

DISCLAIMER: I do not own the contents of GameFiles, these are files pulled directly from the game that are used to generate valid items. All credit to the Developers of Wolcen (Wolcen Studio) for their game files. If this is a problem, please get in contact with me and I will remove the files and modify how they are acquired.

__**REQUIREMENTS:**__
Lua 5.1 or higher

__**IMPORTANT INFORMATION FOR RUNNING ON WINDOWS**__
You you will need get Lua on Windows, I would recommend the latest release here: https://github.com/rjpcomputing/luaforwindows/releases with a standard install.


__**Instructions:**__
1) Install Lua
2) Download as Zip (or clone the repo if you want)
3) Run the program:

    a) UNIX: Run Launch.sh or lua ItemGen.lua
    
    b) Windows: Double Click "Wolcen Item Generator.vbs" for no console window, OR run Launch.bat if you DO want the console.
    
__**GENERATING ITEMS**__
At the time of this writing, you will get an error if you try to modify any affixes before you have your implicit affixes selected. You can close the error, set the implicit, then continue just fine without the error anymore.
    
__**USING THE OUTPUT**__

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

This will result in something that looks like
```
		},{"InventoryY":4,"Type":2,"ItemType":"Foot Armor","MagicEffects":{"Default":[{"EffectId":"toughness_pts","MaxStack":1,"EffectName":"implicit_toughness_armor_1","bDefault":1,"Parameters":[{"semantic":"AttributeFlatInt","value":3}]}],"RolledAffixes":[{"MaxStack":1,"Parameters":[{"semantic":"CharacteristicScoreInt","value":105}],"EffectName":"ar_criticalchance_score_11","EffectId":"criticalchance_score"}]},"Armor":{"Name":"Heavy_Boots_Tier1","Resistance":4},"InventoryX":9,"Value":"1","Level":161,"Rarity":4,"Quality":5} ],
	"InventoryBelt":	[],
```

or like this if you choose to move the ], directly infront of InventoryBelt
```
		},{"InventoryY":4,"Type":2,"ItemType":"Foot Armor","MagicEffects":{"Default":[{"EffectId":"toughness_pts","MaxStack":1,"EffectName":"implicit_toughness_armor_1","bDefault":1,"Parameters":[{"semantic":"AttributeFlatInt","value":3}]}],"RolledAffixes":[{"MaxStack":1,"Parameters":[{"semantic":"CharacteristicScoreInt","value":105}],"EffectName":"ar_criticalchance_score_11","EffectId":"criticalchance_score"}]},"Armor":{"Name":"Heavy_Boots_Tier1","Resistance":4},"InventoryX":9,"Value":"1","Level":161,"Rarity":4,"Quality":5} 
], "InventoryBelt":	[],
```

That mess will get formatted properly by the game once it loads. If you want to add multiple items at a time, just keep adding "," between the }] at the end to keep adding more. Note that the item slots DO matter, so don't try to put every item in the same spot (That is what Inventory X and Y are for in the program. Don't try to put stuff in Y =  5, since that is the bottom row and most items take 2 vertical slots)

__**KNOWN BUGS AND ISSUES**__
1) Using internal names, not localized names.
2) Some belts not included currently. They don't have implicits and I don't remember there being any belts ingame without implicits that are actually used right now.
