# Window Resizer

## 一个轻量级的 Windows 窗口大小与位置调整工具。通过 PID 或鼠标点击拾取目标窗口，精准控制其尺寸和屏幕位置。

## 🎯 主要功能

### 🔍 拾取窗口
点击 **"拾取窗口"** 按钮，然后点击任意目标窗口，即可自动获取其 PID、宽高和当前位置。

### 📐 强制调整大小
输入目标宽度和高度，点击 **"强制调整大小"** 即可改变窗口尺寸。

> 💡 **初衷**：使用网易 UU 远程时，其视窗大小有下限，不利于摸鱼时观看视频/文档。这个小工具就是为了突破这个限制而生。

### 🧭 窗口定位（扩展功能）
通过 X/Y 滑块，手动调整窗口在屏幕上的位置。

> 💡 **适用场景**：当某个窗口因误操作飞出显示器可视范围时，可用此功能将其"拉"回来。

---

## 🚀 使用方法

### 方式一：直接运行 EXE（推荐）
下载 [Releases](https://github.com/Tigarcen/window-resizer/releases) 中的 `ForceResize.exe`，双击运行即可。无需安装任何环境。

### 方式二：运行 PowerShell 脚本
```powershell
.\ForceResize.ps1
```

### 构建为exe
```shell
ps2exe -InputFile ".\ForceResize.ps1" -OutputFile ".\ForceResize.exe" -RequireAdmin -NoConsole
```