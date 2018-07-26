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

ADD https://www.ctr-electronics.com/downloads/installers/CTRE%20Phoenix%20Framework%20v5.7.1.0.zip C:\CTRE.zip
ADD install_ctre.ps1 C:\install_ctre.ps1

RUN .\install_ctre.ps1

ADD ["NET", "C:/BuildTools/MSBuild/Microsoft/.NET Micro Framework"]

ADD ["NSIS", "C:/Program Files (x86)/NSIS"]
ADD NSIS.reg NSIS.reg
RUN REG IMPORT NSIS.reg
ADD setpathNSIS.ps1 setpathNSIS.ps1
RUN .\setpathNSIS.ps1

#I get an error if I try to make this the url
ADD java.exe C:\java.exe
RUN Start-Process .\java.exe -wait -argumentlist '/s INSTALL_SILENT=Enable AUTO_UPDATE=Disable SPONSORS=Disable NOSTARTMENU=Enable REBOOT=Disable'
ADD javaEnv.ps1 javaEnv.ps1
RUN .\javaEnv.ps1

RUN Remove-Item TEMP\vs_buildtools.exe
RUN Remove-Item setpath.ps1
RUN Remove-Item CTRE -recurse
RUN Remove-Item install_ctre.ps1
RUN Remove-Item NSIS.reg
RUN Remove-Item setpathNSIS.ps1
RUN Remove-Item java.exe
RUN Remove-Item javaEnv.ps1

WORKDIR "Program Files"
SHELL ["cmd", "/S", "/C"]
RUN rd /S /Q WindowsPowerShell\Modules\PSReadLine
WORKDIR /

# Start developer command prompt with any other commands specified.
#ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&

# Default to PowerShell if no other command specified.
CMD ["powershell"]
