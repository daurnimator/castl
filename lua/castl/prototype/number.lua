--[[
    Copyright (c) 2014, Paul Bernier
    
    CASTL is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    CASTL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
    You should have received a copy of the GNU Lesser General Public License
    along with CASTL. If not, see <http://www.gnu.org/licenses/>.
--]]

-- [[ CASTL Number prototype submodule]] --
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/prototype

local numberPrototype = {}

local errorHelper = require("castl.modules.error_helper")

local tonumber, format, tostring, floor, concat, insert = tonumber, string.format, tostring, math.floor, table.concat, table.insert
local strsub, strlen, gsub, find, format, getmetatable, type = string.sub, string.len, string.gsub, string.find, string.format, getmetatable, type
local error = error

_ENV = nil

numberPrototype.toString = function(this, radix)
    local mt = getmetatable(this)
    local value = this:valueOf()

    if not radix then
        return tostring(value)
    end

    -- TODO: do not handle floating point numbers
    -- http://stackoverflow.com/a/3554821
    local n = floor(value)
    if not radix or radix == 10 then return tostring(n) end
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    local sign = ""
    if n < 0 then
        sign = "-"
        n = -n
    end
    repeat
        local d = (n % radix) + 1
        n = floor(n / radix)
        insert(t, 1, strsub(digits, d, d))
    until n == 0

    return sign .. concat(t, "")
end

numberPrototype.toLocaleString = numberPrototype.toString

numberPrototype.valueOf = function (this)
    local mt = getmetatable(this)
    if mt and type(mt._primitive) == "number" then
        return mt._primitive
    else
        return this
    end
end

numberPrototype.toFixed = function(this, digits)
    local value = this:valueOf()
    digits = digits or 0
    return format("%." .. tonumber(digits) .. "f", value)
end

numberPrototype.toExponential = function(this, fractionDigits)
    local value = this:valueOf()
    if fractionDigits == nil then
        fractionDigits = strlen(tostring(value)) - 1
        if floor(value) ~= value then
            fractionDigits = fractionDigits - 1
        end
    end
    if fractionDigits < 0 or fractionDigits > 20 then
        error(errorHelper.newRangeError("RangeError: toExponential() argument must be between 0 and 20"))
    end
    local formatted = format("%." .. fractionDigits .. "e", value)
    return (gsub(formatted, "%+0", "+"))
end

numberPrototype.toPrecision = function(this, precision)
    local value = this:valueOf()
    if precision == nil then return tostring(value) end
    if precision < 1 or precision > 21 then
        error(errorHelper.newRangeError("RangeError: toPrecision() argument must be between 1 and 21"))
    end
    local formatted = format("%." .. precision .. "g", value)
    return (gsub(formatted, "%+0", "+"))
end

return numberPrototype
