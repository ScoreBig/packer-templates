# More-or-less port of vm-guest-tools.bat to a non-disgusting language

# This should be checked periodically to make sure we're getting the latest version
$vmware_tools_location = 'http://s3-us-west-2.amazonaws.com/scorebig-provisioning/vmware-tools-windows-9.6.2.iso'

function Install-7Zip {
    if (Test-Path 'C:\Chocolatey') {
        Write-Host "Skipping chocolatey install"
    } else {
        Write-Host "Installing Chocolatey"
        $env:TEMP = 'C:\Windows\Temp'   #chocolatey install will fail without this
	    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
	}
    Write-Host "Installing 7-Zip"
	choco install 7zip
}

function Setup-LocalVBox {
	# VirtualBox image for local testing (Vagrant)

	Write-Host "Setting up local VirtualBox"
	
	Install-7Zip
	
	# There needs to be Oracle CA (Certificate Authority) certificates installed in order
	#to prevent user intervention popups which will undermine a silent installation.
	Write-Host "Installing Oracle certificate"
	cmd /c certutil -addstore -f "TrustedPublisher" A:\oracle-cert.cer

	mv "C:\Users\vagrant\VBoxGuestAdditions.iso" C:\Windows\Temp

    Write-Host "Decompressing ISO"
	& 'C:\Program Files\7-Zip\7z.exe' x C:\Windows\Temp\VBoxGuestAdditions.iso -oC:\Windows\Temp\virtualbox
	Write-Host "Installing VBox Additions"
	C:\Windows\Temp\virtualbox\VBoxWindowsAdditions.exe /S
	Start-Sleep -Seconds 30  #make sure install finishes
}

function Setup-LocalParallels {
	# Parallels image for local testing (Vagrant)

	Write-Host "Setting up local Parallels"

	Install-7Zip

    Write-Host "Decompressing ISO"
	& 'C:\Program Files\7-Zip\7z.exe' x C:\Users\vagrant\prl-tools.iso -oC:\Users\vagrant\prl-tools
	Write-Host "Installing Parallels Agent"
	C:\Users\vagrant\prl-tools\ptagent.exe
	Start-Sleep -Seconds 30  #make sure install finishes
}

function Setup-ESXi {
	
	Write-Host "Setting up ESXi"

	Install-7Zip

	Write-Host "Downloading VMware Tools"
	#download VMware installer
	$progressPreference = 'silentlyContinue'
	Invoke-WebRequest -OutFile 'C:\Users\vagrant\vmware-tools.iso' $vmware_tools_location
	
	#extract the iso and run the installer
	Write-Host "Decompressing ISO"
	& 'C:\Program Files\7-Zip\7z.exe' x 'C:\Users\vagrant\vmware-tools.iso' -oC:\Windows\Temp\vmware
	Write-Host "Installing VMware Tools"
	C:\Windows\Temp\vmware\setup.exe /S /v "/qn REBOOT=R\"
	Start-Sleep -Seconds 30  #make sure install finishes
}

function Setup-OpenStack {
	# Even though we're building on VirtualBox, the image will be converted for use with OpenStack

	Write-Host "Setting up OpenStack"

	Write-Host "Downloading cloudbase-init"
	$progressPreference = 'silentlyContinue'
	Invoke-WebRequest -OutFile 'C:\Users\vagrant\cloudbaseinit.msi' 'https://www.cloudbase.it/downloads/CloudbaseInitSetup_Beta.msi'

	Write-Host "Installing cloudbase-init"
	$p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/i C:\Users\vagrant\cloudbaseinit.msi /qn /l*v C:\Users\vagrant\cloudbaseinit-log.txt"
	if ($p.ExitCode -ne 0) {
	    Write-Host "ERROR: problem installing cloudbase-init!"
	}

	Write-Host "Running SetSetupComplete"
	& "$ENV:ProgramFiles (x86)\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"

    Write-Host "Preparing for sysprep"
    #we have to hack this so that sysprep will run (again?)
    Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\SysprepStatus" -Name GeneralizationState -Value 7
    msdtc -uninstall
    msdtc -install
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name SkipRearm -Value 1

    Write-Host "Running sysprep"
	$unattendedXmlPath = "$ENV:ProgramFiles (x86)\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
    $p = Start-Process -Wait -PassThru -FilePath "$env:SystemRoot\System32\Sysprep\sysprep.exe" -ArgumentList "/quiet /generalize /oobe /shutdown /unattend:`"$unattendedXmlPath`""
    if ($p.ExitCode -ne 0) {
        Write-Host "ERROR: problem running sysprep!"
    }
}

function Install-Features {
    Install-WindowsFeature NET-Framework-45-ASPNET
    Install-WindowsFeature NET-Framework-45-Core
    Install-WindowsFeature MSMQ
    Install-WindowsFeature Web-Server
    Install-WindowsFeature Web-Common-Http
    Install-WindowsFeature Web-Performance
    Install-WindowsFeature Web-Basic-Auth
    Install-WindowsFeature Web-Digest-Auth
    Install-WindowsFeature Web-Windows-Auth
    Install-WindowsFeature Web-Asp-Net45
    Install-WindowsFeature Web-Mgmt-Service
    Install-WindowsFeature Web-Scripting-Tools
}

function Setup-RemoteIIS-Mgmt {
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1
    Set-Service -name WMSVC -StartupType Automatic
    Start-Service WMSVC
}

Install-Features
Setup-RemoteIIS-Mgmt

switch ($env:PACKER_BUILD_NAME) {
	"sb_win2012r2sc_vbox" { Setup-LocalVBox }
	"sb_win2012r2sc_parallels" { Setup-LocalParallels }
	default { Write-Host -ForegroundColor Red "Unknown Packer builder!" }
}




