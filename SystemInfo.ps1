function writeParameter([string] $name, [string] $value)
{
    $y = [console]::cursorTop
    [console]::setcursorposition(0, $y+1)
    Write-Host -Object "$name :" -foreground 'Cyan'
    [console]::setcursorposition(35, $y+1)
    Write-Host -Object $value -NoNewLine -foreground 'Yellow' 
}

function title([string] $title)
{
    [console]::ForeGroundColor = 'Gray'
    Write-Host -Object "`n`n*******************************************************************************`n" 
    [console]::setcursorposition(28, [console]::cursorTop-2)
    Write-Host -Object $title -NoNewLine
}

function clearLine()
{
    for($i=1; $i -le 4; $i++)
    {
        Write-Host -Object '           ' -NoNewLine -background 'Black'
    }
}

function PrintLineState([double] $value)
{
    $y = [console]::cursorTop
    [console]::setcursorposition(35, $y)
    clearLine
    [console]::setcursorposition(35, $y)
    $valuePercent = '{0:P0}' -f $value
    Write-Host -Object $valuePercent -NoNewLine -foreground 'Blue'
    [console]::setcursorposition(38, $y)
    for($i=1; $i -le ($value*100 / 5); $i++)
    {
        Write-Host -Object ' |' -NoNewLine -background 'Blue' -foreground 'Black'
    }
}

[console]::BackGroundColor = 'Black'
$processor = gwmi Win32_processor | Select Name, AddressWidth, DataWidth, L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed, NumberOfCores, NumberOfLogicalProcessors
$os = gwmi Win32_OperatingSystem | Select OSArchitecture, Version, Caption, OSType, BuildType, BuildNumber, BootDevice, FreePhysicalMemory, TotalVisibleMemorySize
title("Операционная система")
writeParameter 'Операционная система' $os.Caption
writeParameter 'Версия' $os.Version
writeParameter 'Номер сборки' $os.BuildNumber
writeParameter 'Тип сборки' $os.BuildType
writeParameter 'Boot Device' $os.BootDevice
writeParameter 'Разрядность' $os.OSArchitecture
writeParameter 'Тип' $os.OSType
writeParameter 'Свободная физическая память' $os.FreePhysicalMemory
writeParameter 'Ram' $os.TotalVisibleMemorySize
title("Процессор")
writeParameter 'Процессор' $processor.Name
writeParameter 'Ширина шины адреса' $processor.AddressWidth
writeParameter 'Ширина шины данных' $processor.DataWidth 
writeParameter 'Кэш L2 размер' $processor.L2CacheSize
writeParameter 'Кэш L2 скорость' $processor.L2CacheSpeed
writeParameter 'Кэш L3 размер' $processor.L3CacheSize
writeParameter 'Кэш L3 скорость' $processor.L3CacheSpeed
writeParameter 'Количество ядер' $processor.NumberOfCores
writeParameter 'Количество логических процессоров' $processor.NumberOfCores
writeParameter 'cpu' (gwmi Win32_Processor).StatusInfo
title("BIOS")
$bios = gwmi win32_bios
writeParameter 'BIOS' $bios.Name
writeParameter 'Версия BIOS' $bios.Version
writeParameter 'Версия SMBIOS' $bios.SMBiosBiosVersion 

title("Видеоадаптеры")
$vgas= gwmi win32_VideoController
foreach($vga in $vgas)
{
    writeParameter 'Производитель' $vga.AdapterCompatibility
    writeParameter 'Наименование' $vga.Name
    writeParameter 'RAM' ($vga.AdapterRam/(1024*1024))
}
title("HDD")
$hdd = gwmi win32_DiskDrive
writeParameter 'Модель' $hdd.Model
writeParameter 'Объем' $hdd.Size
 
title("Быстродействие") 
[console]::CursorVisible=$false    

writeParameter "Используемая память" ' '
writeParameter "Загрузка CPU" 
while(1 -le 2)
{
    $usedMemory = 1 - (gwmi Win32_OperatingSystem).FreePhysicalMemory/(gwmi Win32_OperatingSystem).TotalVisibleMemorySize
    $processorTime = Get-Counter -Counter "\Процессор(_total)\% загруженности процессора" | Select-Object –ExpandProperty CounterSamples | Select-Object CookedValue
    $y = [console]::cursorTop
    [console]::setcursorposition(35, $y-1)
    PrintLineState($usedMemory)
    [console]::setcursorposition(35, $y)
    $cpu = $processorTime.CookedValue/100
    PrintLineState($cpu)
    
    #Start-sleep -s 1
}


"`n"
