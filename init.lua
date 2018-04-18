
-- global
pova = {}

-- local
local pova_list = {}


-- set player table and defaults on join
minetest.register_on_joinplayer(function(player)
	pova_list[ player:get_player_name() ] = {
		default = {speed = 1, jump = 1, gravity = 1}}
end)

-- reset player table and defaults on respawn
minetest.register_on_respawnplayer(function(player)
	pova_list[ player:get_player_name() ] = {
		default = {speed = 1, jump = 1, gravity = 1}}
end)

-- blank player table on leave
minetest.register_on_leaveplayer(function(player)
	pova_list[ player:get_player_name() ] = nil
end)


-- global command functions
pova.set_override_defaults = function(name, def)
	pova_list[name]["default"] = def
end

pova.add_override = function(name, item, def)
	if item == "default" then return end
	pova_list[name][item] = def
end

pova.get_override = function(name, item)
	if item == "default" then return end
	return pova[name][item]
end

pova.del_override = function(name, item)
	if item == "default" then return end
	pova_list[name][item] = nil
end


-- main counter that runs every second and totals override list
local timer = 0
minetest.register_globalstep(function(dtime)

	timer = timer + dtime

	-- every 1 second
	if timer < 1 then
		return
	end

	-- reset time for next check
	timer = 0

	-- define locals outside loop
	local name, speed, jump, gravity

	-- loop through players
	for _,player in ipairs(minetest.get_connected_players()) do

		name = player:get_player_name()

		if pova_list[name] then

			-- check for new defaults
			speed = pova_list[name]["default"].speed or 1
			jump = pova_list[name]["default"].jump or 1
			gravity = pova_list[name]["default"].gravity or 1

			for id, var in pairs(pova_list[name]) do

				if var and id ~= "default" then

					-- add any additional changes
					speed = speed + (pova_list[name][id].speed or 0)
					jump = jump + (pova_list[name][id].jump or 0)
					gravity = gravity + (pova_list[name][id].gravity or 0)
				end
			end

			print ("speed: " .. speed .. " / jump: " .. jump .. " / gravity: " .. gravity)

			player:set_physics_override(speed, jump, gravity)

		end
	end
end)


-- axe tool to change defaults and add changes to table
minetest.register_craftitem("pova:axe", {
	description = "Test Axe (left to apply, right to remove effects)",
	inventory_image = "default_tool_steelaxe.png",
	liquids_pointable = true,

	on_use = function(itemstack, user, pointed_thing)

		local name = user:get_player_name()

		-- set new defaults
		pova.set_override_defaults(name, {
			speed = 2, jump = 0.5, gravity = 1.0})

		-- define changes that are added onto defaults
		pova.add_override(name, "test", {
			speed = 1, jump = 2, gravity = 0.5})
	end,

	on_place = function(itemstack, user, pointed_thing)

		local name = user:get_player_name()

		-- reset defaults
		pova.set_override_defaults(name, {
			speed = 1, jump = 1, gravity = 1})

		-- remove changes
		pova.del_override(name, "test")
	end,
})
