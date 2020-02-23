--Made by Joseph Pace (Thorinori)

--Maybe not needed. Not needed especially until Windows support is the focus.
local sep = package.config:sub(1,1)
--package.cpath = package.cpath .. ";./Modules/lib/lua/5.3/?.so;"
--package.cpath = package.cpath .. ";.\\Modules\\lib\\lua\\5.3\\?.so;"
package.cpath = package.cpath .. ";./libs/UNIX/iup_installed/lib?53.so;"
package.cpath = package.cpath .. ";./libs/UNIX/iup_installed/lib?.so;" --UNIX Version of IUP
--package.cpath = package.cpath .. ";.\\libs\\Windows\\iup\\Lua53\\?53.dll;"
--package.cpath = package.cpath .. ";.\\libs\\Windows\\iup\\?53.dll;"
--package.cpath = package.cpath .. ";.\\libs\\Windows\\iup\\?.dll;"
--package.cpath = package.cpath .. ";.\\libs\\Windows\\iup\\?.lib;"
package.cpath = package.cpath .. ";.\\libs\\Windows\\iup\\Lua53\\?53.lib;"--Windows Version of IUP

require("iuplua")

--lfs = require("lfs")
require("Modules/FileIO")
require("Modules/TableFunctions")
require("Modules/DataLoader")
require("Modules/Util")
--Misc Functions

--Globals
debug_mode = true -- For debug print statements into the multitext console (Primary use of the console)
unpack = unpack or table.unpack
types_enum = {['Weapons and Shields'] = 3, ['Helmets'] = 2, ['Leg Armor'] = 2, ['Boots'] = 2,
  ['Gloves'] = 2, ['Shoulder Armor'] = 2, ['Body Armor'] = 2, ['Belts'] = 2, ['Rings'] = 2, ['Amulets'] = 2}
bodypart_to_string = {['Weapons and Shields'] = 'weapon_r', ['Helmets'] = 'helmet', ['Leg Armor'] = 'legs', ['Boots'] = 'feet',
  ['Gloves'] = 'arm', ['Shoulder Armor'] = 'Shoulder', ['Body Armor'] = 'chest_armor', ['Belts'] = 'Belt', ['Rings'] = 'ring', ['Amulets'] = 'amulet'}

affixes = generate_affixes()
organized_affixes = organize_affixes(affixes)
implicits = generate_implicits()
items = generate_items()
organized_items = organize_items(items)

output_table = {["Quality"] = 5, ["Value"] = "1"}

--Instantiate seed
math.randomseed(os.time())

--[[Configs
config = iup.config{}
config.app_name = "Wolcen Item Generator"
config:Load()]]

--Primary Components

parameter_panel = iup.vbox{iup.label{title='Item Builder',alignment='ACENTER'},padding="10x5", alignment="ALEFT"}

--scroll = iup.scrollbox{parameter_panel}
--add_child(scroll,parameter_panel)

reset_all_button = iup.button{title = "Reset All", padding="10x10", margin="10x10"}

add_child(parameter_panel,iup.hbox{reset_all_button, alignment="ACENTER",padding="10x10",margin="10x10"})

item_ilvl_field = iup.text{visiblecolumns = '3'}

add_child(parameter_panel,iup.hbox{iup.label{title='Item Level:  '},item_ilvl_field, alignment="ALEFT"})

inventory_x_field = iup.text{visiblecolumns = '3'}

add_child(parameter_panel,iup.hbox{iup.label{title='Inventory X Position:  '},inventory_x_field, alignment="ALEFT"})

inventory_y_field = iup.text{visiblecolumns = '3'}

add_child(parameter_panel,iup.hbox{iup.label{title='Inventory Y Position:  '},inventory_y_field, alignment="ALEFT"})

item_rarity_selector = iup.list{"Normal", "Magic", "Rare", "Legendary"
  ,dropdown="YES", padding="10x10", margin="10x10",visiblecolumns='20'}

add_child(parameter_panel,iup.hbox{iup.label{title='Item Rarity: '},item_rarity_selector, alignment="ARIGHT"})

item_type_selector = iup.list{"Weapons and Shields", "Helmets", "Shoulder Armor", "Gloves", "Boots", "Rings", "Belts", "Amulets", "Body Armor", "Leg Armor"
  ,dropdown="YES", padding="10x10", margin="10x10", sort="YES",visiblecolumns='20'}

add_child(parameter_panel,iup.hbox{iup.label{title='Item Type:   '},item_type_selector, alignment="ARIGHT"})

item_base_selector = iup.list{dropdown="YES", padding="10x10", margin="10x10", sort="YES", autoredraw="YES", visiblecolumns='20'}

add_child(parameter_panel,iup.hbox{iup.label{title='Item Base:   '},item_base_selector, alignment="ARIGHT"})


affix_panel = iup.vbox{}

add_child(parameter_panel,affix_panel)


json_text = iup.text{multiline = "YES", scrollbar = "YES", visiblelines = 15, visiblecolumns = 30,alignment = "ALEFT", visible="YES", readonly = "YES", wordwrap="YES"}
--modifier_text = iup.vbox{alignment = 'ALEFT', padding='10x5'}
display_panel = iup.vbox{iup.label{title='Item Preview',alignment='ACENTER'}, json_text, alignment='ALEFT',padding="10x5"}

editor_panel = iup.hbox{parameter_panel,iup.fill{},display_panel}


main_panel = iup.vbox{editor_panel}

--Setup multitext "console"
local visible = "NO"
local console = "NO"--config:GetVariable("MainWindow", "Console")
if console == "YES" then
 visible = "YES"
end
multitext = iup.text{multiline = "YES", expand = "HORIZONTAL", scrollbar = "YES", visiblelines = 12, alignment = "ALEFT", visible=visible, readonly = "YES", wordwrap="YES"}


--Menu Seperator
local horiz_sep = iup.separator{}

--File Menu
local exit_button = iup.item{title = "Exit"}

--File Menu Button Functions

function exit_button:action()
  return iup.CLOSE
end

local file_menu = iup.menu{horiz_sep,exit_button}
local file_submenu = iup.submenu{file_menu, title="File"}

--Help Menu
local about_button = iup.item{title="About"}

function about_button:action()
  iup.Message("About", "Wolcen Item Generator\nAuthor: Joseph Pace (Thorinori)")
end

local help_menu = iup.menu{about_button}
local help_submenu = iup.submenu{help_menu, title="Help"}

--View Menu

local console_button = iup.item{title="Console"}

function console_button:action()
  local curr = multitext.visible
  if curr == "YES" then
    multitext.visible = "NO"
    iup.Unmap(multitext)
    iup.Refresh(main_win)   
    --multitext:detach()
  else
    multitext.visible = "YES"
    iup.Append(main_panel,multitext)
    iup.Map(multitext)
    iup.Refresh(main_win)   
  end
  iup.Refresh(main_win)
  iup.RefreshChildren(main_win)
end

local view_menu = iup.menu{console_button}
local view_submenu = iup.submenu{view_menu, title="View"}

--Main Menu
local menu = iup.menu{file_submenu,view_submenu,help_submenu}

main_win = iup.dialog{
  menu=menu,
  main_panel,
  title = "Wolcen Item Generator",
  size="HALFxFULL",
  close_cb = exit_button.action
}

main_win:showxy(iup.CENTER,iup.CENTER)

function reset_all_button:action()
  item_ilvl_field.value = ''
  inventory_x_field.value = ''
  inventory_y_field.value = ''
  item_rarity_selector.value = 0
  item_type_selector.value = 0
  item_base_selector['1'] = nil
  reset_children(affix_panel)
  reset_output()
end

function item_ilvl_field:valuechanged_cb()
  if(self.value ~= '') then
    if(tonumber(self.value) or not self.value == '') then
      reset_children(affix_panel)
      if(tonumber(self.value) > 200) then
        self.value = "200"
      end 
      if(tonumber(self.value) < 1) then
        self.value = "1"
      end
      output_table["Level"] = tonumber(self.value)
    else
      iup.Message("Invalid Input", "Item Level must be a number between 1 and 200")
    end
    if(item_base_selector.value ~= '0') then
        item_base_selector:action(nil, item_base_selector.value, 1)
    end
  else
    reset_children(affix_panel)
    self.value = "1"
    output_table["Level"] = tonumber(self.value)
    if(item_base_selector.value ~= '0') then
        item_base_selector:action(nil, item_base_selector.value, 1)
    end
  end
end

function inventory_x_field:valuechanged_cb()
  if(self.value ~= '') then
    if(tonumber(self.value) or not self.value == '') then
      if(tonumber(self.value) > 9) then
        self.value = "9"
      end 
      if(tonumber(self.value) < 0) then
        self.value = "0"
      end
      output_table["InventoryX"] = tonumber(self.value)
    else
      iup.Message("Invalid Input", "X Value must be between 0 and 9")
    end
  else
    output_table["InventoryX"] = 0
    self.value = '0'
  end
end

function inventory_y_field:valuechanged_cb()
  if(self.value ~= '') then
    if(tonumber(self.value) or not self.value == '') then
      if(tonumber(self.value) > 4) then
        self.value = "4"
      end 
      if(tonumber(self.value) < 0) then
        self.value = "0"
      end
      output_table["InventoryY"] = tonumber(self.value)
    else
      iup.Message("Invalid Input", "Y Value must be between 0 and 4")
    end
  else
    output_table["InventoryX"] = 0
    self.value = '0'
  end
end

local num_affixes = 0
function item_rarity_selector:action(str, index, state)
  if(index == 1 and state == 1) then
    num_affixes = 0
    output_table["Rarity"] = index
    reset_children(affix_panel)
    if(item_base_selector.value ~= '0') then
      item_base_selector:action(nil, item_base_selector.value, 1)
    end
  elseif (index == 2 and state == 1) then
    num_affixes = 2
    output_table["Rarity"] = index
    reset_children(affix_panel)
    if(item_base_selector.value ~= '0') then
      item_base_selector:action(nil, item_base_selector.value, 1)
    end
  elseif (index == 3 and state == 1) then
    num_affixes = 4
    output_table["Rarity"] = index
    reset_children(affix_panel)
    if(item_base_selector.value ~= '0') then
      item_base_selector:action(nil, item_base_selector.value, 1)
    end
  elseif (index == 4 and state == 1) then
    num_affixes = 6
    output_table["Rarity"] = index
    reset_children(affix_panel)
    if(item_base_selector.value ~= '0') then
      item_base_selector:action(nil, item_base_selector.value, 1)
    end
  end
end

local item_type = ''
function item_type_selector:action(str, index, state)
  if(state == 1) then
    item_type = item_type_selector[tostring(index)]
    output_table["Type"] = types_enum[item_type]
    reset_item_bases(item_type)
    reset_children(affix_panel)
  end
end

local item_base = ''
local prefixes = {}
local suffixes = {}
function item_base_selector:action(str, index, state)
  if(state == 1) then
    reset_children(affix_panel)
    item_base = item_base_selector[tostring(index)]
    output_table["ItemType"] = items[item_base]._attr.ItemType
    if(items[item_base]._attr.BodyPart == 'weapon_r') then
      output_table["Armor"] = nil
      output_table["Weapon"] = {["Name"] = item_base, ["DamageMin"] = ((output_table["Quality"] * 10/100) + 1) * tonumber(items[item_base]._attr.LowDamage_Max)
      ,["DamageMax"] = ((output_table["Quality"] * 10/100) + 1) * tonumber(items[item_base]._attr.HighDamage_Max)
      ,["ResourceGeneration"] = tonumber(items[item_base]._attr.ResourceGain_Max)}
    else
      output_table["Weapon"] = nil
      output_table["Armor"] = {["Name"] = item_base}
      local item_class = items[item_base]._attr.ArmorType

      if(item_class == "Mage") then
        output_table["Armor"].Armor = tonumber(items[item_base]._attr.ForceShieldMax)
      elseif(item_class == "Rogue") then
        output_table["Armor"].Armor = tonumber(items[item_base]._attr.ForceShieldMax)
        output_table["Armor"].Health = tonumber(items[item_base]._attr.HealthBonusMax)
      elseif(item_class == "Heavy") then
        output_table["Armor"].Resistance = tonumber(items[item_base]._attr.AllResistanceMax)
      else
      output_table["Armor"].Health = tonumber(items[item_base]._attr.HealthBonusMax)
      output_table["Armor"].Resistance = tonumber(items[item_base]._attr.AllResistanceMax)
      end
    end
    prefixes = generate_valid_affixes(items[item_base],tonumber(item_ilvl_field.value) or 1, 'prefix')
    suffixes = generate_valid_affixes(items[item_base],tonumber(item_ilvl_field.value) or 1, 'suffix')
    generate_implicit_affixes()
    for i=1, (num_affixes/2) do
      gen_affix_selector(prefixes,'Prefixes')
    end
    for i=1, (num_affixes/2) do
      gen_affix_selector(suffixes,'Suffixes')
    end
  end
end

-- to be able to run this script inside another context (From IUP Documentation)
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
  iup.Close()
end
