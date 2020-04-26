# cocos2d-x lua windows 下的学习环境

* cocos2d-x 版本:3.17.2

## 一、目录介绍

```bash
|- res # 资源
|- src # lua code
|- win32 # windows 下 cocos2d-x 应用程序
|- run_simlulator_win.bat # windows 下启动程序批处理
```

## 二、Demo 介绍

### 2.1 demo 粘包处理

```lua
-- in main.lua
local function main()
    require("app.MyApp"):create():run()
    require("net.socket.Demo")
end
```
