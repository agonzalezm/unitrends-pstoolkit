Chat Room
---------

Want to chat with other members of the Unitrends community?

[![Join the chat at https://gitter.im/Unitrends/unitrends-pstoolkit](https://badges.gitter.im/Unitrends/unitrends-pstoolkit.svg)](https://gitter.im/Unitrends/unitrends-pstoolkit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Engage, Contribute and Provide Feedback
---------------------------------------

Some of the best ways to contribute are to try things out, file bugs, and join in gitter conversations. You are encouraged to start a discussion by filing an issue. 

Looking for something to work on? The list of [issues](https://github.com/Unitrends/unitrends-pstoolkit/issues) is a great place to start.

Download and getting started
---------------------------------------

**WARNING: These community scripts are “as is” & are not officially supported by Unitrends.**

**Request new features or report bugs:**

1. Open github issue

**Download and install:**

1. Open Powershell as Administrator and allow execution of unsigned scripts by running command: Set-ExecutionPolicy Bypass
2. Run commmand: 
    PS> iwr https://raw.githubusercontent.com/Unitrends/unitrends-pstoolkit/master/Unitrends/Install.ps1 -UseBasicParsing | iex

**Usage:**

    PS> Import-Module Unitrends
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

