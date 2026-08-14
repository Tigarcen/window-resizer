## 这是一个主要用于强制改变Windows窗口大小的小工具

### 构建为exe的命令
 ```shell
 ps2exe -InputFile ".\ForceResize.ps1" -OutputFile ".\ForceResize.exe" -RequireAdmin -NoConsole
 ```

### 基础功能
 + 拾取窗口
  点击这个按钮之后点击要改变大小的窗口
 + 自动填充窗口pid以及宽高
 + 强制改变窗口大小的按钮
  - 其实做这个的初衷是，我用网易UU远程的时候，发现它的视窗宽高有下限，不利于摸鱼

### 扩展功能
 + 在小工具界面里手动调节窗口的位置
  - 可以自行去任务管理器里找窗口的pid
  - 这个功能可以用于把飞出显示器可视范围的窗口拉回来