local text1 = "`9SELL SEED 40/1 AT `0GASJUM"

local function spam()
    while true do
        for i = 1, 5 do
            sleep(3000)
            say(text1)
            sleep(1000)
            say("/love")
        end
        sleep(7000)
    end
end

spam()
