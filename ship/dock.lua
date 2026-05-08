-- Gets position of the dock and sends it to the calculator
-- Set channel frequency here
local localChannel = 10
local calculatorChannel = 5
local pivotChannel = 11
local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(localChannel)

-- Offset values (numbers in parenthesis, these are LOCAL coordinates)
-- Used to determine where the dock is with max precision,
-- assuming that the paired docking connector is 180 degrees
-- opposite of the pivot computer.
local arm_x = -3
local arm_y = -4
local x = -1 + arm_x
local y = -1 + arm_y
local z = 0

-- Timer
-- Ship Dock Pivot channel
local event, a, channel, message
while true do
	modem.transmit(pivotChannel, localChannel)
	local wait = os.startTimer(2)

	while true do
		event, a, channel, _, message = os.pullEvent()

		if event == "modem_message" then
			print("Got pivot coordinates.. ")
			local localCoords = sublevel.getLogicalPose().position

			local data = {
				offset_x = x,
				offset_y = y,
				offset_z = z,
				x1 = localCoords.x,
				y1 = localCoords.y,
				z1 = localCoords.z,
				x2 = message.x,
				y2 = message.y,
				z2 = message.z,
			}
			print("Sent to calculator computer.. ")
			modem.transmit(calculatorChannel, localChannel, data)
			break
		elseif event == "timer" and a == wait then
			print("Waiting response.. ")
			break
		end
	end
	sleep(2)
end
