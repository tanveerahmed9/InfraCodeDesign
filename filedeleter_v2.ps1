
#region Method Implementation
$fileskipped = 0
$script:filesdeleted = 0
$script:foldersDeleted = 0
$script:bytesDelted = 0
$Script:xmltags = "Path,Extensions,RetainDays,Recurse,RemoveEmptyFolders,ExcludeLocations,ExcludeExtensions,UseCreateDate"
function DeleteFilesByAgeAndExtension($pFolder, $pExtensions, $pRetainDays, $pRecurse, $pDeleteFolders, $pExcludeFolders, $pExcludeExtensions, $pUseFileCreationDate)
{

    # checking if exclude folder is in path of main folder
    if ($pExcludeFolders)
    {
        $pExcludeFoldersarr = $pExcludeFolders -split ","
        foreach ($excludeFolder in $pExcludeFoldersarr)
        {
            $slashCheck = $excludeFolder.Substring($excludeFolder.Length -1 )
            if ($slashCheck -eq "/" -or $slashCheck -eq "\") #check if slash is der at excluded folder
            {
                $excludeFolder = $excludeFolder.Substring(0,$excludeFolder.Length - 1)
            }
             # check if excluded folder is same as the main folders
            if ($local:pFolder -like "$excludeFolder*")
            {
                Write-log -filePath $logFileLocation -content "Excluded: not traversing folder $pFolder"
                return
            }
        }


    }



    $itemFiles = get-childitem -Path $local:pFolder |Where-Object { ! $_.PSIsContainer } | Select-Object -ExpandProperty Fullname
    ForEach ($itemFile in $itemFiles )
    {

        if ($debugMode)
            {
                Write-Log -filePath $logFileLocation -content " Checking file  $itemFile"
            }

        $deleteflag = $false
        if ($pExtensions -eq "*.*" -or $pExtensions -eq "" )
            {
            $deleteFlag = $True
            }

        else
            {
                $pextensions = $pExtensions -split ","
                foreach ($itemExtension in $pextensions)
                {
                    # if any of the extension matches the file extension

                    if ($itemFile.Substring($itemFile.Length - $itemExtension.Length -1) -eq ".$itemExtension")
                    {
                    $deleteflag = $true
                    break;
                    }
                }

                    if ($debugMode)
                    {
                        Write-log -filePath $logFileLocation -content  "File matches extension inclusion: $deleteFlag"
                    }

            }
            # if any of the excluded extension matches the file extension
        $pExcludeExtensions = $local:pExcludeExtensions -split ","
        foreach ($pExcludeExtension in $pExcludeExtensions)
            {
                if ($itemFile.Substring($itemFile.Length - $pExcludeExtension.Length -1) -eq ".$pExcludeExtension")
                    {
                        $deleteflag = $false
                        Write-Log -filePath $logFileLocation -content " Not deleting file, matches   $pExcludeExtension   -  $itemFile "
                    }
            }

            # if delete flag is set to ON we check fro datediff
        if ($deleteflag)
            {
                 if ($pUseFileCreationDate -eq "True") # if file creation date specified for identifying the Retention policy
                    {
                        $creationDate = (get-item $itemFile).CreationTime
                        $currentDate = get-date
                        $dateDiff = $currentDate - $creationDate
                        [int]$pRetainInt = [convert]::ToInt32($pRetainDays, 10)
                    }
                    else
                    { # last modified date will be taken for identifying the Retention policy
                        $creationDate = (get-item $itemFile).LastWriteTime
                        $currentDate = get-date
                        $dateDiff = ($currentDate - $creationDate).Days
                        [int]$pRetainInt = [convert]::ToInt32($pRetainDays)
                    }
                    if ($dateDiff -ge $pRetainInt)
                    {

                        $noofDays = $dateDiff
                        Write-Log -filePath $logFileLocation -content " Deleting file  $itemFile :  $noofDays  days old"
                        $script:FilesDeleted += 1
                        $script:bytesDelted += ((get-item $itemFile).Length/1kb)*1000

                       if (!($testMode)) # if test mode is not ON file will be deleted
                        {
                           Remove-Item -Path $itemFile -Force # remove comment post go live
                        }
                    }
            }

    }

    # creating a hashtable to return size and no of Files

}


function Write-Log($filePath,$content)
{
 "$content `r"| Out-File -FilePath $filePath -Append
}

function GetFormattedDate()
{
  return get-date -Format "yymmdd_hhmm"
}

function ReadConfigXML()
{
    $global:ReadConfigXML = $False # default value (sentinel value for XML validation)
    $scriptpath = get-location | Select-Object -ExpandProperty Path
    $configFile = resolve-path("$scriptpath\FileDeleter_config.xml")
    $xmlObj = [xml]::new()

    try {
        $xmlObj.Load($configFile) #XML Structure validation
    }
    catch {
        Write-Log -filePath $logFileLocation "Failed to load config  $configFile check it exists and is well formed!"
        return
    }

    [xml]$XMLContent =get-content "$scriptpath\FileDeleter_config.xml"

    $global:locations = $XMLContent.GetElementsByTagName("Location")

    if (!($locations)) # no location items present
    {
        Write-Log -filePath $logFileLocation "Error: Locations node not found in config file"
        return
    }

    else {

        $locCount = 0;
        foreach ($location in $locations)
        {
            $locCount += 1
            $checkFlag = 0
            $xmltagCheck = ""
            $checkFlagCorrect = ([System.Math]::Pow(2,$TOTALCONFIGITEMS) - 1)
            if ($location.Path)
            {
                $path = $location.Path
                Write-Log -filePath $logFileLocation -content "  Path: $path"
                $checkFlag = $checkFlag + 1
                $xmltagCheck += "Path "
            }

            if ($location.Extensions)
            {
                $ext = $location.Extensions
                Write-Log -filePath $logFileLocation -content  "Extensions: $ext"
                $checkFlag = $checkFlag + 2
                $xmltagCheck += "Extensions "
            }

            if ($location.Recurse)
            {
                $recurse = $location.Recurse
                Write-Log -filePath $logFileLocation -content "  Recurse: $recurse"
                $checkFlag = $checkFlag + 4
                $xmltagCheck += "Recurse "
            }

            if ($location.RetainDays)
            {
                $rDays =  $location.RetainDays
                write-log -filePath $logFileLocation -content "RetainDays: $rDays "
                $checkFlag = $checkFlag + 8
                $xmltagCheck += "RetainDays "
            }

            if ($location.RemoveEmptyFolders)
            {
                $reFolders = $location.RemoveEmptyFolders
                Write-Log -filePath $logFileLocation -content "  RemoveEmptyFolders: $reFolders"
                $checkFlag = $checkFlag + 16
                $xmltagCheck += "RemoveEmptyFolders "
            }

            if ($location.ExcludeLocations)
            {
                $eLocations = $location.ExcludeLocations
                Write-log -filePath $logFileLocation -content "  ExcludeLocations: $eLocations"
                $checkFlag = $checkFlag + 32
                $xmltagCheck += "ExcludeLocations "
            }

            if ($location.UseCreateDate)
            {
                $usedate = $location.UseCreateDate
                write-log -filePath $logFileLocation -content   "UseCreateDate: $usedate"
                $checkFlag = $checkFlag + 64
                $xmltagCheck += "UseCreateDate "
            }

            if ($locations.ExcludeExtensions)
            {
                $exExtn = $location.ExcludeExtensions
                write-log -filePath $logFileLocation -content   "Exclude Extension: $exExtn"
                $checkFlag = $checkFlag + 128
                $xmltagCheck += "ExcludeExtensions "
            }
            #split and remove empty elements from xmltagcheck
            $xmltagcheck = $xmltagCheck.Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries)
            $Script:xmltags = $Script:xmltags.Split(',',[System.StringSplitOptions]::RemoveEmptyEntries)
            # compare the XMl tag object with the current object
            $diffObj = Compare-Object -ReferenceObject $Script:xmltags -DifferenceObject $xmltagCheck -PassThru

            #if there is any difference in the object the user is notified about the same
            if ($diffObj)
            {
                Write-Log -filePath $logFileLocation -content   "At location $loccount Following tag(s) $diffobj not specified"
                exit
            }
        }
      # fetch the testMode tag
      $global:testMode = $XMLContent.GetElementsByTagName("TestMode") | Select-Object -ExpandProperty '#text'
      if ($testMode -eq "False")
      {
          $global:testMode = $False
      }
      else {
        $global:testMode = $True
      }


      # fetch debug mode tag

      $global:debugMode = $XMLContent.GetElementsByTagName("DebugMode") | Select-Object -ExpandProperty '#text'
      if (!($debugMode))
      {
      $debugMode =$True
      }

      Write-Log -filePath $logFileLocation -content "Config read successfully"
      $global:ReadConfigXML = $True
    }




     # node type condition not required as commented type not picked up by PS








}
#endregion

$TOTALCONFIGITEMS = 7
#endregion

$config = @() #  to store config of XML from locations
$date = GetFormattedDate
$logFileLocation = "C:\Users\t.b.ahmed\Desktop\Automation\TFO"  + $date + ".txt"
Write-Log -filePath $logFileLocation -content "File Deletion script"
ReadConfigXML # calling ReadConfigXMl for XMl validation and input creation

#region Validations and Code path decison post XML call and travese through XML
if ($global:testMode) ## checking if test Mode in On
{
    Write-Log -filePath $logFileLocation  -content "*** TESTMODE is set, nothing will actually be deleted!"
}

if (!($ReadConfigXML)) # if read XML is set to false code will be exited.
{
  exit
}

$config = $locations
$noOfFiles = 0
$noOfBytes = 0
[hashtable]$receiveHash = @{}


foreach ($configT in $config) ## traversing through element of XML and deletion function called
{
    # first layer check and deletion invoked.
    $reciveHash = DeleteFilesByAgeAndExtension -pFolder $configT.Path -pExtensions $configT.Extensions -pRetainDays $configT.RetainDays -pRecurse $config.Recurse -pDeleteFolders $configT.RemoveEmptyFolders -pExcludeFolders $configT.ExcludeLocations -pExcludeExtensions $configT.ExcludeExtensions -pUseFileCreationDate $configT.UseCreateDate
    $noOfFiles += [int32]$receiveHash.file
    $noOfBytes += [int32]$receiveHash.size

    # subsequent layer checks and deletion invoke.
    if ($config.Recurse -eq  "True")
    {
     $pFolder = $configT.Path
     $itemFolders = get-childitem -path $pFolder -Recurse |Where-Object {  $_.PSIsContainer } | Select-Object -ExpandProperty Fullname
        foreach ($itemFolder in $itemFolders)
        {
          $receiveHash = DeleteFilesByAgeAndExtension -pFolder $itemFolder  -pExtensions $configT.Extensions -pRetainDays $configT.RetainDays -pRecurse $config.Recurse -pDeleteFolders $configT.RemoveEmptyFolders -pExcludeFolders $configT.ExcludeLocations -pExcludeExtensions $configT.ExcludeExtensions -pUseFileCreationDate $configT.UseCreateDate
          $noOfFiles += [int32]$receiveHash.file
          $noOfBytes += [int32]$receiveHash.size
        }


        if ($configT.RemoveEmptyFolders -eq "True") #check and clean empty folders
            {
                $exclusiveFolders = $configT.ExcludeLocations -split ","
                $itemFolders = get-childitem -path $pFolder -Recurse |Where-Object {  $_.PSIsContainer } | Select-Object -ExpandProperty Fullname | Sort-Object -Descending -Property Length
                $itemFoldersRem = @() ## this will store the difference object
                # filtering out the excluded folders from empty ones
                foreach ($itemFoldersT in $itemFolders)
                {
                    $flag = 0
                    foreach ($exclusiveFoldersT in $exclusiveFolders)
                    {
                        if (($itemFoldersT -like "$exclusiveFoldersT*"))
                        {
                          $flag = 1
                          break
                        }
                    }
                    if ($flag -eq 0)
                    {
                        $itemFoldersRem += $itemFoldersT
                    }
                }

                #checking against empty folders and deletion
                foreach ($itemFolder in $itemFoldersRem)
                {

                    $creationDate = (get-item $itemFolder).CreationTime
                    $currentDate = get-date
                    $dateDiff = $currentDate - $creationDate
                    $ageDays = $dateDiff.TotalDays
                    # check if it is empty folders
                   if(!(Get-ChildItem -Path $itemFolder).Count)
                   {
                    if ($ageDays -ge $configT.RetainDays) # if the folder has passed its retain days time
                    {

                        Write-Log -filePath $logFileLocation  -content " Deleting empty folder $itemFolder  : $ageDays days old"
                       remove-item -Path $itemFolder -Force -Confirm:$false
                       $script:foldersDeleted += 1

                    }
                   }
                }
            }


    }
}

$summaryCount = "Files Deleted $script:filesdeleted" + "`r`n BytesDeleted $script:bytesDelted" + "`r`n FoldersDeleted $script:foldersdeleted"
Write-Log -filePath $logFileLocation -content $summaryCount



#endRegion
