local whitelist_file_path = minetest.get_worldpath() .. "/whitelist.txt"

core.register_privilege("whitelist", {
    description = "Used to manage the whitelist",
    give_to_singleplayer = false
})

local function load_whitelist()
local file = io.open(whitelist_file_path, "r")
local list = {}

if file then
    for line in file:lines() do
        list[line] = true
        end
        file:close()
        end

        return list
        end

        local function save_whitelist(list)
        local file = io.open(whitelist_file_path, "w")
        if not file then return end

            for name, _ in pairs(list) do
                file:write(name .. "\n")
                end

                file:close()
                end

                -- Auto-whitelist singleplayer and admin
                minetest.register_on_mods_loaded(function()
                local list = load_whitelist()

                if minetest.is_singleplayer() then
                    list["singleplayer"] = true
                    end

                    for _, player in ipairs(minetest.get_connected_players()) do
                        local pname = player:get_player_name()
                        if minetest.check_player_privs(pname, { server = true }) then
                            list[pname] = true
                            end
                            end

                            save_whitelist(list)
                            end)

                minetest.register_on_prejoinplayer(function(name, ip)
                local whitelist = load_whitelist()
                if not whitelist[name] then
                    return "[minetest-whitelister] You are not whitelisted on this server."
                    end
                    end)

                core.register_chatcommand("whitelist", {
                    privs = { whitelist = true },
                    func = function(name, param)
                    local action, target = param:match("^(%S+)%s*(%S*)$")
                    local list = load_whitelist()

                    if action == "add" and target ~= "" then
                        if list[target] then
                            return false, "[minetest-whitelister] " .. target .. " is already whitelisted."
                            end
                            list[target] = true
                            save_whitelist(list)
                            return true, "[minetest-whitelister] Added " .. target .. " to the whitelist."

                            elseif action == "reload" then
                                list = load_whitelist()
                                for _, player_obj in ipairs(minetest.get_connected_players()) do
                                    local pname = player_obj:get_player_name()
                                    if not list[pname] then
                                        -- Use minetest.kick_player if player_obj:kick is nil
                                        if player_obj.kick then
                                            player_obj:kick("[minetest-whitelister] Whitelist was reloaded. You weren't on the whitelist so you were kicked.")
                                            else
                                                minetest.kick_player(pname, "[minetest-whitelister] Whitelist was reloaded. You weren't on the whitelist so you were kicked.")
                                                end
                                                end
                                                end
                                                return true, "[minetest-whitelister] Whitelist reloaded and non-whitelisted players kicked."

                                                elseif action == "remove" and target ~= "" then
                                                    list[target] = nil
                                                    save_whitelist(list)
                                                    return true, "[minetest-whitelister] Removed " .. target .. " from the whitelist."

                                                    elseif action == "list" then
                                                        local names = {}
                                                        for player in pairs(list) do
                                                            table.insert(names, player)
                                                            end
                                                            if #names == 0 then
                                                                return true, "[minetest-whitelister] No players are currently whitelisted."
                                                                end
                                                                return true, "[minetest-whitelister] Whitelisted players:\n" .. table.concat(names, ", ")

                                                                else
                                                                    return false, "Usage: /whitelist <add|remove|list|reload> <playername>"
                                                                    end
                                                                    end,
                })
