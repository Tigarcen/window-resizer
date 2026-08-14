# ======================================================
# 窗口控制工具 (大小 + 位置) - 静默退出版
# 兼容 PowerShell v2+，添加 SWP_NOACTIVATE
# ======================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------- 定义 Windows API ----------
if (-not ([System.Type]::GetType("WinAPI"))) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public class WinAPI {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(
        IntPtr hWnd,
        IntPtr hWndInsertAfter,
        int X, int Y,
        int cx, int cy,
        uint uFlags
    );

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll")]
    public static extern IntPtr WindowFromPoint(POINT Point);

    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern IntPtr LoadCursor(IntPtr hInstance, int lpCursorName);

    [DllImport("user32.dll")]
    public static extern IntPtr SetCursor(IntPtr hCursor);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);

    // 鼠标事件常量
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;

    public struct POINT {
        public int X;
        public int Y;
    }

    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@
}

# ---------- 获取屏幕分辨率 ----------
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$screenWidth = $screen.Width
$screenHeight = $screen.Height

# ---------- 创建主窗体 ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "窗口控制工具 (大小 + 位置)"
$form.Size = New-Object System.Drawing.Size(450, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $true

# ---------- 第一行：拾取按钮 + PID ----------
$btnPick = New-Object System.Windows.Forms.Button
$btnPick.Text = "拾取窗口"
$btnPick.Location = New-Object System.Drawing.Point(20, 20)
$btnPick.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($btnPick)

$lblPid = New-Object System.Windows.Forms.Label
$lblPid.Text = "进程 PID："
$lblPid.Location = New-Object System.Drawing.Point(140, 25)
$lblPid.Size = New-Object System.Drawing.Size(70, 25)
$form.Controls.Add($lblPid)

$txtPid = New-Object System.Windows.Forms.TextBox
$txtPid.Location = New-Object System.Drawing.Point(210, 23)
$txtPid.Size = New-Object System.Drawing.Size(200, 25)
$form.Controls.Add($txtPid)

# ---------- 第二行：宽度 ----------
$lblWidth = New-Object System.Windows.Forms.Label
$lblWidth.Text = "宽度 (px)："
$lblWidth.Location = New-Object System.Drawing.Point(20, 70)
$lblWidth.Size = New-Object System.Drawing.Size(80, 25)
$form.Controls.Add($lblWidth)

$txtWidth = New-Object System.Windows.Forms.TextBox
$txtWidth.Location = New-Object System.Drawing.Point(110, 68)
$txtWidth.Size = New-Object System.Drawing.Size(300, 25)
$form.Controls.Add($txtWidth)

# ---------- 第三行：高度 ----------
$lblHeight = New-Object System.Windows.Forms.Label
$lblHeight.Text = "高度 (px)："
$lblHeight.Location = New-Object System.Drawing.Point(20, 115)
$lblHeight.Size = New-Object System.Drawing.Size(80, 25)
$form.Controls.Add($lblHeight)

$txtHeight = New-Object System.Windows.Forms.TextBox
$txtHeight.Location = New-Object System.Drawing.Point(110, 113)
$txtHeight.Size = New-Object System.Drawing.Size(300, 25)
$form.Controls.Add($txtHeight)

# ---------- 第四行：强制调整按钮 ----------
$btnResize = New-Object System.Windows.Forms.Button
$btnResize.Text = "强制调整大小"
$btnResize.Location = New-Object System.Drawing.Point(150, 160)
$btnResize.Size = New-Object System.Drawing.Size(130, 35)
$form.Controls.Add($btnResize)

# ---------- 第五行：屏幕分辨率显示 ----------
$lblResolution = New-Object System.Windows.Forms.Label
$lblResolution.Text = "屏幕分辨率：$screenWidth × $screenHeight"
$lblResolution.Location = New-Object System.Drawing.Point(20, 215)
$lblResolution.Size = New-Object System.Drawing.Size(400, 25)
$lblResolution.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblResolution)

# ---------- 第六行：X 位置滑块 ----------
$lblX = New-Object System.Windows.Forms.Label
$lblX.Text = "X 位置："
$lblX.Location = New-Object System.Drawing.Point(20, 255)
$lblX.Size = New-Object System.Drawing.Size(60, 25)
$form.Controls.Add($lblX)

$trackX = New-Object System.Windows.Forms.TrackBar
$trackX.Location = New-Object System.Drawing.Point(80, 250)
$trackX.Size = New-Object System.Drawing.Size(270, 45)
$trackX.Minimum = 0
$trackX.Maximum = $screenWidth - 1
$trackX.TickFrequency = 50
$trackX.Value = 0
$form.Controls.Add($trackX)

$lblXVal = New-Object System.Windows.Forms.Label
$lblXVal.Text = "0"
$lblXVal.Location = New-Object System.Drawing.Point(360, 255)
$lblXVal.Size = New-Object System.Drawing.Size(50, 25)
$form.Controls.Add($lblXVal)

# ---------- 第七行：Y 位置滑块 ----------
$lblY = New-Object System.Windows.Forms.Label
$lblY.Text = "Y 位置："
$lblY.Location = New-Object System.Drawing.Point(20, 305)
$lblY.Size = New-Object System.Drawing.Size(60, 25)
$form.Controls.Add($lblY)

$trackY = New-Object System.Windows.Forms.TrackBar
$trackY.Location = New-Object System.Drawing.Point(80, 300)
$trackY.Size = New-Object System.Drawing.Size(270, 45)
$trackY.Minimum = 0
$trackY.Maximum = $screenHeight - 1
$trackY.TickFrequency = 50
$trackY.Value = 0
$form.Controls.Add($trackY)

$lblYVal = New-Object System.Windows.Forms.Label
$lblYVal.Text = "0"
$lblYVal.Location = New-Object System.Drawing.Point(360, 305)
$lblYVal.Size = New-Object System.Drawing.Size(50, 25)
$form.Controls.Add($lblYVal)

# ---------- 状态标签 ----------
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "就绪"
$lblStatus.Location = New-Object System.Drawing.Point(20, 370)
$lblStatus.Size = New-Object System.Drawing.Size(400, 25)
$lblStatus.ForeColor = "Blue"
$form.Controls.Add($lblStatus)

# ---------- 拾取模式变量 ----------
$script:isPicking = $false
$script:timer = New-Object System.Windows.Forms.Timer
$script:timer.Interval = 50
$script:originalCursor = $null
$script:currentPid = 0   # 保存当前选中的 PID

# ---------- 更新滑块数值显示 ----------
function Update-SliderLabels {
    $lblXVal.Text = $trackX.Value.ToString()
    $lblYVal.Text = $trackY.Value.ToString()
}

# 定义常量（添加 SWP_NOACTIVATE）
$SWP_NOACTIVATE = 0x0010

# 滑块值变化事件
$trackX.Add_ValueChanged({
    $lblXVal.Text = $trackX.Value.ToString()
    Move-WindowToPosition
})

$trackY.Add_ValueChanged({
    $lblYVal.Text = $trackY.Value.ToString()
    Move-WindowToPosition
})

# ---------- 移动窗口到滑块位置 ----------
function Move-WindowToPosition {
    if ($script:currentPid -le 0) {
        # 如果没有有效 PID，尝试从文本框读取
        $pidInput = $txtPid.Text.Trim()
        if ($pidInput) {
            $pid = $pidInput -as [int]
            if ($pid -gt 0) {
                $script:currentPid = $pid
            } else {
                return
            }
        } else {
            return
        }
    }

    try {
        $proc = Get-Process -Id $script:currentPid -ErrorAction Stop
        $hwnd = $proc.MainWindowHandle
        if ($hwnd -eq 0) { return }
    } catch {
        return
    }

    $newX = $trackX.Value
    $newY = $trackY.Value

    # SWP_NOSIZE = 0x0001 (保持大小), SWP_NOZORDER = 0x0004
    $SWP_NOSIZE = 0x0001
    $SWP_NOZORDER = 0x0004

    # 添加 SWP_NOACTIVATE 防止目标窗口获得焦点
    [WinAPI]::SetWindowPos($hwnd, [IntPtr]::Zero, $newX, $newY, 0, 0, $SWP_NOSIZE -bor $SWP_NOZORDER -bor $SWP_NOACTIVATE) | Out-Null
}

# ---------- 拾取模式开始/停止 ----------
function Start-PickMode {
    $script:isPicking = $true
    $btnPick.Text = "✖ 取消"
    $btnPick.BackColor = "LightCoral"

    $txtPid.Enabled = $false
    $txtWidth.Enabled = $false
    $txtHeight.Enabled = $false
    $btnResize.Enabled = $false
    $trackX.Enabled = $false
    $trackY.Enabled = $false

    $hCursor = [WinAPI]::LoadCursor([IntPtr]::Zero, 32515) # IDC_CROSS
    if ($hCursor -ne [IntPtr]::Zero) {
        $script:originalCursor = [WinAPI]::SetCursor($hCursor)
    }

    $form.Opacity = 0.7
    $lblStatus.ForeColor = "DarkOrange"
    $lblStatus.Text = "请点击目标窗口（点击本工具无效）..."
    $script:timer.Start()
}

function Stop-PickMode {
    $script:isPicking = $false
    $script:timer.Stop()

    if ($script:originalCursor -ne $null) {
        [WinAPI]::SetCursor($script:originalCursor)
        $script:originalCursor = $null
    }

    $form.Opacity = 1.0
    $btnPick.Text = "🔍 拾取窗口"
    $btnPick.BackColor = "Control"
    $txtPid.Enabled = $true
    $txtWidth.Enabled = $true
    $txtHeight.Enabled = $true
    $btnResize.Enabled = $true
    $trackX.Enabled = $true
    $trackY.Enabled = $true

    if ($lblStatus.Text -eq "请点击目标窗口（点击本工具无效）...") {
        $lblStatus.ForeColor = "Blue"
        $lblStatus.Text = "已取消拾取"
    }
}

# ---------- 计时器事件（拾取窗口） ----------
$script:timer.Add_Tick({
    $left = [WinAPI]::GetAsyncKeyState(0x01)
    if ($left -band 0x8000) {
        Start-Sleep -Milliseconds 100
        while ([WinAPI]::GetAsyncKeyState(0x01) -band 0x8000) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 30
        }

        $pt = New-Object WinAPI+POINT
        if ([WinAPI]::GetCursorPos([ref]$pt)) {
            $hwnd = [WinAPI]::WindowFromPoint($pt)
            if ($hwnd -ne $form.Handle) {
                $procId = 0
                [WinAPI]::GetWindowThreadProcessId($hwnd, [ref]$procId)
                if ($procId -gt 0) {
                    # 获取窗口位置和尺寸
                    $rect = New-Object WinAPI+RECT
                    if ([WinAPI]::GetWindowRect($hwnd, [ref]$rect)) {
                        $posX = $rect.Left
                        $posY = $rect.Top
                        $width = $rect.Right - $rect.Left
                        $height = $rect.Bottom - $rect.Top

                        # 更新滑块
                        $trackX.Value = [Math]::Max(0, [Math]::Min($trackX.Maximum, $posX))
                        $trackY.Value = [Math]::Max(0, [Math]::Min($trackY.Maximum, $posY))
                        Update-SliderLabels

                        # ---- 自动填入宽度和高度 ----
                        $txtWidth.Text = $width.ToString()
                        $txtHeight.Text = $height.ToString()
                    }

                    $txtPid.Text = $procId.ToString()
                    $script:currentPid = $procId
                    $lblStatus.ForeColor = "Green"
                    $lblStatus.Text = "已获取 PID: $procId，位置 (${posX}, ${posY})，尺寸 ${width}x${height}"
                    Stop-PickMode
                    $form.TopMost = $true
                    $form.TopMost = $false
                    # 获取工具窗口的位置
                    $rect = New-Object WinAPI+RECT
                    [WinAPI]::GetWindowRect($form.Handle, [ref]$rect)

                    # 计算标题栏点击位置（左上角偏移 10 像素）
                    $clickX = $rect.Left + 10
                    $clickY = $rect.Top + 10

                    # 移动鼠标到标题栏
                    [WinAPI]::SetCursorPos($clickX, $clickY)

                    # 模拟鼠标左键点击（按下 + 释放）
                    [WinAPI]::mouse_event([WinAPI]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, [UIntPtr]::Zero)
                    Start-Sleep -Milliseconds 10
                    [WinAPI]::mouse_event([WinAPI]::MOUSEEVENTF_LEFTUP, 0, 0, 0, [UIntPtr]::Zero)
                    return
                } else {
                    $lblStatus.ForeColor = "Red"
                    $lblStatus.Text = "无法获取该窗口 PID，请重试"
                }
            } else {
                $lblStatus.ForeColor = "Red"
                $lblStatus.Text = "请勿点击本工具窗口，请点击目标窗口"
            }
        }
    }
})

# ---------- 拾取按钮点击 ----------
$btnPick.Add_Click({
    if ($script:isPicking) {
        Stop-PickMode
        $lblStatus.ForeColor = "Blue"
        $lblStatus.Text = "已取消"
    } else {
        Start-PickMode
    }
})

# ---------- 强制调整大小按钮 ----------
$btnResize.Add_Click({
    if ($script:isPicking) { Stop-PickMode }

    $lblStatus.ForeColor = "Blue"
    $lblStatus.Text = "正在处理..."

    $pidInput = $txtPid.Text.Trim()
    $wInput = $txtWidth.Text.Trim()
    $hInput = $txtHeight.Text.Trim()

    if (-not $pidInput -or -not $wInput -or -not $hInput) {
        $lblStatus.ForeColor = "Red"
        $lblStatus.Text = "错误：请填写所有输入框！"
        return
    }

    $targetPid = $pidInput -as [int]
    $width = $wInput -as [int]
    $height = $hInput -as [int]

    if ($targetPid -eq $null -or $targetPid -le 0) {
        $lblStatus.ForeColor = "Red"
        $lblStatus.Text = "错误：PID 必须是正整数！"
        return
    }
    if ($width -eq $null -or $width -le 0) {
        $lblStatus.ForeColor = "Red"
        $lblStatus.Text = "错误：宽度必须是正整数！"
        return
    }
    if ($height -eq $null -or $height -le 0) {
        $lblStatus.ForeColor = "Red"
        $lblStatus.Text = "错误：高度必须是正整数！"
        return
    }

    try {
        $proc = Get-Process -Id $targetPid -ErrorAction Stop
        $hwnd = $proc.MainWindowHandle
        if ($hwnd -eq 0) {
            $lblStatus.ForeColor = "Red"
            $lblStatus.Text = "错误：该进程无主窗口 (PID: $targetPid)"
            return
        }
    } catch {
        $lblStatus.ForeColor = "Red"
        $lblStatus.Text = "错误：找不到 PID 为 $targetPid 的进程"
        return
    }

    $SWP_NOSENDCHANGING = 0x0400
    $SWP_NOZORDER = 0x0004
    $SWP_NOMOVE = 0x0002

    # 添加 SWP_NOACTIVATE 防止目标窗口获得焦点
    $result = [WinAPI]::SetWindowPos(
        $hwnd,
        [IntPtr]::Zero,
        0, 0,
        $width, $height,
        $SWP_NOSENDCHANGING -bor $SWP_NOZORDER -bor $SWP_NOMOVE -bor $SWP_NOACTIVATE
    )

    if ($result) {
        $lblStatus.ForeColor = "Green"
        $lblStatus.Text = "成功！窗口已调整为 ${width}x${height}"
    } else {
        $lblStatus.ForeColor = "Red"
        $lblStatus.Text = "调整失败，请尝试以管理员身份运行本脚本"
    }
})

# ---------- 回车键支持 ----------
$txtPid.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { $btnResize.PerformClick() } })
$txtWidth.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { $btnResize.PerformClick() } })
$txtHeight.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { $btnResize.PerformClick() } })

# ---------- ★★★ 关键修改：窗体关闭时强制结束进程，避免任何弹窗 ★★★ ----------
$form.Add_FormClosed({
    # 先清理资源
    if ($script:isPicking) { Stop-PickMode }
    $script:timer.Stop()
    $script:timer.Dispose()
    # 强制终止整个进程，避免 ShowDialog 返回任何值
    [System.Environment]::Exit(0)
})

# ---------- 显示窗体 ----------
$form.ShowDialog()