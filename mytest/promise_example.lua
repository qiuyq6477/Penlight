local Promise = require('promise')
local timer = require("timer")
local function asyncTask()
    return Promise:new(function(resolve, reject)
        -- 模拟异步任务
        timer.timeout(2,function()
            resolve("success!")
        end)
    end)
end

asyncTask():then_(function(value)
    print(value)  -- 输出 "任务成功!"
end, function(error)
    print("错误: " .. error)
end)

while true do
    timer.update()
end
