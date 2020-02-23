local json = require('Modules/json')

function debug(s)
  if debug_mode then
    multitext.append = '['..os.date('%H:%M:%S')..']: ' .. s
  end
end

--String Splitting for Adding Lists (Found at https://stackoverflow.com/questions/1426954/split-string-in-lua)
function split (inputstr, sep)
  if(inputstr ~= '' and inputstr ~= nil) then
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
  end
  return nil
end

function add_child(parent, child)
    iup.Append(parent,child)
    iup.Map(child)
    iup.Refresh(parent)
end

function check_keywords(affix_words, item_words,mode)
  local count = 0
  local found = 0
  local affix_word_table = split(affix_words,',')
  for k,v in pairs(split(item_words, ',')) do
    if(table.check(affix_word_table,v)) then
      found = found + 1
    end
      count = count + 1
  end
  if(mode == 'mandatory') then
    return (found >= #affix_word_table)
  else
    return (found > 0)
  end
end

function generate_valid_affixes(item, ilvl,affix_type)
  local found_affixes = {}
  for _,v in pairs(affixes) do
    local optionals = v.DropParams.Keywords._attr.OptionalKeywords
    local mandatory = v.DropParams.Keywords._attr.MandatoryKeywords
    local min_ilvl = v.DropParams.ItemLevel._attr.LevelMin
    local max_ilvl = v.DropParams.ItemLevel._attr.LevelMax
    local mandatory_match = true
    local optionals_match = true
    if(mandatory) then
      mandatory_match = check_keywords(string.lower(mandatory),string.lower(item._attr.Keywords),'mandatory')
    end
    if(optionals) then
      optionals_match = check_keywords(string.lower(optionals), string.lower(item._attr.Keywords),'optional')
    end
    if(mandatory_match and optionals_match) then
      if(tonumber(min_ilvl) <= ilvl and ilvl <= tonumber(max_ilvl)) then
        if(not table.check(found_affixes, v)) then
            if(v._attr.AffixType == affix_type) then
                table.insert(found_affixes, v)
            end
        end
      end
    end
  end

  return found_affixes
end

--Index 1 is Max, Index 2 is Min
function get_low_affix_roll(affix, min_or_max) --Only used for multiple value rolls
  local tmp = ''
  if(min_or_max == 'max') then
      tmp = affix.MagicEffect.LoRoll._attr[affix.roll_type[1]]
  else
    tmp = affix.MagicEffect.LoRoll._attr[affix.roll_type[2]]
  end
  return tmp
end

function get_high_affix_roll(affix, min_or_max) --Only used for multiple value rolls
  local tmp = ''
  if(min_or_max == 'max') then
      tmp = affix.MagicEffect.HiRoll._attr[affix.roll_type[1]]
  else
    tmp = affix.MagicEffect.HiRoll._attr[affix.roll_type[2]]
  end
  return tmp
end

function get_implicits(item)
  return split(item._attr.ImplicitAffixes,',')
end

function organize_items(items)
  local organized = {}
  for k,v in pairs(items) do
    if(not organized[v._attr.BodyPart]) then
      organized[v._attr.BodyPart] = {}
    end
    table.insert(organized[v._attr.BodyPart],v)
  end
  return organized
end

function organize_affixes(affixes)
  local organized = {}
  for k,v in pairs(affixes) do
    if(not organized[v._attr.AffixType]) then
      organized[v._attr.AffixType] = {}
    end
    table.insert(organized[v._attr.AffixType],v)
  end
  return organized
end

function get_affix(affix_type, name)
  for k,v in pairs(organize_affixes[affix_type]) do
    if(v._attr.Name == name) then
      return v
    end
  end
end

function reset_item_bases(item_type)
  item_bases = {}
  for _,v in ipairs(organized_items[bodypart_to_string[item_type]]) do
    if(v._attr.BodyPart == bodypart_to_string[item_type]) then
      table.insert(item_bases, v._attr.Name)
    end
  end

  item_base_selector['1'] = nil
  for k,v in ipairs(item_bases) do
    item_base_selector[tostring(k)] = v
  end
  iup.RefreshChildren(main_win)
end

function get_valid_implicits(item_imps)
  if(item_imps) then
    local imps = {}
    for k,v in pairs(implicits) do
      for _,v2 in pairs(item_imps) do
        if(v._attr.AffixId == v2) then
          table.insert( imps, v )
        end
      end
    end

    return imps
  end
  return nil
end

function gen_affix_selector(valid_affixes,affix_type)
  local affix_choice = iup.list{dropdown="YES", padding="10x10", margin="10x10",visiblecolumns='20', sort="YES"}
  local choices = {}
  for _,v in ipairs(valid_affixes) do
    table.insert(choices, v._attr.AffixId)
  end

  affix_choice['1'] = nil
  for k,v in ipairs(choices) do
    affix_choice[tostring(k)] = v
  end
  local sliders = iup.vbox{}
  add_child(affix_panel,iup.vbox{iup.hbox{iup.label{title=affix_type..':      '},affix_choice},sliders})
  iup.RefreshChildren(main_win)

  function affix_choice:action(str, index, state)
    if(state == 1) then
      reset_children(sliders)
      local affix_name = affix_choice[affix_choice.value]
      local full_affix = affixes[affix_name] or implicits[affix_name]
      if(full_affix.count > 1) then
        local min_val = iup.val{min=get_low_affix_roll(full_affix,'min'), max=get_low_affix_roll(full_affix,'max')}
        local max_val = iup.val{min=get_high_affix_roll(full_affix,'min'), max=get_high_affix_roll(full_affix,'max')}

        min_val.value = ((tonumber(min_val.max) + tonumber(min_val.min))/2)
        max_val.value = ((tonumber(max_val.max) + tonumber(max_val.min))/2)

        local min_label = iup.label{title=min_val.value}
        local max_label = iup.label{title=max_val.value}

        local min = iup.hbox{iup.label{title='Minimum: '},min_val,min_label}
        local max = iup.hbox{iup.label{title='Maximum: '},max_val,max_label}
        
        function min_val:valuechanged_cb()
            if(self.value > max_val.value) then
              self.value = max_val.value
            end
            min_label.title = tostring(self.value)
            generate_output(self.value)
        end
        
        function max_val:valuechanged_cb()
          if(self.value < min_val.value) then
            self.value = min_val.value
          end
          max_label.title = tostring(self.value)
          generate_output(self.value)
        end
        add_child(sliders, min)
        add_child(sliders, max)

      else
        local val = iup.val{min=full_affix.MagicEffect.LoRoll._attr[full_affix.roll_type], max=full_affix.MagicEffect.HiRoll._attr[full_affix.roll_type]}
        if(val.min == val.max) then
          val.max = val.max + .0000000001
        end
        val.value = ((tonumber(val.max) + tonumber(val.min))/2)

        local label = iup.label{title=val.value}

        local tmp = iup.hbox{iup.label{title=full_affix.roll_type},val,label}

        function val:valuechanged_cb()
            label.title = self.value
            generate_output(self.value)
        end

        add_child(sliders, tmp)
      end
    end
  end
end

function reset_children(comp)
  if(iup.GetChildCount(comp) > 0) then
    local next = iup.GetNextChild(comp,nil)
    while(next) do
      local last = next
      next = iup.GetBrother(last)
      iup.Unmap(last)
      iup.Destroy(last)
      iup.Refresh(comp)
    end
  end
end

function reset_output()
  output_table = {["Quality"] = 5, ["Value"] = 1}
end

function regen_output()
  item_ilvl_field:valuechanged_cb()
  item_rarity_selector:action(nil, item_rarity_selector.value, 1)
  item_type_selector:action(nil, item_type_selector.value, 1)
  item_base_selector:action(nil, item_base_selector.value, 1)
end

function generate_implicit_affixes()
  local item = items[item_base_selector[tostring(item_base_selector.value)]]
  local keywords = get_implicits(item)
  local imp = get_valid_implicits(keywords)
  if(imp) then
    for i=1, #imp do
      gen_affix_selector(imp,'Implicit')
    end
  end
end

function generate_output(s)
  --regen_output()

  output_table["MagicEffects"] = {}
  local item = items[item_base_selector[tostring(item_base_selector.value)]]
  local keywords = get_implicits(item)
  local current_affix = iup.GetNextChild(affix_panel,nil)
  local last = current_affix
  if(#keywords > 1) then
    local Default = {}
    for i=1, #keywords do
      local imp = {}
      local affix_info = iup.GetNextChild(last,nil)
      local sliders = iup.GetNextChild(iup.GetBrother(affix_info),nil)
      local effect_dropdown = iup.GetBrother(iup.GetNextChild(affix_info,nil))
      local effectid = effect_dropdown[effect_dropdown.value]
      if(effectid) then 
        local semantic = iup.GetNextChild(sliders, nil)
        local val = iup.GetNextChild(sliders,semantic)
        imp = {["EffectId"] = implicits[effectid].MagicEffect._attr.EffectId, ["EffectName"] = effectid, ["MaxStack"] = 1, ["bDefault"] = 1,
                                            ["Parameters"] = {[1] = {
                                              ["semantic"] = semantic.title,
                                              ["value"] = math.floor(tonumber(val.value))}}}
        table.insert(Default,imp)
      end
      last = iup.GetBrother(last)
    end
    output_table.MagicEffects.Default = Default
  else
    local affix_info = iup.GetNextChild(last,nil)
    local sliders = iup.GetNextChild(iup.GetBrother(affix_info),nil)
    local effect_dropdown = iup.GetBrother(iup.GetNextChild(affix_info,nil))
    local effectid = effect_dropdown[effect_dropdown.value]
    local semantic = iup.GetNextChild(sliders, nil)
    local val = iup.GetNextChild(sliders,semantic)
    output_table.MagicEffects.Default = {[1] = {["EffectId"] = implicits[effectid].MagicEffect._attr.EffectId, ["EffectName"] = effectid, ["MaxStack"] = 1, ["bDefault"] = 1,
                                          ["Parameters"] = {[1] = {
                                            ["semantic"] = semantic.title,
                                            ["value"] = math.floor(tonumber(val.value))}}}}
    last = iup.GetBrother(last)
  end

  local RolledAffixes = {}
  while(last) do
    local exp = {}
    local affix_info = iup.GetNextChild(last,nil)
    local sliders = iup.GetNextChild(iup.GetBrother(affix_info),nil)
    --local sliders2 = iup.GetBrother(sliders)
    local effect_dropdown = iup.GetBrother(iup.GetNextChild(affix_info,nil))
    local effectid = effect_dropdown[effect_dropdown.value]
    local full_affix = affixes[effectid]
    local sliders2 = nil
    if(effectid) then
      local semantic = iup.GetNextChild(sliders, nil)
      local val = iup.GetNextChild(sliders,semantic)
      
      if(full_affix.count > 1) then
        sliders2 = iup.GetNextChild(iup.GetBrother(affix_info),sliders)
        local tmp__semantic_lo = full_affix.MagicEffect.LoRoll._attr
        local special_semantic = {}
        local val2 = iup.GetBrother(iup.GetNextChild(sliders2,nil))

        for k,_ in pairs(tmp__semantic_lo) do
          table.insert(special_semantic,k)
        end
        exp = {["EffectId"] = full_affix.MagicEffect._attr.EffectId, ["EffectName"] = effectid, ["MaxStack"] = 1}
        exp.Parameters = {}
        table.insert(exp.Parameters,{["semantic"] = special_semantic[1], ["value"] = math.floor(tonumber(val.value))})
        table.insert(exp.Parameters,{["semantic"] = special_semantic[2], ["value"] = math.floor(tonumber(val2.value))})
      else
        exp = {["EffectId"] = full_affix.MagicEffect._attr.EffectId, ["EffectName"] = effectid, ["MaxStack"] = 1,
                                          ["Parameters"] = {[1] = {
                                            ["semantic"] = semantic.title,
                                            ["value"] = math.floor(tonumber(val.value))}}}
      end
      table.insert(RolledAffixes,exp)
    end
    last = iup.GetBrother(last)
  end

  output_table.MagicEffects.RolledAffixes = RolledAffixes
  json_text.value = ''
  json_text.append = json.encode(output_table)
end