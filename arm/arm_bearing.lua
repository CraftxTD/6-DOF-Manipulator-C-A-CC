package.path = package.path .. ";/?.lua"

-- This is used to control the rotation of the ring, limb 1 and limb 2 bearings.
local channels = require("protocols.channels")
local network = require("protocols.network")
local args = { ... }
local localChannel
if args[1] == "1" then
	localChannel = channels.LIMB_RING_BEARING
elseif args[1] == "2" then
	localChannel = channels.LIMB_1
elseif args[1] == "3" then
	localChannel = channels.LIMB_2
end

local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(localChannel)

for _, name in ipairs(peripheral.getNames()) do
	print(string.format("Found peripheral %s to the %s..", peripheral.getType(name), name))
end

local gearshift = peripheral.wrap("right")
local data

while true do
	data = network.poll(channels.CONTROLLER, 1)
	gearshift.rotate(data.angle, data.dir)

	while gearshift.isRunning() do
		sleep(0.1)
	end

	modem.transmit(channels.CONTROLLER, channels.CONTROLLER, _)
end
