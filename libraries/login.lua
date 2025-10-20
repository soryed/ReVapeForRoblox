local login = {}
if not shared.vape then
    repeat task.wait() until shared.vape
end

local vape = shared.vape
local httpService = game:GetService('HttpService')
local api = "https://vapeclient.fsl58.workers.dev"

local username = getgenv().username or "GUEST"
local password = getgenv().password or "PASSWORD"

local function ensureAccountsFolder()
    if not isfolder("ReVape/accounts") then
        makefolder("ReVape/accounts")
    end
end

local function saveAccountFiles(S, U, P)
    ensureAccountsFolder()
    shared.vape.Libraries.Role = tostring(S)
    writefile("ReVape/accounts/username.txt", tostring(U))
    writefile("ReVape/accounts/password.txt", tostring(P))
end

local function sendRequest(url, data)
    local reqFunc = request or syn.request or http_request
    if not reqFunc then
        return { StatusCode = 0, Body = "" }
    end
    return reqFunc({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(data)
    })
end

function login:Login()
    local status, S, U, P = "", "","",""
    local success, result = pcall(function()
        local req = sendRequest(api, { username = username, password = password })

        if not req or req.StatusCode ~= 200 then
            S = "guest"
            U = "GUEST"
            P = "PASSWORD"
            saveAccountFiles(S, U, P)
            return "guest", "GUEST", "PASSWORD"
        end

        local decoded
        local ok, err = pcall(function()
            decoded = httpService:JSONDecode(req.Body)
        end)

        if not ok or not decoded then
            S = "guest"
            U = "GUEST"
            P = "PASSWORD"
            saveAccountFiles(S, U, P)
            return "guest", "GUEST", "PASSWORD"
        end

        status = decoded.role or "guest"
        S = status
        U = username
        P = password
        status = string.upper(status)
        vape:CreateNotification("ReVape", "Logged in as "..username.." (Type '"..status.."')", 7)
        saveAccountFiles(S, U, P)
    end)

    if not success or result == "Down" then
        S = "guest"
        U = "GUEST"
        P = "PASSWORD"
        saveAccountFiles(S, U, P)
        vape:CreateNotification("ReVape", "Login failed or API is down. Continue as 'GUEST'", 7)
        return "guest", "GUEST", "PASSWORD"
    end

    return S, U, P
end

function login:SlientLogin()
    local status, S, U, P = "", "","",""
    local success, result = pcall(function()
        local req = sendRequest(api, { username = username, password = password })

        if not req or req.StatusCode ~= 200 then
            S = "guest"
            U = "GUEST"
            P = "PASSWORD"
            saveAccountFiles(S, U, P)
            return "guest", "GUEST", "PASSWORD"
        end

        local decoded
        local ok, err = pcall(function()
            decoded = httpService:JSONDecode(req.Body)
        end)

        if not ok or not decoded then
            S = "guest"
            U = "GUEST"
            P = "PASSWORD"
            saveAccountFiles(S, U, P)
            return "guest", "GUEST", "PASSWORD"
        end

        status = decoded.role or "guest"
        S = status
        U = username
        P = password
        status = string.upper(status)
        saveAccountFiles(S, U, P)
    end)

    if not success or result == "Down" then
        S = "guest"
        U = "GUEST"
        P = "PASSWORD"
        saveAccountFiles(S, U, P)
        return "guest", "GUEST", "PASSWORD"
    end

    return S, U, P
end

return login
