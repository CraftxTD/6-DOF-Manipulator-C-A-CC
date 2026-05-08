local directories = {
	arm = { "arm_bearing.lua", "dock_bearing.lua" },
	programs = { "controller.lua" },
	protocols = { "calculate.lua", "channels.lua", "geometry.lua", "network.lua" },
	ship = { "dock.lua", "pivot.lua" },
	test = { "test.lua" },
}

local base = "https://raw.githubusercontent.com/CraftxTD/3-DOF-Manipulator-C-A-CC/refs/heads/main/"

for dir, files in pairs(directories) do
	fs.makeDir(dir)
	for _, file in pairs(files) do
		shell.run("rm", dir .. "/" .. file)

		print("Downloading " .. file)

		shell.run("wget", base .. dir .. "/" .. file, dir .. "/" .. file)
	end
end

print("Successfully downloaded.")
