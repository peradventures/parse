--------------------------------------
-- Class Attributes
--------------------------------------

Log = {
    description = "",
    data = {}
}

--------------------------------------
-- Class Methods
--------------------------------------

function Log:add_message(content)

end

--------------------------------------
-- Class Constructor
--------------------------------------

function Log:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
    return t
end