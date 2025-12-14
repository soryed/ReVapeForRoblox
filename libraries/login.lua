local login = {}
if not shared.vape then repeat task.wait() until shared.vape end
local cloneref = cloneref or function(obj)
    return obj
end

local vape = shared.vape
local http = cloneref(game:GetService("HttpService"))

local ApiBase = "https://onyxclient.fsl58.workers.dev/"
local LoginBase = ApiBase..'login'
local ResetBase = ApiBase..'reset'
local UpgradeBase = ApiBase..'role'
local SignupBase = ApiBase.."signup"
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


local function resetPassword(U, NP, R, OP)
    local req = request or http_request or syn.request
    if not req then 
        return nil, "No HTTP request function available"
    end

    local response = req({
        Url = ResetBase,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = http:JSONEncode({
            user = U,
            newPassword = NP,
            requester = R,
            oldPassword = OP
        })
    })

    return response
end

local function roleUpgrader(T, NR, R)
    local req = request or http_request or syn.request
    if not req then 
        return nil, "No HTTP request function available"
    end

    local response = req({
        Url = UpgradeBase,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = http:JSONEncode({
            target = T,
            newRole = NR,
            requester = R
        })
    })

    return response
end

local function createAccount(U, P)
    local req = request or http_request or syn.request
    if not req then 
        return nil, "No HTTP request function available"
    end

    local response = req({
        Url = SignupBase,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = http:JSONEncode({
            username = U,
            password = P
        })
    })

    return response
end

local function postLogin(U, P)
    local req = request or http_request or syn.request
    if not req then
        return nil, "No HTTP request function available"
    end

    return req({
        Url = LoginBase,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = http:JSONEncode({
            username = U,
            password = P
        })
    })
end

local function decodeSafe(body)
    local ok, result = pcall(function()
        return http:JSONDecode(body)
    end)
    return ok and result or nil
end

function login:ResetPassword(user, newPass, requester, oldPass)
    local resp, err = resetPassword(user, newPass, requester, oldPass)

    if not resp then
        return false, err
    end

    if resp.StatusCode ~= 200 then
        return false, "Server returned " .. tostring(resp.StatusCode)
    end

    local body = decodeSafe(resp.Body)
    if not body then 
        warn("Invaild JSON returned")
        return false, "Invalid JSON returned"
    end

    if body.error then
        warn(body.error or 'Unknown error')
 
        return false, body.error
    end

    return true, body
end

function login:RoleUpgrader(target, newRole, requester)
    local resp, err = roleUpgrader(target, newRole, requester)

    if not resp then
        return false, err
    end

    if resp.StatusCode ~= 200 then
        return false, "Server returned " .. tostring(resp.StatusCode)
    end

    local body = decodeSafe(resp.Body)
    if not body then 
        warn("Invaild JSON returned")
        return false, "Invalid JSON returned"
    end

    if body.error then
        warn(body.error or 'Unknown error')

        return false, body.error
    end

    return true, body
end

function login:CreateAccount(username, password)
    local resp, err = createAccount(username, password)

    if not resp then
        return false, err
    end

    if resp.StatusCode ~= 200 then
        return false, "Server returned " .. tostring(resp.StatusCode)
    end

    local body = decodeSafe(resp.Body)
    if not body then
        warn("Invaild JSON returned")
        return false, "Invalid JSON returned"
    end

    if body.status == "error" then
        warn(body.message or 'Unknown error')
        return false, body.message or "Unknown error"
    end

    return true, body
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
        if not decoded  then
            vape:CreateNotification("Onyx", "Bad login response. Guest mode.", 7,'warning')
            return 'guest', 'GUEST', 'PASSWORD'
        end
        role = decoded.role or "guest"
        U = username
        P = password

        vape:CreateNotification("Onyx", "Logged in as "..U.." ("..role..")", 7)
    end)
    vape.role = role
    vape.user = U
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
    vape.role = role
    vape.user = U
    return role, U, P
end

return login
