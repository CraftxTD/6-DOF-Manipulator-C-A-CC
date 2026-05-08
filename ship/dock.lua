package.path = package.path .. ";/?.lua"
-- Gets position of the dock and sends it to the calculator
local channels = require("protocols.channels")
local network = require("protocols.network")
local geometry = require("protocols.geometry")
local calculate = require("protocols.calculate")
local modem = peripheral.find("modem") or error("No modem", 0)
modem.open(channels.SHIP_DOCK)

-- Offset values (numbers in parenthesis, these are LOCAL coordinates)
-- MUST BE CALIBRATED FOR EVERY SHIP.
-- Used to determine where the dock is with max precision,
-- assuming that the paired docking connector is 180 degrees
-- opposite of the pivot computer.
local x = -1 + geometry.DOCK_X
local y = -1 + geometry.DOCK_Y
local z = 0 + geometry.DOCK_Z

-- Approximate distance between dock and ship. Used to filter other different ships.
local dock_to_pivot = 12

for _, name in ipairs(peripheral.getNames()) do
	print(string.format("Found peripheral %s to the %s..", peripheral.getType(name), name))
end

-- For checking if in docking mode
local relay_lever = "top"

-- For checking if docked. This uses the
-- comparator value from the dock connector.
local relay_check_dock = "right"

while true do
	-- Check if docked
	if redstone.getAnalogInput(relay_check_dock) > 14 then
		sleep(1)
	else
		-- Waits for a redstone output
		if network.poll_redstone(relay_lever, 1, 1) then
			-- Location updates every 0.5 seconds
			pivot = network.poll(channels.SHIP_PIVOT, 0.5)
			local this = sublevel.getLogicalPose().position

			local coordinates = {
				offset_x = x,
				offset_y = y,
				offset_z = z,
				x1 = this.x,
				y1 = this.y,
				z1 = this.z,
				x2 = pivot.x,
				y2 = pivot.y,
				z2 = pivot.z,
			}
			if calculate.filter_ship(coordinates, dock_to_pivot) then
				modem.transmit(channels.CONTROLLER, channels.SHIP_DOCK, coordinates)
				print("Sent to controller.. ")
			else
				print("Wrong ship.. ")
			end
		end
	end
end
