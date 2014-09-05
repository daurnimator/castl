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

-- [[ CASTL Date constructor submodule]] --
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean

local Date

local common = require("castl.modules.common")
local dateparser = require("castl.modules.dateparser")
local coreObjects = require("castl.core_objects")
local dateProto = require("castl.prototype.date")

local date, time, difftime = os.date, os.time, os.difftime
local pack, type, setmetatable = table.pack, type, setmetatable

_ENV = nil

Date = function(this, ...)
    -- Date constructor not called with a new
    if not coreObjects.instanceof(this, Date) then
        return date("%a %h %d %Y %H:%M:%S GMT%z (%Z)")
    end

    local o = {}
    local args = pack(...)
    local timestamp = 0

    if args.n == 0 then
        timestamp = Date.now()
    elseif args.n == 1 then
        local arg = args[1]
        if type(arg) == "number" then
            timestamp = arg * 1000
        elseif type(arg) == "string" then
            timestamp = Date.parse(arg)
        end
    else
        -- more than 1 arguments
        -- year, month, day, hour, minute, second, millisecond
        timestamp = time{year=args[1],
            month=args[2] + 1,
            day=args[3] or 1,
            hour=args[4] or 0,
            min = args[5] or 0,
            sec = args[6] or 0}

        timestamp = timestamp * 1000 + (args[7] or 0)
    end

    o._timestamp = timestamp

    setmetatable(o, {
        __index = function (self, key)
            return common.prototype_index(dateProto, key)
        end,
        __tostring = dateProto.toString,
        __tonumber = function(self)
            return self:getTime()
        end,
        _prototype = dateProto
    })

    return o
end

Date._timestamp = 0

Date.now = function(this)
    -- TODO: write a C function to get milliseconds
    return time() * 1000
end

Date.parse = function(this, str)
    -- TODO: parse RFC2822 only for now
    return dateparser.parse(str, 'RFC2822') * 1000
end

Date.UTC = function(this, year, month, day, hrs, min, sec, ms)
    local timestamp = 0
    timestamp = time{year=year,
        month = month + 1,
        day = day or 1,
        hour = hrs or 0,
        min = min or 0,
        sec = sec or 0}

    timestamp = (timestamp + dateProto.getTimezoneOffset()) * 1000 + (ms or 0)

    return timestamp
end

Date.length = 7

Date.prototype = dateProto
dateProto.constructor = Date

return Date