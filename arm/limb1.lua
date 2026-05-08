-- Set channel frequency here
local localChannel = 2
local calculatorChannel = 5
local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(localChannel)

-- Timer
local timer = os.startTimer(1)
local gearshift = peripheral.wrap("right")
local event, a, channel, angle

while true do
	event, a, channel, _, angle = os.pullEvent()
	if event == "modem_message" and channel == localChannel then
		if angle > 0 then
			gearshift.rotate(angle, 1)

			-- TESTING
			sleep(5)
			gearshift.rotate(angle, 1)
		else
			gearshift.rotate(angle, -1)

			-- TESTING
			sleep(5)
			gearshift.rotate(angle, -1)
		end
	elseif event == "timer" and a == timer then
		print("Polling 1 second.. (arm)")
		timer = os.startTimer(1)
	end
end
