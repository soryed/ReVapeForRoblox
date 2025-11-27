local login = {}
if not shared.vape then
    repeat task.wait() until shared.vape
end

local vape = shared.vape
local httpService = game:GetService('HttpService')
local api = "https://vapeclient.fsl58.workers.dev"
local username = ""
local password = ""

if getgenv().TestAccount then
     username = "GUEST"
     password = "PASSWORD"
else
     username = getgenv().username or "GUEST"
     password = getgenv().password or "PASSWORD"
    
end

local function getHardwareId() -- hwid checks finna be lit
    local hardwareInfo = ""
    
    if syn and syn.crypt then
        hardwareInfo = syn.crypt.hash(syn.crypt.random(16))
    elseif getexecutorname then
        hardwareInfo = getexecutorname() .. tostring(os.clock())
    else
        hardwareInfo = game:GetService("RbxAnalyticsService"):GetClientId() .. tostring(tick())
    end
    
    local hash = ""
    for i = 1, 32 do
        local byte = string.byte(hardwareInfo, (i % #hardwareInfo) + 1)
        hash = hash .. string.format("%02x", byte)
    end
    
    return hash:sub(1, 16)
end

local function ensureAccountsFolder()
    if not isfolder("ReVape/accounts") then
        makefolder("ReVape/accounts")
    end
end

local function saveAccountFiles(S, U, P)
    ensureAccountsFolder()
    vape.role = tostring(S)
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
            vape:CreateNotification("Onyx", "Login failed, Error Code 200. Continue as 'GUEST'", 7)
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
            vape:CreateNotification("Onyx", "Login failed, failed to decode or couldn't be good enough. Continue as 'GUEST'", 7)
            return "guest", "GUEST", "PASSWORD"
        end
    
        status = decoded.role or "guest"
        S = status
        U = username
        P = password
        status = string.upper(status)
        vape:CreateNotification('Onyx', "Initialized as " .. U .. " with role " .. S, 7)
        saveAccountFiles(S, U, P)
    end)

    if not success or result == "Down" then
        S = "guest"
        U = "GUEST"
        P = "PASSWORD"
        saveAccountFiles(S, U, P)
        vape:CreateNotification("Onyx", "Login failed or API is down. Continue as 'GUEST'", 7)
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
           vape:CreateNotification("Onyx", "Login failed Cloudflare is down, Error Code 200. Continue as 'GUEST'", 7)
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
                print("didnt not decode or be enough good")
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
       print("Login failed or API is down. Continue as 'GUEST'")
        return "guest", "GUEST", "PASSWORD"
    end

    return S, U, P
end

return login
