Windows Server Packer Images
----------------------------

These are public version of the Packer templates we use to build Windows Server images for Vagrant, OpenStack, etc.

They are based on the templates provided by [OpenTable](https://github.com/opentable/packer-images/).
 
They include a trial license key and are therefore only valid for 30 days. You must replace the key in Autounattend.xml 
with a valid permanent key to use the generated OS images beyond 30 days.

The images produced are Server Core (no GUI shell) unless otherwise specified.

Usage
-----

Assuming you have [Packer](http://packer.io) installed, issue the following command in the template directory:

```
$ packer build ./windows_2012_r2.json
```

You must put a valid installer iso (eg, from MSDN) in the "iso" subdirectory. Make sure it is referenced properly in the respective JSON
file.


Installed Software (on generated OS image)
------------------------------------------

* Cygwin
* OpenSSH server (listening on 22)
* Chocolatey
* 7-Zip
* Hypervisor tools (VBox Additions/Parallels Tools)
* Features: IIS, ASP.NET, MSMQ, IIS Remote Management