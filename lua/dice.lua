local api = vim.api

local Expression = require 'Expression'
local Terminal = require 'Terminal'

local function split_roll(string)
  local _, _, prefix, op, rest = string.find(string, "^([^+-]+)([+-]?)(.*)$")

  -- if op is defined, then rest must also be:
  if op ~= nil and rest == nil then
    print "invalid roll, operator without expression"
  end

  local terminal = Terminal:new(prefix)

  if op == '' then
    return Expression:new(terminal, "", "")
  end

  return Expression:new(terminal, op, split_roll(rest))
end

--[[
Take a string and parse it as a dice roll

'[multiplier]diceroll[+-diceroll...]'

- [multiplier]

'<integer>x' indicates how many times the roll should be repeated.
it is an integer followed by x. If none is provided, it defaults to 1.

- diceroll
'[numdice]d<size>[h<integer>][l<integer>]

-- numdice
The optional numdice decides how many times a dice is rolled. If left out, it defaults to one, or 4 if the dice size is 'f'

-- d<size>
decides what kind of dice is rolled. This is either an integer or 'f' for fudge/fate dice.

-- h<integer>/l<integer>
Only keep the <integer> highest (h) or lowest (l) dice. The rest is discarded and not summed.

- +- diceroll
This optional parameter can be used to add or subtract the results of additional dice rolls.

Examples:

d6
Roll one normal dice.

2d6
Roll two normal dice and add the results.

2d6h1
Roll two normal dice, and pick the highest.

2d6l1
Roll two normal dice, and pick the lowest.

2x2d6
Roll two normal dice and add the results. Do this two times.

2d20h1+1
Roll two d20, keep the highest and add one.

2d10+d12+3

--]]
local function diceroll(input)
  local string_result = input .. ":"

  -- Is there a multiplier fx 2x[...]
  _, _, multiplier = string.find(input, "(%d+)x")
  if multiplier == nil then multiplier = 1 end

  expression = split_roll(input)

  for x=1,multiplier do
    -- Roll a dice fx. 1d6
    str_res, int_res = expression:eval()
    print(input .. ": " .. str_res .. "= " .. int_res)
  end
end

return {
  diceroll = diceroll
}
