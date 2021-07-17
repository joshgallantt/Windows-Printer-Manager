PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""start.ps1""' -Verb RunAs}";
$Title = "Printer Manager by Josh"
$host.UI.RawUI.WindowTitle = $Title

<# ADD NEW PRINTERS HERE (If you're unsure where to get installed printer driver files, "C:\Windows\System32\DriverStore\FileRepository) #>

$Printer1 = [Printer]::new();
$Printer1.id = "1"
$Printer1.name = "Example Printer 1"
$Printer1.location = "Third Floor Office"
$Printer1.address = "203.0.113.12"
$Printer1.driver = "HP Color LaserJet Pro M252 PCL 6"
$Printer1.driverlocation = "C:\Users\$env:userprofile\Desktop\Windows Printer Manager\Drivers\Printer 1\hpor3c2a_x64.inf"

$Printer2 = [Printer]::new();
$Printer2.id = "2"
$Printer2.name = "Example Printer 2"
$Printer2.location = "Fourth Floor Office"
$Printer2.address = "203.0.113.11"
$Printer2.driver = "HP Color LaserJet Pro M252 PCL 6"
$Printer2.driverlocation = "C:\Users\$env:userprofile\Desktop\Windows Printer Manager\Drivers\Printer 1\hpor3c2a_x64.inf"

$Printer3 = [Printer]::new();
$Printer3.id = "3"
$Printer3.name = "Example Printer 3"
$Printer3.location = "Fifth Floor Office"
$Printer3.address =  "203.0.113.13"
$Printer3.driver = "YOU FIND THIS IN THE .INF FILE"
$Printer3.driverlocation = "U:\Drivers\Printer3_Driver\Epson.inf"

<# MAKE SURE YOU ADD THEM TO THE LIST #>

$printerslist = $Printer1, $Printer2, $Printer3

<# AND TO THE SELECTION CHOICES #>

function printer-choices{
    $selection = Read-Host
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

<# No need to go paseed here! :D #>


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

    Foreach ($installedprinter in  Get-Printer){
        Foreach ($printer in $printerslist){
            if($printer.Name -eq $installedprinter.Name){
                $printer.installed = $true
                $installed = $true
            }
        }
    }

    Write-Output(" ======================= PRINTER MANAGER =======================`n")

    if(!$installed){
        Write-Host("There are currently no GSHQ printers installed on this device.`n") -ForegroundColor "Red"
        Write-Host "Select an option:"
        Write-Host "  (1) Add a printer" -ForegroundColor "Yellow"
        Write-Host "  (Q) To Quit" -ForegroundColor "Yellow"
        $selection = Read-Host
        switch ($selection){
        '1' {install-menu "install"} 
        'q' {exit}
        }
    }
    
    else{
        Write-Output("The following GSHQ printers are installed on this device:`n")
        Foreach ($printer in $printerslist){
            if($printer.installed){
                Write-Host("  $($printer.name), $($printer.location), $($printer.address), $($printer.driver)`n") -ForegroundColor "Green"
            
            }
        }

        Write-Host "Select an option:"
        Write-Host "  (1) Add a printer" -ForegroundColor "Yellow"
        Write-Host "  (2) Remove a printer" -ForegroundColor "Yellow"
        Write-Host "  (Q) To Quit" -ForegroundColor "Yellow"
        $selection = Read-Host
        switch ($selection){
            '1' {install-menu "install"} 
            '2' {install-menu "uninstall"} 
            'q' {exit}
        }
    }
}

function printer-handler($printerobject, [string]$method){
    cls

    Write-Host("  $($method)ing $($printerobject.name) please wait... this can a few minutes") -ForegroundColor "Red"
        if($method -eq "Install"){
            $printerobject.Install()
        }

        else{
            $printerobject.Uninstall()
        }
        
    cls
    Write-Host("`n   $($printerobject.name) $($method)ed!") -ForegroundColor "Green"
    Start-Sleep -s 1
    Write-Host("   Returning to Main Menu...")
    Start-Sleep -s 1
    main-menu
}

function install-menu([string]$type){
    cls

    Write-Output(" ======================= PRINTER $($type.ToUpper()) =======================`n")

    Write-Output("The following GSHQ printers can be $($type)ed on this device:`n")

    if($type -eq "uninstall"){
        Foreach ($printer in  $printerslist){
            if($printer.installed){
                Write-Host("  ($($printer.id))") -NoNewLine -ForegroundColor "Yellow"
                Write-Host("  $($printer.name), $($printer.location), $($printer.address), $($printer.driver)`n") -ForegroundColor "Red"
            }
        }
    }

    else{
        Foreach ($printer in  $printerslist){
            if(!$printer.installed){
                Write-Host("  ($($printer.id))") -NoNewLine -ForegroundColor "Yellow"
                Write-Host("  $($printer.name), $($printer.location), $($printer.address), $($printer.driver)`n") -ForegroundColor "Green"
            }
        }
    }
    Write-Host "Select an option:"
    Write-Host "  (num) the printer you wish to $($type)" -ForegroundColor "Yellow"
    Write-Host "  (M) for main menu" -ForegroundColor "Yellow"
    Write-Host "  (Q) to exit" -ForegroundColor "Yellow"
    printer-choices
}

main-menu
