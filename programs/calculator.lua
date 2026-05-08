local channels = require("protocols.channels")
local calculate = require("protocols.calculate")

local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(channels.controller)

local event, a, channel, message

while true do
	modem.transmit(channels.ship_dock, channels.controller)
	-- Timer
	local wait = os.startTimer(2)

	while true do
		event, a, channel, _, message = os.pullEvent()

		if event == "modem_message" then
			print("Found ship.. ")
			local data = calculate.angles(message)
			modem.transmit(channels.limb_ring_bearing, channels.controller, data.center_pivot)
			modem.transmit(channels.limb_1, channels.controller, data.limb1_angle)
			modem.transmit(channels.limb_2, channels.controller, data.limb2_angle)
			modem.transmit(channels.limb_dock_bearing, channels.controller, data.dock_pivot)
			break
		elseif event == "timer" and a == wait then
			print("Waiting response.. ")
			break
		end
	end

	sleep(1)
end
