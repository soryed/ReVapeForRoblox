local login = {}
if not shared.vape then
    repeat task.wait() until shared.vape
end

local vape = shared.vape
local httpService = game:GetService('HttpService')
local api = "https://vapeclient.fsl58.workers.dev"


local username = getgenv().username or "GUEST"
local password = getgenv().password or "PASSWORD"

local function sendRequest(url, data)
    local reqFunc = request or syn.request or http_request
    if not reqFunc then
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
    local status = ""
    local success, result = pcall(function()
        local req = sendRequest(api, { username = username, password = password })


        if req.StatusCode ~= 200 then
            return "Down"
        end

        local decoded
        local ok, err = pcall(function()
            decoded = httpService:JSONDecode(req.Body)
        end)

        if not ok then
            return "Down"
        end


       status = decoded.role or "guest"

        vape:CreateNotification("ReVape", "Logged in as "..username.." (Type "..status..")", 7)
    end)

    if not success or result == "Down" then
        vape:CreateNotification("ReVape", "Login failed or API is down. Continue as 'GUEST'", 7)
        return "guest"
    end

 return status

end

return login
