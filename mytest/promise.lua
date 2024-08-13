local Promise = {}
Promise.__index = Promise

local validStates = {
    PENDING = 0,
    FULFILLED = 1,
    REJECTED = 2
}

local function isValidState(state)
    return state == validStates.PENDING or state == validStates.FULFILLED or state == validStates.REJECTED
end

function Promise:new(fn)
    local obj = setmetatable({
        value = nil,
        state = validStates.PENDING,
        queue = {},
        handlers = {
            fulfill = nil,
            reject = nil
        }
    }, self)

    if fn then
        fn(function(value)
            self:resolve(obj, value)
        end, function(reason)
            self:reject(obj, reason)
        end)
    end

    return obj
end

function Promise:then_(onFulfilled, onRejected)
    local queuedPromise = Promise:new()

    if type(onFulfilled) == "function" then
        queuedPromise.handlers.fulfill = onFulfilled
    end

    if type(onRejected) == "function" then
        queuedPromise.handlers.reject = onRejected
    end

    table.insert(self.queue, queuedPromise)
    self:process()

    return queuedPromise
end

function Promise:transition(state, value)
    if self.state == state or self.state ~= validStates.PENDING or not isValidState(state) or not value then
        return
    end

    self.value = value
    self.state = state
    self:process()
end

function Promise:process()
    if self.state == validStates.PENDING then
        return
    end

    while #self.queue > 0 do
        local queuedPromise = table.remove(self.queue, 1)
        local handler = nil
        local value

        if self.state == validStates.FULFILLED then
            handler = queuedPromise.handlers.fulfill or function(value) return value end
        elseif self.state == validStates.REJECTED then
            handler = queuedPromise.handlers.reject or function(reason) error(reason) end
        end

        local status, result = pcall(handler, self.value)
        if status then
            self:resolve(queuedPromise, result)
        else
            self:reject(queuedPromise, result)
        end
    end
end

function Promise:resolve(promise, x)
    if promise == x then
        promise:transition(validStates.REJECTED, "The promise and its value refer to the same object")
    elseif getmetatable(x) == Promise then
        if x.state == validStates.PENDING then
            x:then_(function(value)
                self:resolve(promise, value)
            end, function(reason)
                promise:transition(validStates.REJECTED, reason)
            end)
        else
            promise:transition(x.state, x.value)
        end
    elseif type(x) == "table" or type(x) == "function" then
        local called = false
        local thenHandler = x.then_

        if type(thenHandler) == "function" then
            pcall(function()
                thenHandler(x, function(y)
                    if not called then
                        self:resolve(promise, y)
                        called = true
                    end
                end, function(r)
                    if not called then
                        promise:transition(validStates.REJECTED, r)
                        called = true
                    end
                end)
            end)
        else
            promise:transition(validStates.FULFILLED, x)
        end
    else
        promise:transition(validStates.FULFILLED, x)
    end
end

function Promise:fulfill(value)
    self:transition(validStates.FULFILLED, value)
end

function Promise:reject(reason)
    self:transition(validStates.REJECTED, reason)
end

-- Helper functions to create resolved and rejected promises
local function resolved(value)
    return Promise:new(function(resolve)
        resolve(value)
    end)
end

local function rejected(reason)
    return Promise:new(function(_, reject)
        reject(reason)
    end)
end

local function deferred()
    local resolve, reject
    local promise = Promise:new(function(rslv, rjct)
        resolve = rslv
        reject = rjct
    end)
    return {
        promise = promise,
        resolve = resolve,
        reject = reject
    }
end

-- Expose the Promise constructor and helper functions
return Promise