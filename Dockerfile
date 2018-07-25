# escape=`

FROM microsoft/dotnet-framework:4.7.1

# Restore the default Windows shell for correct batch processing below.
SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Install Build Tools excluding workloads and components with known issues.
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.ManagedDesktop `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --includeRecommended `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0



SHELL ["powershell"]

ADD setpath.ps1 C:\setpath.ps1
RUN .\setpath.ps1

ADD CTRE.exe C:\CTRE.exe
RUN Start-Process C:\CTRE.exe -wait -argumentlist '/S /D=C:\Users\Public\Documents\'

ADD ["NET", "C:/BuildTools/MSBuild/Microsoft/.NET Micro Framework"]

ADD ["NSIS", "C:/Program Files (x86)/NSIS"]
ADD NSIS.reg NSIS.reg
RUN REG IMPORT NSIS.reg
ADD setpathNSIS.ps1 setpathNSIS.ps1
RUN .\setpathNSIS.ps1
ADD java.exe java.exe
RUN Start-Process .\java.exe -wait -argumentlist '/s INSTALL_SILENT=Enable AUTO_UPDATE=Disable SPONSORS=Disable NOSTARTMENU=Enable REBOOT=Disable'
ADD javaEnv.ps1 javaEnv.ps1
RUN .\javaEnv.ps1

RUN Remove-Item TEMP\vs_buildtools.exe
RUN Remove-Item setpath.ps1
RUN Remove-Item CTRE.exe
RUN Remove-Item NSIS.reg
RUN Remove-Item setpathNSIS.ps1
RUN Remove-Item java.exe
RUN Remove-Item javaEnv.ps1

# Start developer command prompt with any other commands specified.
#ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

# Default to PowerShell if no other command specified.
CMD ["powershell"]
