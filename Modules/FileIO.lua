--Based on the IO from the IUP Examples
function readfile(fname)
    local tmpfile = io.open(fname, "r")
    if ( not tmpfile) then
        iup.Message("Error", "Can't open file: " .. fname)
        return nil
    end

    local str = tmpfile:read("*a")
    if(not str) then
        iup.Message("Error", "Can't read file: " .. fname)
        return nil
    end
    tmpfile:close()
    return str
end

function writefile(fname, data)
    local tmpfile = io.open(fname, "w")
    save("data",data,nil,tmpfile)
    tmpfile:close()
end


--Table serialization code from Lua Documenation https://www.lua.org/pil/12.1.2.html

 function basicSerialize (o)
      if type(o) == "number" then
        return tostring(o)
      else   -- assume it is a string
        return string.format("%q", o)
      end
end

function save (name, value, saved, fname)
  saved = saved or {}       -- initial value
  fname:write(name, " = ")
  if type(value) == "number" or type(value) == "string" then
    fname:write(basicSerialize(value), "\n")
  elseif type(value) == "table" then
    if saved[value] then    -- value already saved?
      fname:write(saved[value], "\n")  -- use its previous name
    else
      saved[value] = name   -- save name for next time
      fname:write("{}\n")     -- create a new table
      for k,v in pairs(value) do      -- save its fields
        local fieldname = string.format("%s[%s]", name,
                                            basicSerialize(k))
        save(fieldname, v, saved, fname)
        end
      end
    else
      error("cannot save a " .. type(value))
    end
end
