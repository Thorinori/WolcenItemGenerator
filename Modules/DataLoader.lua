require("Modules/FileIO")
require("Modules/TableFunctions")
local xml = require('Modules/xml2lua')
local handler = require('Modules/xmlhandler/tree')
local lfs = require('lfs')

local parser = xml.parser(handler)

local affixes = {}
local items = {}
local implicits = {}

function generate_affixes()
    local path = './GameFiles/Affixes'
    for f in lfs.dir(path) do
        if(f ~= '.' and f ~= '..') then
            local full_path = path..'/'..f
            local s = io.open(full_path):read('*a')
            parser:parse(s)
            for _,v in pairs(handler.root.MetaData.Affix) do
                if(not v.DropParams._attr.CraftOnly) then
                    affixes[v._attr.AffixId] = v
                    local count = 0
                    local types = {}
                    for j, k in pairs(v.MagicEffect.LoRoll._attr) do
                        table.insert(types, j)
                        count = count + 1
                    end
                    affixes[v._attr.AffixId].count = count
                    table.sort(types)
                    affixes[v._attr.AffixId].roll_type = types
                end
            end
        end
    end
    return affixes
end

function generate_implicits()
    local path = './GameFiles/Implicits'
    for f in lfs.dir(path) do
        if(f ~= '.' and f ~= '..') then
            local full_path = path..'/'..f
            local s = io.open(full_path):read('*a')
            parser:parse(s)
            for _,v in pairs(handler.root.MetaData.Affix) do
                if(not v.DropParams._attr.CraftOnly) then
                    implicits[v._attr.AffixId] = v
                    local count = 0
                    local types = {}
                    for j, k in pairs(v.MagicEffect.LoRoll._attr) do
                        table.insert(types, j)
                        count = count + 1
                    end
                    implicits[v._attr.AffixId].count = count
                    table.sort(types)
                    implicits[v._attr.AffixId].roll_type = types
                end
            end
        end
    end
    return implicits
end

function generate_items()
    local path = './GameFiles/Items'
    for f in lfs.dir(path) do
        if(f ~= '.' and f ~= '..') then
            local full_path = path..'/'..f
            local s = io.open(full_path):read('*a')
            parser:parse(s)
            for k, _ in pairs(handler.root.MetaData) do
                for _,v2 in pairs(handler.root.MetaData[k]) do
                    for _,v3 in pairs(v2) do
                        items[v3._attr.Name] = v3
                    end
                end
            end
        end
    end
    return items
end