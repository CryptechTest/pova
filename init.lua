
-- global
pova = {}

-- local
local pova_list = {}

-- do we want override loop enabled to apply changes every second?
local pova_loop = minetest.settings:get_bool("pova_loop") ~= false


-- set player table and defaults on join
minetest.register_on_joinplayer(function(player)
	pova_list[ player:get_player_name() ] = {
		default = {speed = 1, jump = 1, gravity = 1},
		min = {speed = 0, jump = 0, gravity = 0}}
	pova.do_override(player)
end)

-- reset player table and defaults on respawn
minetest.register_on_respawnplayer(function(player)
	pova_list[ player:get_player_name() ] = {
		default = {speed = 1, jump = 1, gravity = 1},
		min = {speed = 0, jump = 0, gravity = 0}}
	pova.do_override(player)
end)

-- blank player table on leave
minetest.register_on_leaveplayer(function(player)
	pova_list[ player:get_player_name() ] = nil
end)


pova.add_override = function(name, item, def)
	pova_list[name][item] = def
end

pova.get_override = function(name, item)
	return pova_list[name][item]
end

pova.del_override = function(name, item)
	pova_list[name][item] = nil
end

pova.do_override = function(player)

	local name = player:get_player_name()

	if name and pova_list[name] then

		-- check for new defaults
		local speed = pova_list[name]["default"].speed or 1
		local jump = pova_list[name]["default"].jump or 1
		local gravity = pova_list[name]["default"].gravity or 1

		-- loop through list of added overrides
		for id, var in pairs(pova_list[name]) do

			-- skip any custom sets
			if var
			and id ~= "default"
			and id ~= "min"
			and id ~= "max"
			and id ~= "force" then

				-- add any additional changes
				speed = speed + (pova_list[name][id].speed or 0)
				jump = jump + (pova_list[name][id].jump or 0)
				gravity = gravity + (pova_list[name][id].gravity or 0)
			end
		end

		-- minimum checks
		if pova_list[name]["min"] then
			speed = math.max(pova_list[name]["min"].speed or speed, speed)
			jump = math.max(pova_list[name]["min"].jump or jump, jump)
			gravity = math.max(pova_list[name]["min"].gravity or gravity, gravity)
		end

		-- maximum checks
		if pova_list[name]["max"] then
			speed = math.min(pova_list[name]["max"].speed or speed, speed)
			jump = math.min(pova_list[name]["max"].jump or jump, jump)
			gravity = math.min(pova_list[name]["max"].gravity or gravity, gravity)
		end

		-- force values (for things like sleeping in bed)
		if pova_list[name]["force"] then
			speed = pova_list[name]["force"].speed or speed
			jump = pova_list[name]["force"].jump or jump
			gravity = pova_list[name]["force"].gravity or gravity
		end

		-- for testing only
		if name == "singleplayer" then
			print ("speed: " .. speed .. " / jump: " .. jump .. " / gravity: " .. gravity)
		end

		-- set new overrides
		player:set_physics_override(speed, jump, gravity)
	end
end


-- main counter that runs every second and totals override list (if enabled)
if pova_loop then

	local timer = 0
	minetest.register_globalstep(function(dtime)

		timer = timer + dtime

		-- every 1 second
		if timer < 1 then
			return
		end

		-- reset time for next check
		timer = 0

		-- loop through players and apply overrides
		for _,player in ipairs(minetest.get_connected_players()) do
			pova.do_override(player)
		end
	end)
end


-- axe tool to change defaults and add changes to table
minetest.register_craftitem("pova:axe", {
	description = "Test Axe (left to apply, right to remove effects)",
	inventory_image = "default_tool_steelaxe.png",
	liquids_pointable = true,

	on_use = function(itemstack, user, pointed_thing)

		local name = user:get_player_name()

		-- set new defaults
		pova.add_override(name, "default", {
			speed = 2, jump = 3, gravity = 1.0})

		-- define changes that are added onto defaults
		pova.add_override(name, "test", {
			speed = 1, jump = -1, gravity = 0.5})

		-- set new minimum for jump
		pova.add_override(name, "min", {
			jump = 3})

		-- add new maximum for speed
		pova.add_override(name, "max", {
			speed = 2})

		-- add force value for gravity
		pova.add_override(name, "force", {
			gravity = 1.2})

		-- apply override
		pova.do_override(user)
	end,

	on_place = function(itemstack, user, pointed_thing)

		local name = user:get_player_name()

		-- remove changes
		pova.del_override(name, "max")
		pova.del_override(name, "force")
		pova.del_override(name, "test")

		-- reset min for jump
		pova.add_override(name, "min", {
			jump = 0})

		-- reset defaults
		pova.add_override(name, "default", {
			speed = 1, jump = 1, gravity = 1})

		-- apply override
		pova.do_override(user)
	end,
})
