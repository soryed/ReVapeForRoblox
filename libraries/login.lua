local login = {}
if not shared.vape then
    repeat task.wait() until shared.vape
end

local vape = shared.vape
local httpService = game:GetService('HttpService')
local api = "https://revapeclient.vercel.app"

local username = getgenv().username or "USER"
local password = getgenv().password or "PASSWORD"

local function sendRequest(url, data)
    local requestFunction = request or syn.request or http_request
    if not requestFunction then
        error("No request function found!")
    end

    local req = requestFunction({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(data)
    })

    return req
end

function login:Login()
    local success, res = pcall(function()
        local req = sendRequest(api .. "/login", {
            username = username,
            password = password
        })

        if req.StatusCode ~= 200 then
            return "Down"
        end

        local API = httpService:JSONDecode(req.Body)
        local status = API.role or "USER"

        vape:CreateNotification("ReVape", "Logged in as "..username.." (Type "..status..")", 7)

        return status
    end)

    if not success or res == "Down" then
        vape:CreateNotification("ReVape", "Login failed or API is down. Continue as 'GUEST'", 7)
        return "guest"
    end

    return res
end

return login
