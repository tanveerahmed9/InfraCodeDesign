

#Region Method defination
function EmptyRecyclebin{
    Get-ChildItem -Path 'C:\$Recycle.Bin' -Force | Remove-Item -Recurse -ErrorAction SilentlyContinue

}

function write-log{
    # Parameter help description
    param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]
    $filename,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]
    $content
    )

   "$content `r" | Out-File -FilePath $filename -Append

}

function DeleteWithErrorLogs {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $fileToDelete
    )

    try{
        remove-item -Path $fileToDelete -Force -Confirm:$false
    }

    catch{
        if (!(Test-Path $slogroot/archivelogs.error.flag))
        {
        New-Item -ItemType File -Path "$slogroot/archivelogs.error.flag" }
    }

}

function formattedDateTime{
    $cDate = get-date -Format "dd-mm-yy hh:mm:ss"
    return $cDate
}

function MoveWindowsArchivedEventLogs {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $destination
    )
    $WinArchiveDir = "$env:SystemRoot\system32\winevt\logs\"
    $content  = formattedDateTime + "Checking for archived logs in $WinArchiveDir"
    Write-Log -filename $oLogFileName -content $content
    $FilenamePrefix = "Archive_"
    $archivedFiles = Get-ChildItem -Path $WinArchiveDir | Select-Object Name


    # iterating againts each files and checking whether the file contaings Archive_ keyword.
    foreach ($fname in $archivedFiles)
    {

      $archiveCheck = $fname.Substring(0,$FilenamePrefix.Length)
      $evtsCheck = $fname.Substring($fname.Length-4)
      $evtCheck = $fname.Substring($fname.Length-3)
      # checking against the Archive keyword and extension
       if ($archiveCheck.toupper() -eq $FilenamePrefix.ToUpper() -and ($evtsCheck.ToUpper() -eq "EVTX" -or $evtCheck.ToUpper() -eq "EVT"))
       {
          $content = formattedDateTime + "Moving $fnamae to $destination"
          Write-Log -filename $oLogFileName -content $content
          try {
              $Error.Clear() # clearing the previous error stack
              Move-Item -Path $fname -Destination $destination -ErrorAction Stop
          }
          catch {
            $errorID = $Error.FullyQualifiedErrorId
            $exception = $Error.exception
            $content = "Error ID:$errorID Exception:$exception"
            Write-Log -filename $oLogFileName -content $content
          }
       }

    }

}
function ArchiveEventlogs{

    Param(
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [String]
        $sLogName
    )
    begin{
        $content = formattedDateTime + "Checking for $slogname EventLog"
        Write-Log -filename $oLogFileName -content $content
        $log = Get-WmiObject Win32_NTEventlogFile | Where-Object LogfileName -EQ $sLogname
    }

    process{
        $appFileName = "$sEvtLogName" + "$sLogName.evt"
        $content = formattedDateTime + "Archiving $slogname EventLog"
        try{
            $Error.Clear()
            $backupLocation = $sEvtLogRoot + "\$appFileName"
            $log.BackupEventlog($backupLocation)
        }
        catch{
            $content = formattedDateTime + "ERROR: Unable to backup the $sLogname log file"
        }
        finally{
            if (!($Error)) # when there was no error during backing up the event log
            {
                $content = formattedDateTime
                $content += " EventLogs Archived "
                Write-Log -filename $oLogFileName -content $content
                $content = formattedDateTime
                $content += "Clearing event log $slogname"
                Write-Log -filename $oLogFileName -content $content
                $log.ClearEventlog()
                $log.clea
            }
        }
    }

    end{

    }
}

function Archive {

    param(
    [Parameter(Mandatory=$true)]
    [string]
    $folderName
    )

    begin{
        $sZipFileName = $folder + $szipdatename + ".Zip"
        $objFiles = get-childitem -Path $folderName
    }

    process{
        foreach ($objLogFileName in $objFiles)
        {
            $updateDate = (Get-Item $objLogFileName).LastAccessTime
            $currentDate = Get-Date
            $diff = $currentDate - $updateDate
            $diffDays = $diff.totalDays

            if ($objLogFileName.Substring($objLogFileName.Length-3).toupper -eq "ZIP") # if it is a zipped file
            {
                # evaluating the difference in current date vs Last Access Date of the file

                if ($diffDays -ge $Global:Iretention)
                {
                    $content = formattedDateTime
                    $content += "Deleting Archive $sZipFileName as it is older than the retention period"
                    write-log -filename $oLogFileName -content $content
                    DeleteWithErrorLogs $objLogFileName
                    $content = formattedDateTime
                    $content += "Deleted Archive $sZipFileName"

                }
            }

            else # if it is not a Zip file we will add it to the archive
            {
                if ($diffDays -gt 0)
                {
                    $content = formattedDateTime
                    $content += "Adding $objLogFileName to the archive $sZipFileName"
                    write-log -filename $oLogFileName -content $content
                    Compress-Archive -Path $objLogFileName -DestinationPath $sZipFileName  #run the winzip command here Check with jitendra
                    DeleteWithErrorLogs $objLogFileName
                }
            }



            else{


            }
        }
    }

    end{

    }

}

#region controller section

# fetching date and time details
$sDay = (get-date).AddDays(-1).Day
$sMonth = (get-date).AddDays(-1).Month
$sMonthName = (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($sMonth)
$sYear = (get-date).AddDays(-1).Year
$sHour = (get-date).Hour
$sMinute = (get-date).Minute

# formatting the hour minute hour and month

If ($sMonth.Length -eq 1){
	$sMonth = "0" + "$sMonth"
}

If ($sDay.Length -eq 1){
	$sDay = "0" + "$sDay"
}

If ($sHour.Length -eq 1){
    $sHour += "0" + "$sHour"
}

If ($sHour.Length -eq 0){
    $sHour = "00"
}

If ($sMinute.Length -eq 1) {
	$sMinute = "0" + "$sMinute"
}

If ($sMinute.Length -eq 0) {
	$sMinute = "00"
}

# creating slogRoot
$rootFlag = 0
if (test-path "D:\LogFiles"){
    $sLogRoot = "D:\LogFiles\"
    $rootFlag = 1
}
if (Test-Path "C:\LogFiles"){
    $sLogRoot = "C:\LogFiles"
    $rootFlag = 1
}

if ($rootFlag -eq 0)
{
    "Achive log for non availabilty of log path"  # to be checked with Zak
    exit
}

$oLogFileName = $sLogRoot + "ArchiveLogs.txt"
$content = formattedDateTime
$content += "Log path found in $slogroot"
write-log -filename $oLogFileName -content $content
$Global:Iretention = 6

$content = formattedDateTime
$content += " Checking for Checking for Winzip CLI directory"
$Winzipflag = 0
if (Test-Path -Path "C:\Program Files (x86)\WinZip\wzzip.exe")
{
    $WinZipCmd = """C:\Program Files (x86)\WinZip\wzzip.exe"""
    $Winzipflag = 1
}

if (Test-Path -Path "C:\Program Files\WinZip\wzzip.exe")
{
    $WinZipCmd = """C:\Program Files\WinZip\wzzip.exe"""
    $Winzipflag = 1
}

if (Test-Path -Path "D:\Program Files (x86)\WinZip\wzzip.exe")
{
    $WinZipCmd = """D:\Program Files (x86)\WinZip\wzzip.exe"""
    $Winzipflag = 1
}

if (Test-Path -Path "D:\Program Files\WinZip\wzzip.exe")
{
    $WinZipCmd = """D:\Program Files\WinZip\wzzip.exe"""
    $Winzipflag = 1
}

if ($Winzipflag -eq 0) # wZ directory not found
{
$content = formattedDateTime
$content += " Error: No Winzip CLI directory found`r`r"
exit
}

else {
    $content = formattedDateTime
    $content += " Winzip CLI directory found in  $WinZipCmd"
    write-log -filename $oLogFileName -content $content
    $sRunFlagFile = "$sLogRoot"+ "archivelogs.run.flag"


    try{
        $content = formattedDateTime
        $content += " Deleteing flags $sRunFlagFile"
        Remove-Item -Path $sRunFlagFile -Force -ErrorAction Stop
        $content = formattedDateTime
        $content += " Deleting flags:  $sLogRoot" + "archivelogs.error.flag"
        write-log -filename $oLogFileName -content $content
        $flags = "sLogRoot" + "archivelogs.error.flag"
        Remove-Item -Path $flags -Force -ErrorAction Stop
    }

    catch{

    }
}
$sYear = $sYear.ToString()
$sZipDateName = $sYear.Substring($sYear.Length -2) + $sMonth + "_" + $sMonthName
$sEvtLogRoot = $sLogRoot + "EventLogs\"

ArchiveEventLogs "Application"
ArchiveEventLogs "Security"
ArchiveEventLogs "System"
ArchiveEventLogs "IRL2"
ArchiveEventLogs "IRL3"

MoveWindowsArchivedEventLogs $sEvtLogRoot

# getting sub-folders of slogroot
$objFolderNames = Get-ChildItem -Path $slogRoot | Where-Object {$_.PSIsContainer} | Select-Object Name

foreach ($objFolderName in $objFolderNames){
  Archive $objFolderName
}

$content = formattedDateTime
$content += " Archiving complete"
write-log -filename $oLogFileName -content $content
EmptyRecyclebin
$content = formattedDateTime
$content += " Creating flags: $sRunFlagFile `r`r`r"
write-log -filename $oLogFileName -content $content
New-Item -Path $sRunFlagFile


#endregion


#endRegion