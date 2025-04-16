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

minetest.register_on_prejoinplayer(function(name, ip)
    local whitelist = load_whitelist()

    if not whitelist[name] then
        return "You are not whitelisted on this server."
    end
end)

core.register_chatcommand("whitelist", {
    privs = { whitelist = true },
    func = function(name, param)
        local action, target = param:match("^(%S+)%s*(%S*)$")
        local list = load_whitelist()

        if action == "add" and target ~= "" then
            list[target] = true
            save_whitelist(list)
            return true, "Added " .. target .. " to the whitelist."

        elseif action == "remove" and target ~= "" then
            list[target] = nil
            save_whitelist(list)
            return true, "Removed " .. target .. " from the whitelist."

        elseif action == "list" then
            local names = {}
            for player in pairs(list) do
                table.insert(names, player)
            end
            return true, "Whitelisted players:\n" .. table.concat(names, ", ")

        else
            return false, "Usage: /whitelist <add|remove|list> <playername>"
        end
    end,
})
