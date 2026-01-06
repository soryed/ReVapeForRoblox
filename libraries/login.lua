local login = {}



if not shared.vape then repeat task.wait() until shared.vape end
local cloneref = cloneref or function(obj) return obj end
local vape = shared.vape
local http = cloneref(game:GetService("HttpService"))

local ApiBase = "https://onyxclient.fsl58.workers.dev/"
local LoginBase = ApiBase.."login"
local ResetBase = ApiBase.."reset"
local UpgradeBase = ApiBase.."role"
local SignupBase = ApiBase.."signup"
local HwidResetBase = ApiBase.."reset-hwid"
local username = getgenv().username or "GUEST"
local password = getgenv().password or "PASSWORD"

local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Onyx', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/qyroke2/ReVapeForRoblox/'..readfile('ReVape/profiles/commit.txt')..'/'..select(1, path:gsub('ReVape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local HWID_PATH = "ReVape/accounts/hwid.txt"
local GenLib = loadstring(downloadFile("ReVape/libraries/Generator.lua"), "Generator")()

local function generateHWID()
	math.randomseed(os.time() * 9e9) -- true randomness.
    return GenLib:UUID()
end

local function getHWID()
    if not isfile(HWID_PATH) then
        writefile(HWID_PATH, generateHWID())
    end
    return readfile(HWID_PATH)
end

local function decodeSafe(body)
    local ok, result = pcall(function() return http:JSONDecode(body) end)
    return ok and result or nil
end

local function postRequest(url, bodyTable)
    local req = request or http_request or syn.request
    if not req then return nil, "No HTTP request function available" end
    return req({
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = http:JSONEncode(bodyTable)
    })
end

local function createAccount(U, P)
    return postRequest(SignupBase, { username = U, password = P, hwid = getHWID() })
end

local function postLogin(U, P)
    return postRequest(LoginBase, { username = U, password = P, hwid = getHWID() })
end

local function resetPassword(U, NP, R, OP)
    return postRequest(ResetBase, { user = U, newPassword = NP, requester = R, oldPassword = OP })
end

local function roleUpgrader(T, NR, R)
    return postRequest(UpgradeBase, { target = T, newRole = NR, requester = R })
end

local function resetHWIDRequest(requester, pass, target)
    return postRequest(HwidResetBase, { username = requester, password = pass, target = target })
end

function login:CreateAccount(U, P)
    local resp, err = createAccount(U, P)
    if not resp then return false, err end
    if resp.StatusCode ~= 200 then return false, "Server returned "..resp.StatusCode end

    local body = decodeSafe(resp.Body)
    if not body then return false, "Invalid JSON returned" end
    if body.status == "error" then return false, body.message or "Unknown error" end

    return true, body
end

function login:Login()
    local role, U, P = "", username, password
    local ok = pcall(function()
        local req = postLogin(username, password)
		if req.StatusCode == 403 then
	        vape:CreateNotification("Onyx", "API HWID Mis-Match. Guest mode.", 7,'warning')
	        role, U, P = "guest", "GUEST", "PASSWORD"
	        return
		end
        if not req or req.StatusCode ~= 200 then
            vape:CreateNotification("Onyx", "API Unreachable. Guest mode.", 7,'warning')
            role, U, P = "guest", "GUEST", "PASSWORD"
            return
        end
        local decoded = decodeSafe(req.Body)
        if not decoded then
            vape:CreateNotification("Onyx", "Bad login response. Guest mode.", 7,'warning')
            role, U, P = "guest", "GUEST", "PASSWORD"
            return
        end
        role = decoded.role or "guest"
        vape:CreateNotification("Onyx", "Logged in as "..U.." ("..role..")", 7)
    end)
    return role, U, P
end

function login:SlientLogin()
    local role, U, P = "", username, password
    local ok = pcall(function()
        local req = postLogin(username, password)
		if req.StatusCode == 403 then
	        vape:CreateNotification("Onyx", "API HWID Mis-Match. Guest mode.", 7,'warning')
	        role, U, P = "guest", "GUEST", "PASSWORD"
	        return
		end
        if not req or req.StatusCode ~= 200 then
            vape:CreateNotification("Onyx", "API Unreachable. Guest mode.", 7,'warning')
            role, U, P = "guest", "GUEST", "PASSWORD"
            return
        end
        local decoded = decodeSafe(req.Body)
        if not decoded then
            vape:CreateNotification("Onyx", "Bad login response. Guest mode.", 7,'warning')
            role, U, P = "guest", "GUEST", "PASSWORD"
            return
        end
        role = decoded.role or "guest"
    end)
    return role, U, P
end

function login:ResetPassword(user, newPass, requester, oldPass)
    local resp, err = resetPassword(user, newPass, requester, oldPass)
    if not resp then return false, err end
    if resp.StatusCode ~= 200 then return false, "Server returned "..resp.StatusCode end
    local body = decodeSafe(resp.Body)
    if not body then return false, "Invalid JSON returned" end
    if body.error then return false, body.error end
    return true, body
end

function login:RoleUpgrader(target, newRole, requester)
    local resp, err = roleUpgrader(target, newRole, requester)
    if not resp then return false, err end
    if resp.StatusCode ~= 200 then return false, "Server returned "..resp.StatusCode end
    local body = decodeSafe(resp.Body)
    if not body then return false, "Invalid JSON returned" end
    if body.error then return false, body.error end
    return true, body
end

function login:ResetHWID(targetUsername)
    if not targetUsername then vape:CreateNotification("Onyx","Couldn't find targets username",7,'alert') return false, "HWID reset failed"  end
    local resp, err = resetHWIDRequest(username, password, targetUsername)
    if not resp then return false, err end
    local body = decodeSafe(resp.Body)
    if not body then vape:CreateNotification("Onyx","Invalid server response",7,'alert') return false, "Invalid server response" end
    if resp.StatusCode ~= 200 then vape:CreateNotification("Onyx" ,body.message or "HWID reset failed",7,'alert')  return false, body.message or "HWID reset failed" end

    if targetUsername == username then if isfile(HWID_PATH) then delfile(HWID_PATH) end end

    vape:CreateNotification("Onyx","HWID reset successful. Relog to bind new device.",7)
    return true, body
end

return login
