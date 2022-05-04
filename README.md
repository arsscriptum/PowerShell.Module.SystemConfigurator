# PowerShell.Module.SystemConfigurator
The SystemConfigurator Module is a powershell module providing all the functions required to setup a new Windows system

![SystemConfigurator](https://raw.githubusercontent.com/arsscriptum/PowerShell.Module.SystemConfigurator/master/img/sysconfig.png)

The script provide all the relevant functions to install required applications and setup the environment for a development machine.
User can call specific functions to install on a per-application basis or can use the automation process to do everything.

In short:
- Create the permanent directory structure
- Setup the PowerShell user profile
- Setup the PowerShell module development environment: builder and environment values
- Install my personalized PowerShell modules
- Install 3rd party PowerShell modules
- Install Git for Windows
- Install SublimeText
- Remove the Windows 10 Bloatware

## Why ?

I was getting tired of all the complicated steps required to do on a new system to get my tools and scripts to run.


## Parameters

1. ***Path***
    1. Path of the module to compile, is not specified, takind current path
1. ***ModuleIdentifier***
    1. Module Identifier, if not specified, the directory name is used 
1. ***Doumentation***
    1. FLAG: Build documentation 
1. ***Deploy***
    1. Deploy after build 
1. ***Debug***
    1. FLAG: For Debug purposes. Output the scripts with no compression 
1. ***Verbose***
    1. FLAG: For Debug purposes. Output LOTS of logs 


## How To Use

1. FIRSTLY, run ./
1. 
   

	

##EXAMPLE
```
    Runs without any parameters. Uses all the default values/settings
    >> ./Build.ps1
    -
```


## Tasks List
-------------

龱 Create the permanent directory structure

龱 Setup the PowerShell user profile

龱 Setup the PowerShell module development environment: builder and environment values

龱 Install my personalized PowerShell modules

龱 Install 3rd party PowerShell modules

龱 Install Git for Windows

龱 Install SublimeText

龱 Remove the Windows 10 Bloatware
