-- Calculator helper functions
local geometry = require("protocols.geometry")
local calculate = {}

function calculate.quadrant(a, b)
	local magnitude = math.abs(math.atan2(b, a))
	if a >= 0 and b >= 0 then
		return magnitude
	elseif a < 0 and b >= 0 then
		return magnitude + math.pi / 2
	elseif a < 0 and b < 0 then
		return magnitude + math.pi
	elseif a >= 0 and b < 0 then
		return magnitude + (3 * math.pi) / 2
	end
end

function calculate.angles(data)
	if type(data) ~= "table" then
		return 0
	end

	-- Angles are in pi
	-- The arm dock pivot angle is assumed to always be at 0,
	-- in order to be easily used by the ship pivot angle.
	-- Horizontal angle spins the pivot bearing, while the
	-- vertical angle is used to calculate each joint arm angle.
	local magnitude, h_angle, v_angle, limb1_angle, limb2_angle, ship_pivot_angle, center_pivot, dock_pivot

	-- Ship angles
	-- The ship is assumed to be level.
	local ship_x, ship_y, ship_z
	ship_pivot_angle = quadrant(data.x2 - data.x1, -(data.z2 - data.z1))
	ship_x = data.x1 + data.offset_x * math.cos(ship_pivot_angle) - data.offset_z * math.sin(ship_pivot_angle)
	ship_z = data.z1 + data.offset_x * math.sin(ship_pivot_angle) + data.offset_z * math.cos(ship_pivot_angle)
	ship_y = data.y1 - data.offset_y

	-- Arm to ship angles and magnitude (z is inverted)
	-- Current arm is initially rotated by 90 degrees
	h_angle = quadrant(ship_x - geometry.center_x, -(ship_z - geometry.center_z))
	-- Using hypotenuse of x and z to find vertical angle
	local hypotenuse_xz = (ship_x - geometry.center_x) / math.cos(h_angle)
	v_angle = quadrant(hypotenuse_xz, ship_y - geometry.center_y)
	magnitude = hypotenuse_xz / math.cos(v_angle)

	-- Calculate each joint arm angle
	-- If at quadrant 2, each joint arm angle
	-- is the reflection of their corresponding
	-- angle at quadrant 1. This is done to
	-- prevent the arm from going underground.
	if v_angle > math.pi / 2 then
		limb1_angle = v_angle - math.acos(magnitude / geometry.arm_radius)
		limb2_angle = v_angle + math.acos(magnitude / geometry.arm_radius)
	else
		limb1_angle = v_angle + math.acos(magnitude / geometry.arm_radius)
		limb2_angle = v_angle - math.acos(magnitude / geometry.arm_radius)
	end

	-- Calculate center pivot angle and direction
	-- (1 is towards x, -1 is towards -x)
	if geometry.initial_arm_angle >= h_angle then
		center_pivot = { angle = math.deg(geometry.initial_arm_angle - h_angle), dir = 1 }
	elseif h_angle > geometry.initial_arm_angle then
		center_pivot = { angle = math.deg(h_angle - geometry.initial_arm_angle), dir = -1 }
	end

	-- Calculate dock pivot angle and direction
	if ship_pivot_angle >= h_angle then
		dock_pivot = { angle = math.deg(ship_pivot_angle) - h_angle, dir = -1 }
	elseif h_angle > ship_pivot_angle then
		dock_pivot = { angle = math.deg(h_angle - ship_pivot_angle), dir = 1 }
	end

	return {
		magnitude = math.deg(magnitude),
		v_angle = math.deg(v_angle),
		limb1_angle = math.deg(limb1_angle),
		limb2_angle = math.deg(limb2_angle),
		center_pivot = center_pivot,
		dock_pivot = dock_pivot,
	}
end

return calculate
