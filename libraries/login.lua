local login = {}
if not shared.vape then repeat task.wait() until shared.vape end
local cloneref = cloneref or function(obj)
    return obj
end

local vape = shared.vape
local http = cloneref(game:GetService("HttpService"))

local ApiBase = "https://onyxclient.fsl58.workers.dev/"
local LoginBase = 'https://onyxclient.fsl58.workers.dev/login'
--local HwidBase = ApiBase.."hwid?user="
local username = ""
local password = ""

if getgenv().TestAccount then
    username = "GUEST"
    password = "PASSWORD"
else
    username = getgenv().username or "GUEST"
    password = getgenv().password or "PASSWORD"
end


--[[local function HWIDCheck(user)
    local hwid = readfile("ReVape/accounts/hwid.txt")
    local req = request or http_request or (syn and syn.request)
    if not req then 
        warn("No HTTP request function available.")
        return nil 
    end

    local success, result = pcall(function()
        return req({
            Url = HwidBase..user.."&hwid="..hwid,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if not success then
        warn("HWID check failed:", result)
        return nil
    end

    return result
end
--]]


local function postLogin(u, p)
    local req = request or http_request or syn.request
    if not req then return nil end

    return req({
        Url = LoginBase,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = http:JSONEncode({
            username = u,
            password = p
        })
    })
end



function login:Login()
    local role, U, P = "", "", ""

    local ok = pcall(function()
        local req = postLogin(username, password)
        if not req or req.StatusCode ~= 200 then
            vape:CreateNotification("Onyx", "API Unreachable. Guest mode.", 7,'warning')
            return 'guest', 'GUEST', 'PASSWORD'
        end

        local decoded
        pcall(function() decoded = http:JSONDecode(req.Body) end)
        if not decoded then
            vape:CreateNotification("Onyx", "Bad login response. Guest mode.", 7,'warning')
            return 'guest', 'GUEST', 'PASSWORD'
        end
        role = decoded.role or "guest"
        U = username
        P = password

        vape:CreateNotification("Onyx", "Logged in as "..U.." ("..role..")", 7)
    end)

    return role, U, P
end



function login:SlientLogin()
    local role, U, P = "", "", ""

    pcall(function()
        local req = postLogin(username, password)
        if not req or req.StatusCode ~= 200  then
            vape:CreateNotification("Onyx", "API Unreachable. Guest mode.", 7,'warning')
            return 'guest', 'GUEST', 'PASSWORD'
        end

        local decoded
        pcall(function() decoded = http:JSONDecode(req.Body) end)
        if not decoded then
            vape:CreateNotification("Onyx", "Bad login response. Guest mode.", 7,'warning')
            return 'guest', 'GUEST', 'PASSWORD'
        end

        role = decoded.role or "guest"
        U = username
        P = password
    end)

    return role, U, P
end

return login
