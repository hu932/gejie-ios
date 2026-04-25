@echo off
chcp 65001 >nul
echo =====================================
echo  启用 WSL2 + 虚拟机平台
echo =====================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 请右键此文件，选择「以管理员身份运行」！
    pause
    exit /b 1
)

echo [1/3] 启用 WSL 功能...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
echo.

echo [2/3] 启用虚拟机平台...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
echo.

echo [3/3] 设置 WSL 默认版本为 2...
wsl --set-default-version 2
echo.

echo =====================================
echo  完成！请重启电脑后运行以下命令：
echo  wsl -d Ubuntu
echo  然后执行格界编译脚本。
echo =====================================
echo.
pause
