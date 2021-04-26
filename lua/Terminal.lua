local Terminal = {}

Terminal.__index = Terminal

local function parse_roll(string)
  -- fate dice:
  _, _, num_dice, dice_size = string.find(string, "(%d*)d(f)")

  if dice_size == 'f' then
    -- fate uses 4df as standard:
    if num_dice == '' then num_dice = 4 end
  else
    -- normal dice
    _, _, num_dice, dice_size = string.find(string, "(%d*)d(%d+)")
    if num_dice == '' then num_dice = 1 end
  end

  -- keep the higher or lower ?
  found, _, higher = string.find(string, "h(%d*)$")
  if found ~= nil and higher == "" then higher = 1 end
  found, _, lower = string.find(string, "l(%d*)$")
  if found ~= nil and lower == "" then lower = 1 end

  return tonumber(num_dice), dice_size, tonumber(lower), tonumber(higher)
end

function Terminal:new(term)
  if term == nil or term == "" then print("Error: no term") end
  local s = {}
  setmetatable(s, Terminal)
  s.string = term
  if string.find(term, "^%d+$") then
    s.int = tonumber(term)
  elseif string.find(term, "^%[.*%]$") then
    s.macro = string.sub(term, 2, #term-1)
  else
    s.num_dice, s.dice_size, s.lower, s.higher = parse_roll(term)
  end
  return s
end

local function roll_dice(num_dice, dice_size, lower, higher)
    local int_result = 0
    local string_result = ""
    local rolls = {}
    for i=1,num_dice do
      local res, str
      -- Fate dice:
      if dice_size == 'f' then
        res = math.random(-1,1)
        if res == -1 then str = '-' end
        if res == 0  then str = ' ' end
        if res == 1  then str = '+' end

      -- Normal dice
      else
        res = math.random(1,dice_size)
        str = res
      end
      rolls[i] = {res=res, str=str}
    end

    table.sort(rolls, function (a,b)
      return a["res"] > b["res"]
    end)

    for i=1,#rolls do
      -- Skip this result if we are only keeping the highest, and have choosen those:
      if higher ~= nil and i > higher then
        string_result = string_result .. "(" .. rolls[i]["str"] .. ") "

      -- Skip this result if we are only keeping the lowest, and this dice is too high
      elseif lower ~= nil and i <= (#rolls - lower) then
        string_result = string_result .. "(" .. rolls[i]["str"] .. ") "

      -- Otherwise we add this result to the kept dice:
      else
        string_result = string_result .. "[" .. rolls[i]["str"] .. "] "
        int_result = int_result + rolls[i]["res"]
      end
    end

    return string_result, int_result
end

-- return  string, value
-- where string is the description and individual rolls, and value is the total result
function Terminal:eval()
  if(self.int ~= nil) then
    return self.int .. " ", self.int
  end

  if(self.macro ~= nil) then
    local expr = require'dice'.get_macro(self.macro)
    local string_result, int_result = require'Expression'.eval(expr)
    return "[" .. self.macro .. ": " .. string_result .. "] ", int_result
  end

  return roll_dice(self.num_dice, self.dice_size, self.lower, self.higher)
end

return Terminal
