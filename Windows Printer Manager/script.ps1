PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""script.ps1""' -Verb RunAs}";

class Printer {
    [string]$id;
    [string]$name;
    [string]$location;
    [string]$address;
    [string]$driver;
    [string]$driverlocation;
    [bool] $installed = $false;

    [void] install(){

        Foreach ($printer in  Get-Printer){
            if($printer.name -eq $this.name){
                Remove-Printer -Name $this.name
                Remove-PrinterPort -Name $this.name
            }
        }
        pnputil.exe /add-driver $this.driverlocation /install
        Write-Output $this.driverlocation
        Add-PrinterDriver -Name $this.driver
        Add-PrinterPort -Name $this.name -PrinterHostAddress $this.address
        Get-PrinterDriver
        Add-Printer -DriverName $this.driver -Name $this.name -PortName $this.name -Location $this.location
        $this.installed = $true
        Start-Sleep -s 3
    }

    [void] uninstall(){
        Foreach ($printer in  Get-Printer){
            if($printer.name -eq $this.name){
                Remove-Printer -Name $this.name
                Remove-PrinterPort -Name $this.name
                $this.installed = $false
                Start-Sleep -s 3
            }
        }
    }
}

function main-menu{
    cls
    $someinstalled = $false
    Foreach ($installedprinter in  Get-Printer){
        Foreach ($printer in  $printerslist){
            if($printer.Name -eq $installedprinter.Name){
                $printer.installed = $true
                $someinstalled = $true
            }
        }
    }

    Write-Output(" ======================= PRINTER MANAGER =======================`n")

    if(!$someinstalled){
        Write-Output("There are currently no GSHQ printers installed on this device.`n")
        $selection = Read-Host "1. install a printer`n2. quit`n`nSelect an Option"
        switch ($selection){
        '1' {install-menu} 
        'q' {exit}
        }
    }
    
    else{
        Write-Output("The following Gymshark printers are installed on this device:`n")
        Foreach ($printer in  $printerslist){
            if($printer.installed){
                Write-Output "$($printer.name), $($printer.location), $($printer.address), $($printer.driver)`n"
            }
            $selection = Read-Host "1. install/reinstall a printer`n2. uninstall a printer`n3. quit`n`nSelect an Option"
            switch ($selection){
                '1' {install-menu} 
                '2' {uninstall-menu} 
                'q' {exit}
            }
        }
    }
}

<#

No need to edit anything above.

Below is where you add new printer objects to the $printerslist array (make sure you also add any new printers in the install/uninstall function)

If you're unsure where to get installed printer driver files, "C:\Windows\System32\DriverStore\FileRepository"

#>


$Printer1 = [Printer]::new();
$Printer1.id = "1"
$Printer1.name = "Example Printer 1"
$Printer1.location = "Third Floor Office"
$Printer1.address = " 203.0.113.11"
$Printer1.driver = "HP Color LaserJet Pro M252 PCL 6"
$Printer1.driverlocation = "C:\Users\$env:userprofile\Desktop\Windows Printer Manager\Drivers\Printer 1\hpor3c2a_x64.inf"

$Printer2 = [Printer]::new();
$Printer2.id = "2"
$Printer2.name = "Example Printer 2"
$Printer2.location = "Fourth Floor Office"
$Printer2.address = "203.0.113.11"
$Printer2.driver = "YOU FIND THIS IN THE .INF FILE"
$Printer2.driverlocation = "U:\Drivers\Printer2_Driver\HP.inf"

$Printer3 = [Printer]::new();
$Printer3.id = "3"
$Printer3.name = "Example Printer 3"
$Printer3.location = "Fifth Floor Office"
$Printer3.address =  "203.0.113.11"
$Printer3.driver = "YOU FIND THIS IN THE .INF FILE"
$Printer3.driverlocation = "U:\Drivers\Printer3_Driver\Epson.inf"

$printerslist = $Printer1, $Printer2, $Printer3


$Title = "Printer Manager by Josh"
$host.UI.RawUI.WindowTitle = $Title

function install-menu{
    cls
    
    Write-Output(" ======================= PRINTER INSTALL =======================`n")

    Write-Output("The following GSHQ printers can be installed on this device:`n")
    $printerslist

    $selection = Read-Host "`nEnter the ID of the printer you wish to install/reinstall, (m) for main menu, or (q) to exit"
        switch ($selection){
            '1' {
                $Printer1.install()
                main-menu
                }
            '2' {
                $Printer2.install()
                main-menu
                }
            '3' {
                $Printer3.install()
                main-menu
                }
            'm' {main-menu}
            'q' {exit}
        }
}

function uninstall-menu{
    cls

    Write-Output(" ====================== PRINTER UNINSTALL =====================`n")

    Write-Output("The following GSHQ printers can be uninstalled on this device:`n")

    Foreach ($printer in  $printerslist){
        if($printer.installed){
            $printer
        }
    $selection = Read-Host "`nEnter the ID of the printer you wish to uninstall, (m) for main menu, or (q) to exit"
        switch ($selection){
            '1' {
                $Printer1.uninstall()
                main-menu
                }
            '2' {
                $Printer2.uninstall()
                main-menu
                }
            '3' {
                $Printer3.uninstall()
                main-menu
                }
            'm' {main-menu}
            'q' {exit}
        }
    }
}

main-menu
