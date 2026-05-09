-- Calculator helper functions
local geometry = require("protocols.geometry")
local calculate = {}

local function quadrant(a, b)
	local angle = math.atan2(b, a)
	if angle < 0 then
		angle = angle + 2 * math.pi
	end
	return angle
end

-- Get direction because gearshfits don't seem to support
-- negative angles (returns a table)
-- In xz plane, 1 is towards -x (anti-clockwise), -1 is towards x (clockwise)
-- Converts radians to degree
local function deg_direction(theta)
	if theta < 0 then
		return { angle = math.deg(math.abs(theta) % (2 * math.pi)), dir = 1 }
	else
		return { angle = math.deg(theta % (2 * math.pi)), dir = -1 }
	end
end

-- Returns reference angle, necessary for only calculating
-- limb joint angles at the first quadrant
local function reference(theta)
	if math.pi / 2 >= theta and theta > 0 then
		return theta
	elseif math.pi >= theta and theta > math.pi / 2 then
		return math.pi - theta
	elseif 3 * math.pi / 2 >= theta and theta > math.pi then
		return theta - math.pi
	else
		return 2 * math.pi - theta
	end
end

-- All ships have the same channels, thus ships need to be filtered.
-- Uses magnitude of distance between two computers to determine
-- if they both belong to the same ship.
function calculate.filter_ship(position, dock_to_pivot)
	local magnitude = math.sqrt(
		math.pow(position.x1 - position.x2, 2)
			+ math.pow(position.y1 - position.y2, 2)
			+ math.pow(position.z1 - position.z2, 2)
	)
	if magnitude > dock_to_pivot then
		return false
	else
		return true
	end
end

-- FIXIT: Figure out a way to take care of dock rotation

function calculate.angles(local_ship)
	-- Angles are in radians. The arm dock pivot angle is assumed to always be at 0,
	-- in order to be easily used by the ship pivot angle.
	-- Horizontal angle spins the pivot bearing, while the vertical angle is used to calculate each joint arm angle.
	local magnitude, h_angle, v_angle, limb1_angle, limb2_angle, ship_pivot_angle, center_pivot, dock_pivot

	-- Ship angles
	-- The ship is assumed to be level.
	local ship_x, ship_y, ship_z
	ship_pivot_angle = quadrant(local_ship.x2 - local_ship.x1, -(local_ship.z2 - local_ship.z1))
	ship_x = local_ship.x1
		+ local_ship.offset_x * math.cos(ship_pivot_angle)
		- local_ship.offset_z * math.sin(ship_pivot_angle)
	ship_z = local_ship.z1
		- local_ship.offset_x * math.sin(ship_pivot_angle)
		+ local_ship.offset_z * math.cos(ship_pivot_angle)
	ship_y = local_ship.y1 - local_ship.offset_y

	-- Arm to ship angles and magnitude (z is inverted)
	-- Current arm is initially rotated by 90 degrees
	h_angle = quadrant(ship_x - geometry.CENTER_X, -(ship_z - geometry.CENTER_Z))
	-- Using hypotenuse of x and z to find vertical angle
	local hypotenuse_xz = (ship_x - geometry.CENTER_X) / math.cos(h_angle)
	v_angle = quadrant(hypotenuse_xz, ship_y - geometry.CENTER_Y)
	magnitude = hypotenuse_xz / math.cos(v_angle)

	-- Calculate each joint arm angle
	-- If at quadrant 2, each joint arm angle is the reflection of their corresponding
	-- angle at quadrant 1. This is done to prevent the arm from going underground.
	limb1_angle = reference(v_angle) + math.acos(magnitude / geometry.ARM_RADIUS)
	limb2_angle = reference(v_angle) - math.acos(magnitude / geometry.ARM_RADIUS) - limb1_angle

	-- Calculate center pivot angle and direction
	center_pivot = deg_direction(geometry.INITIAL_ARM_ANGLE - h_angle)

	-- Calculate dock pivot angle and direction.
	-- The initial dock pivot angle is the same as the center pivot angle.
	dock_pivot = deg_direction(ship_pivot_angle - h_angle)

	return {
		v_angle = deg_direction(v_angle),
		limb1_angle = deg_direction(-limb1_angle),
		limb2_angle = deg_direction(-limb2_angle),
		center_pivot = center_pivot,
		dock_pivot = dock_pivot,
	}
end

return calculate
