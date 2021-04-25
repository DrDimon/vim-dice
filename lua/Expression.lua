local Terminal = require 'Terminal'

local Expression = {}
Expression.__index = Expression

function Expression:new(terminal, op, expression)

  if terminal == nil or terminal == "" then
    print("Error: no terminal")
  end
  if not (op == "" or op == "+" or op == "-" or op == nil) then
    print("Error: unrecognised operator " .. op)
  end

  local s = {}
  setmetatable(s, Expression)
  s.terminal = terminal
  s.op = op
  s.expression = expression

  return s
end

-- return value, string
-- where string is the description and individual rolls, and value is the total result
function Expression:eval()
  -- Eval terminal:
  local term_string_res, term_int_res = self.terminal:eval()

  -- Return terminal if there is no expression on this object:
  if self.op == "" or self.op == nil then
    return term_string_res, term_int_res
  end 

  -- Eval expression:
  local expr_string_res, expr_int_res = self.expression:eval()

  if self.op == "+" then
    return term_string_res .. "+ " .. expr_string_res, term_int_res + expr_int_res
  end

  if self.op == "-" then
    return term_string_res .. "- " .. expr_string_res, term_int_res - expr_int_res
  end

  print("error: unkown op " .. self.op)
  return 0
end

return Expression
