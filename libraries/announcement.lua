local annc
print('not finished twinny')

local function create(name, props)
    local obj = Instance.new(name)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end


function annc:Announce(TYPE,Title,Time,Setting,Color)
  
end

return annc
