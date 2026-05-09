package.path = package.path .. ";/?.lua"
-- This is used to control the rotation of the dock bearings and to detect if it is docked.
local channels = require("protocols.channels")
local network = require("protocols.network")

local localChannel = channels.LIMB_DOCK_BEARING
local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(localChannel)

for _, name in ipairs(peripheral.getNames()) do
	print(string.format("Found peripheral %s to the %s..", peripheral.getType(name), name))
end

local gearshift = peripheral.wrap("right")
local redstone_relay = "bottom"
local data

while true do
	data = network.poll(channels.CONTROLLER, 1)
	gearshift.rotate(data.angle, data.dir)

	while gearshift.isRunning() do
		sleep(0.1)
	end

	modem.transmit(channels.CONTROLLER, channels.CONTROLLER, _)

	-- TODO: Move this to controller
	-- Check if dock successfully
	-- network.poll_redstone(redstone_relay, 15, 1)
	-- modem.transmit()
end
