Chat Room
---------

Want to chat with other members of the Unitrends community?

[![Join the chat at https://gitter.im/dotnet/coreclr](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Unitrends/unitrends-pstoolkit)

Engage, Contribute and Provide Feedback
---------------------------------------

Some of the best ways to contribute are to try things out, file bugs, and join in gitter conversations. You are encouraged to start a discussion by filing an issue. 

Looking for something to work on? The list of [issues](https://github.com/Unitrends/unitrends-pstoolkit/issues) is a great place to start.

Download and getting started
---------------------------------------

[![Join the chat at https://gitter.im/Unitrends/unitrends-pstoolkit](https://badges.gitter.im/Unitrends/unitrends-pstoolkit.svg)](https://gitter.im/Unitrends/unitrends-pstoolkit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**WARNING: These community scripts are “as is” & are not officially supported by Unitrends.**

**Request new features or report bugs:**

1. Open github issue

**Download and install:**

1. Download last version from <a href="https://github.com/unitrends/unitrends-pstoolkit/archive/master.zip"> here</a>
2. Unzip to a folder
3. Open Powershell as Administrator and allow execution of unsigned scripts by running command: Set-ExecutionPolicy Bypass
4. Cd to unzipped folder and run .\Init.ps1 to load module

**Usage:**



    PS E:\unitrends-pstoolkit-master\unitrends-pstoolkit> .\Init.ps1
      [*] Welcome to Unitrends Powershell Toolkit! ---------------------------------------------------------
      
    Sample usage:
    

            Connect-UebServer -Server ueb01 -User root -Password yourpass
            Get-UebJob
            Get-UebJob -Active
            Get-UebJob -Recent
            Get-UebJob -Active|Stop-UebJob
            Get-UebJob -Active|Stop-UebJob
            Get-UebJob -Name job1*|Start-UebJob
            Get-UebAlert
            Get-UebVirtualClient


    Copyright (C) Unitrends,Inc. All rights reserved.

