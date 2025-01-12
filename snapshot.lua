
local listenerCode = -1

local count = 0
-- 创建保存快照的函数
function SaveSnapshot(dlgData)
    local sprite = app.sprite
    local spriteName = "temp"
    local scale = dlgData.scale

    if not sprite then
        app.alert("No active sprite.")
        return
    end
    if app.filename == "" then
        spriteName = "temp"
    else
        spriteName = app.fs.fileTitle(sprite.filename).."Snapshot"
    end
    -- 获取当前时间戳，用于命名文件
    local timestamp = os.date("%Y%m%d%H%M%S")

    -- 定义文件名，使用帧编号或时间戳
    local filename = string.format("%s\\snapshot_%s_%d.png", spriteName, timestamp,count)

    local filepath = app.fs.filePath(sprite.filename)
    local fullPath = filepath .. "\\" .. filename
    local image = app.image
    -- 保存快照
    --渲染第一帧图像
    local image = Image(sprite)
    image:resize(scale*image.width,scale*image.height)
    image:saveAs(fullPath)
    count = count + 1 
    --app.alert("Snapshot saved as: " .. fullPath)
end




-- 创建帮助对话框
local help = Dialog("Help")
    :label{text="Snapshot Plugin"}
    :separator()
    :label{text="Press the button to save a snapshot of the current image."}
    :newrow()
    :label{text="Snapshots will be saved in the same directory as the sprite."}
    :newrow()
    :label{text="Each snapshot will be named as snapshot_<count>_<timestamp>.png."}

-- 创建插件UI
local dlg = Dialog("Snapshot Plugin")

function AddListener(dlgData)
    if dlgData.SaveOnChange == true then
        listenerCode = app.sprite.events:on('change',
        function()
            SaveSnapshot(dlg.data)
        end
        )  
    else
        app.sprite.events:off(listenerCode)
    end
end


dlg
    -- 保存快照按钮
    :button{text="Save Snapshot", 
            onclick=function() 
            SaveSnapshot(dlg.data)      
            end}
    :check{ id="SaveOnChange",
           text="SaveOnChange",
           selected=false,
           onclick= function ()
                    AddListener(dlg.data) 
                    end}
    :slider{id="scale", min=1, max=10.0, value=1.0}
    -- 帮助按钮
    :button{text="Help", onclick=function() help:show{} end}
    -- 退出按钮
    -- 退出时清理事件绑定，由用户可能不使用saveOnChange功能，此时listenerCode不合法，需要进行判断
    :button{text="Close", onclick=function() 
                                    dlg:close() 
                                    if listenerCode ~= -1 then
                                        app.sprite.events:off(listenerCode)     
                                    end
                                   end}
    :show{wait=false}

