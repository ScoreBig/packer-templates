Windows 2012 R2 Datacenter Edition x64 Server Core


Machine Specific
----------------

Box size around 4 GB <br/>
Configured as 2 CPU and 1 GB memory by default <br/>

Based on [OpenTable packer templates](https://github.com/opentable/packer-images).

This box is activated with our Bizspark keys. Therefore it cannot be distributed outside of ScoreBig.

Software Pre-installed
----------------------
The following software is installed and pre-configured:

* Openssh (via Cygwin)
* Git (via Cygwin)
* Curl and Wget (via Cygwin)
* Guest Additions (provider specific)

Preconfigured
-------------
The following configuration is set:

* WinRM configured for vagrant-windows plugin
* Local Administrator account enabled
* Powershell is installed with Remote Execution policy is set unrestricted

Features
--------

* IIS
* Related IIS features (basic/digest auth, compression, redirection, etc)
* IIS remote management
* ASP.NET 4.5
* MSMQ
