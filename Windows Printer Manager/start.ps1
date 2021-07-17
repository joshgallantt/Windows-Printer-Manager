PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""start.ps1""' -Verb RunAs}";

class Printer {
    [string]$id;
    [string]$name;
    [string]$location;
    [string]$address;
    [string]$driver;
    [string]$driverlocation;
    [bool] $installed = $false;

    [void] install(){
        Write-Output("The following GSHQ printers can be uninstalled on this device:`n")
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

    }

    [void] uninstall(){
        Foreach ($printer in  Get-Printer){
            if($printer.name -eq $this.name){
                Remove-Printer -Name $this.name
                Remove-PrinterPort -Name $this.name
                $this.installed = $false
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
        $selection = Read-Host "(1) install a printer`n(Q) quit`n`nSelect an Option"
        switch ($selection){
        '1' {install-menu "Install"} 
        'q' {exit}
        }
    }
    
    else{
        Write-Output("The following GSHQ printers are installed on this device:`n")
        Foreach ($printer in  $printerslist){
            if($printer.installed){
                Write-Output "$($printer.name), $($printer.location), $($printer.address), $($printer.driver)`n"
            }
            $selection = Read-Host "(1) install/reinstall a printer`n(2) uninstall a printer`n(Q) quit`n`nSelect an Option"
            switch ($selection){
                '1' {install-menu "Install"} 
                '2' {install-menu "Uninstall"} 
                'q' {exit}
            }
        }
    }
}

function printer-handler($printerobject, [string]$method){
    cls
    Write-Output("$($method)ing $($method.name) please wait... ")
        if($method -eq "Install"){
            $printerobject.Install()
        }

        else{
        $printerobject.Install()
        }
    main-menu
    Start-Sleep -s 3
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

function install-menu([string]$type){
    cls

    Write-Output(" ======================= PRINTER $($type.ToUpper()) =======================`n")

    Write-Output("The following GSHQ printers can be $($type)ed on this device:`n")

    if($type = "Uninstall"){
        Foreach ($printer in  $printerslist){
            if($printer.installed){
                $printer
            }
        }
    }

    else{
        $printerslist
    }

    $selection = Read-Host "`nEnter the ID of the printer you wish to $($type), (m) for main menu, or (q) to exit"
        switch ($selection){
            '1' {
                printer-handler $Printer1 $type
                }
            '2' {
                printer-handler $Printer2 $type
                }
            '3' {
                printer-handler $Printer3 $type
                }
            'm' {main-menu}
            'q' {exit}
        }
}

main-menu
