if not shared.vape then
    repeat task.wait() until shared.vape
end

local vape = shared.vape
local httpService = game:GetService('HttpService')
local api = "https://revapeclient.vercel.app/"

local license = ({...})[1] or {}

local username = getgenv().username or "USER"
local password = getgenv().password or "PASSWORD"

local success, res = pcall(function()
    local req = request({
        Url = api .. "/login",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode({
            username = username,
            password = password
        })
    })

    if req.StatusCode == 404 or req.StatusCode == 502 then
        return "Down"
    end

    local API
    local ok, err = pcall(function()
        API = httpService:JSONDecode(req.Body)
    end)

    if not ok then
        return "Down"
    end

    local status = API.role or "USER"

    vape:CreateNotification("ReVape", "Logged in as "..username.." (Type "..status..")", 7)
end)

if not success or res == "Down" then
    vape:CreateNotification("ReVape", "Login failed or API is down. Continue as 'GUEST'", 7)
end
