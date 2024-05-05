SET ASPNETCORE_ENVIRONMENT=Development
SET ASPNETCORE_HOSTINGSTARTUPASSEMBLIES=Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation
SET LAUNCHER_PATH=bin\Debug\net8.0\WebHome.exe
rem "c:\Program Files\IIS Express\iisexpress.exe" /site:WebHome /config:C:\Project\Github\beyond-fitness\WebHome\.vs\WebHome\config\applicationhost.config /apppool:"WebHome AppPool"
robocopy ..\WebDev\bin\Debug\net8.0 bin\Debug\net8.0 /S
Start "WebHome" bin\Debug\net8.0\WebHome.exe --urls="http://*:5000"