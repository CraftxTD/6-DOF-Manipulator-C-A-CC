-- Set channel frequency here
local localChannel = 11
local dockChannel = 10
local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(localChannel)

-- Timer
local timer = os.startTimer(1)
-- Wait until receive message from dock channel
local event, a, channel
while true do
	event, a, channel = os.pullEvent()
	if event == "modem_message" and channel == localChannel then
		-- Returns table of coordinates
		print("Sending pivot coordinates to dock.. ")
		modem.transmit(dockChannel, localChannel, sublevel.getLogicalPose().position)
	elseif event == "timer" and a == timer then
		print("Polling 1 second.. ")
		timer = os.startTimer(1)
	end
end
