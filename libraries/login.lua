local login = {}
if not shared.vape then
    repeat task.wait() until shared.vape
end

local vape = shared.vape
local httpService = game:GetService('HttpService')
local api = "https://vapeclient.fsl58.workers.dev"


--local username = getgenv().username or "USER"
--local password = getgenv().password or "PASSWORD"
local username = "USER"
local password = "PASSWORD"
local function sendRequest(url, data)
    local reqFunc = request or syn.request or http_request
    if not reqFunc then
        error("No request function available!")
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
    local success, result = pcall(function()
        local req = sendRequest(api, { username = username, password = password })

        print("StatusCode:", req.StatusCode)
        print("Body:", req.Body)

        if req.StatusCode ~= 200 then
            return "Down"
        end

        local decoded
        local ok, err = pcall(function()
            decoded = httpService:JSONDecode(req.Body)
        end)

        if not ok then
            print("JSON Decode failed:", err)
            return "Down"
        end

        print("Decoded Response:", decoded)

        local status = decoded.role or "USER"

        vape:CreateNotification("ReVape", "Logged in as "..username.." (Type "..status..")", 7)
        return status
    end)

    if not success or result == "Down" then
        vape:CreateNotification("ReVape", "Login failed or API is down. Continue as 'GUEST'", 7)
        return "guest"
    end

    return result
end

return login
