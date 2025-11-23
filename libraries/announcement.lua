local annc = {}
print('not finished twinny')
local vape = shared.vape
local function create(name, props)
    local obj = Instance.new(name)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end


function annc:Announce(TYPE,Message,Title,Time,Setting,Color)
    vape:CreateNotification(Title,Message,Time,TYPE)
end

return annc
