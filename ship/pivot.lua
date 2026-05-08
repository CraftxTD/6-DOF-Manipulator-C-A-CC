package.path = package.path .. ";/?.lua"
local channels = require("protocols.channels")
local network = require("protocols.network")
local modem = peripheral.find("modem") or error("No modem", 0)

-- TODO: Add redstone toggle in order to prevent from being continuously open

while true do
	print("Sending location.. ")
	modem.transmit(channels.SHIP_DOCK, channels.SHIP_PIVOT, sublevel.getLogicalPose().position)
	sleep(1)
end
