-- Set channel frequency here
local localChannel = 1
local calculatorChannel = 5
local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(localChannel)

-- Timer
local timer = os.startTimer(1)
local gearshift = peripheral.wrap("right")
local event, a, channel, message

while true do
	event, a, channel, _, message = os.pullEvent()
	if event == "modem_message" and channel == localChannel then
		gearshift.rotate(message.angle, message.dir)

		-- TESTING
		sleep(5)
		gearshift.rotate(message.angle, -message.dir)
	elseif event == "timer" and a == timer then
		print("Polling 1 second.. (arm)")
		timer = os.startTimer(1)
	end
end
