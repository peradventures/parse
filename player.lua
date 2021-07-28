--------------------------------------
-- Class Attributes
--------------------------------------

Player = {
    name = "",
    targets = {}
}

--------------------------------------
-- Class Methods
--------------------------------------

function Player:increment(metric)

end

function Player:set(metric)

end

--------------------------------------
-- Class Constructor
--------------------------------------

function Player:new(t)
    t = t or {}
    setmetatable(t, self)
    self.__index = self
    return t
end