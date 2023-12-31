# Used to reboot Hyper-Vs and not intended for VMs
# Yes there is manually, look at the GMD example <Target><ComputerName> in the <SingleAction> section
# Corrected Outfile path ln 22
# 20200223 Added prompt to show how many days away, day of week, and duration
param (
[Parameter(Mandatory=$true)]
[DateTime]$DateTime = "$($(Get-Date).addmonths(1))", # <- doesn't work
[int]$Duration = "300",
[int]$PreStart = "0", # <-- Use this to have reboot occure early
[string]$actioncompsfile = "",
[String]$descr,
[switch]$NoVerify,
[switch]$NoConfrm
)
if($DateTime -eq $null){
   "Exiting, no time set"
   pause
   exit
}

if ($actioncompsfile -ne "" ){
  if (!$NoVerify){
    "Opening actioncompsfile for verification, use -NoVerify to not be prompted for a host list"
    start notepad $actioncompsfile -Wait
    }
   $actioncomps = Get-Content $actioncompsfile
  }

  $span = (New-TimeSpan -Start $(Get-Date) -End $DateTime).Days
  if ($span -ge 0){
    if (!$NoConfrm){
    $pmpt = Read-Host -Prompt "This action will occure in $span days on a $($DateTime | Get-Date -Format dddd) for $($Duration/60) hours and affect $($actioncomps.count) computers. Do You want to continue? (Y/N)"
    if ($pmpt -ne "y"){
      "Exiting!"
      exit
    }
    }
  }else{
    "Date you entered is in the past or is invalid"
  }
  
$startDate = (Get-Date $DateTime).AddMinutes("-$PreStart") # <-- Use this to have reboot occure early
$SDB = New-TimeSpan -End $startDate #<-- Start Date before conversion to ISO 8601
$EDB = New-TimeSpan -End $startDate.AddMinutes($Duration) #<-- End Date before conversion to ISO 8601

$StartISO = "P" + $SDB.Days + "D" + "T" + $SDB.Hours + "H" + $SDB.Minutes + "M" + $SDB.Seconds + "S"
$EndDateISO = "P" + $EDB.Days + "D" + "T" + $EDB.Hours + "H" + $EDB.Minutes + "M" + $EDB.Seconds + "S"

$outfile = "$($env:USERPROFILE)\Documents\testbesfile.bes"
If ($descr){
  Set-Variable -Name "descr" -Value " - $descr"
}
$besTitle = "Secure AD Restart $DateTime$descr"

Out-File -FilePath $outfile -InputObject "<?xml version=""1.0"" encoding=""UTF-8""?>"
Out-File -FilePath $outfile -append -InputObject "<BES xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:noNamespaceSchemaLocation=""BES.xsd"">"
Out-File -FilePath $outfile -append -InputObject "	<SingleAction>"
Out-File -FilePath $outfile -append -InputObject "		<Title>$besTitle</Title>"
Out-File -FilePath $outfile -append -InputObject "		<Relevance>pending restart</Relevance>"
Out-File -FilePath $outfile -append -InputObject "		<ActionScript MIMEType=""application/x-Fixlet-Windows-Shell"">// only run this action on computers that are not locked"
Out-File -FilePath $outfile -append -InputObject "continue if {not locked of action lock state}"
Out-File -FilePath $outfile -append -InputObject ""
Out-File -FilePath $outfile -append -InputObject "// restart action command removed on March 8th, 2007, please set the appropriate post-action restart options through the Take Action Dialog."
Out-File -FilePath $outfile -append -InputObject "action requires restart</ActionScript>"
Out-File -FilePath $outfile -append -InputObject "		<SuccessCriteria Option=""OriginalRelevance""></SuccessCriteria>"
Out-File -FilePath $outfile -append -InputObject "		<Settings>"
Out-File -FilePath $outfile -append -InputObject "			<PreActionShowUI>false</PreActionShowUI>"
Out-File -FilePath $outfile -append -InputObject "			<HasRunningMessage>false</HasRunningMessage>"
Out-File -FilePath $outfile -append -InputObject "			<HasTimeRange>false</HasTimeRange>"
Out-File -FilePath $outfile -append -InputObject "			<HasStartTime>true</HasStartTime>"
Out-File -FilePath $outfile -append -InputObject "			<StartDateTimeLocalOffset>$StartISO</StartDateTimeLocalOffset>"
Out-File -FilePath $outfile -append -InputObject "			<HasEndTime>true</HasEndTime>"
Out-File -FilePath $outfile -append -InputObject "			<EndDateTimeLocalOffset>$EndDateISO</EndDateTimeLocalOffset>"
Out-File -FilePath $outfile -append -InputObject "			<HasDayOfWeekConstraint>false</HasDayOfWeekConstraint>"
Out-File -FilePath $outfile -append -InputObject "			<UseUTCTime>true</UseUTCTime>"
Out-File -FilePath $outfile -append -InputObject "			<ActiveUserRequirement>NoRequirement</ActiveUserRequirement>"
Out-File -FilePath $outfile -append -InputObject "			<ActiveUserType>AllUsers</ActiveUserType>"
Out-File -FilePath $outfile -append -InputObject "			<HasWhose>false</HasWhose>"
Out-File -FilePath $outfile -append -InputObject "			<PreActionCacheDownload>false</PreActionCacheDownload>"
Out-File -FilePath $outfile -append -InputObject "			<Reapply>true</Reapply>"
Out-File -FilePath $outfile -append -InputObject "			<HasReapplyLimit>true</HasReapplyLimit>"
Out-File -FilePath $outfile -append -InputObject "			<ReapplyLimit>3</ReapplyLimit>"
Out-File -FilePath $outfile -append -InputObject "			<HasReapplyInterval>false</HasReapplyInterval>"
Out-File -FilePath $outfile -append -InputObject "			<HasRetry>false</HasRetry>"
Out-File -FilePath $outfile -append -InputObject "			<HasTemporalDistribution>true</HasTemporalDistribution>"
Out-File -FilePath $outfile -append -InputObject "			<TemporalDistribution>PT25M</TemporalDistribution>"
Out-File -FilePath $outfile -append -InputObject "			<ContinueOnErrors>true</ContinueOnErrors>"
Out-File -FilePath $outfile -append -InputObject "			<PostActionBehavior Behavior=""Restart"">"
Out-File -FilePath $outfile -append -InputObject "				<AllowCancel>false</AllowCancel>"
Out-File -FilePath $outfile -append -InputObject "				<PostActionDeadlineBehavior>RunAutomatically</PostActionDeadlineBehavior>"
Out-File -FilePath $outfile -append -InputObject "				<PostActionDeadlineInterval>PT1M</PostActionDeadlineInterval>"
Out-File -FilePath $outfile -append -InputObject "				<Title>$besTitle</Title>"
Out-File -FilePath $outfile -append -InputObject "				<Text>Your system administrator is requesting that you restart your computer.  Please save any unsaved work and then take this action to restart your computer.</Text>"
Out-File -FilePath $outfile -append -InputObject "			</PostActionBehavior>"
Out-File -FilePath $outfile -append -InputObject "			<IsOffer>false</IsOffer>"
Out-File -FilePath $outfile -append -InputObject "		</Settings>"
Out-File -FilePath $outfile -append -InputObject "		<SettingsLocks>"
Out-File -FilePath $outfile -append -InputObject "			<ActionUITitle>false</ActionUITitle>"
Out-File -FilePath $outfile -append -InputObject "			<PreActionShowUI>false</PreActionShowUI>"
Out-File -FilePath $outfile -append -InputObject "			<PreAction>"
Out-File -FilePath $outfile -append -InputObject "				<Text>false</Text>"
Out-File -FilePath $outfile -append -InputObject "				<AskToSaveWork>false</AskToSaveWork>"
Out-File -FilePath $outfile -append -InputObject "				<ShowActionButton>false</ShowActionButton>"
Out-File -FilePath $outfile -append -InputObject "				<ShowCancelButton>false</ShowCancelButton>"
Out-File -FilePath $outfile -append -InputObject "				<DeadlineBehavior>false</DeadlineBehavior>"
Out-File -FilePath $outfile -append -InputObject "				<ShowConfirmation>false</ShowConfirmation>"
Out-File -FilePath $outfile -append -InputObject "			</PreAction>"
Out-File -FilePath $outfile -append -InputObject "			<HasRunningMessage>false</HasRunningMessage>"
Out-File -FilePath $outfile -append -InputObject "			<RunningMessage>"
Out-File -FilePath $outfile -append -InputObject "				<Text>false</Text>"
Out-File -FilePath $outfile -append -InputObject "			</RunningMessage>"
Out-File -FilePath $outfile -append -InputObject "			<TimeRange>false</TimeRange>"
Out-File -FilePath $outfile -append -InputObject "			<StartDateTimeOffset>false</StartDateTimeOffset>"
Out-File -FilePath $outfile -append -InputObject "			<EndDateTimeOffset>false</EndDateTimeOffset>"
Out-File -FilePath $outfile -append -InputObject "			<DayOfWeekConstraint>false</DayOfWeekConstraint>"
Out-File -FilePath $outfile -append -InputObject "			<ActiveUserRequirement>false</ActiveUserRequirement>"
Out-File -FilePath $outfile -append -InputObject "			<ActiveUserType>false</ActiveUserType>"
Out-File -FilePath $outfile -append -InputObject "			<Whose>false</Whose>"
Out-File -FilePath $outfile -append -InputObject "			<PreActionCacheDownload>false</PreActionCacheDownload>"
Out-File -FilePath $outfile -append -InputObject "			<Reapply>false</Reapply>"
Out-File -FilePath $outfile -append -InputObject "			<ReapplyLimit>false</ReapplyLimit>"
Out-File -FilePath $outfile -append -InputObject "			<RetryCount>false</RetryCount>"
Out-File -FilePath $outfile -append -InputObject "			<RetryWait>false</RetryWait>"
Out-File -FilePath $outfile -append -InputObject "			<TemporalDistribution>false</TemporalDistribution>"
Out-File -FilePath $outfile -append -InputObject "			<ContinueOnErrors>false</ContinueOnErrors>"
Out-File -FilePath $outfile -append -InputObject "			<PostActionBehavior>"
Out-File -FilePath $outfile -append -InputObject "				<Behavior>true</Behavior>"
Out-File -FilePath $outfile -append -InputObject "				<AllowCancel>false</AllowCancel>"
Out-File -FilePath $outfile -append -InputObject "				<Deadline>false</Deadline>"
Out-File -FilePath $outfile -append -InputObject "				<Title>false</Title>"
Out-File -FilePath $outfile -append -InputObject "				<Text>false</Text>"
Out-File -FilePath $outfile -append -InputObject "			</PostActionBehavior>"
Out-File -FilePath $outfile -append -InputObject "			<IsOffer>false</IsOffer>"
Out-File -FilePath $outfile -append -InputObject "			<AnnounceOffer>false</AnnounceOffer>"
Out-File -FilePath $outfile -append -InputObject "			<OfferCategory>false</OfferCategory>"
Out-File -FilePath $outfile -append -InputObject "			<OfferDescriptionHTML>false</OfferDescriptionHTML>"
Out-File -FilePath $outfile -append -InputObject "		</SettingsLocks>"
Out-File -FilePath $outfile -append -InputObject "		<IsUrgent>false</IsUrgent>"
if ($actioncomps){ # Adds targets if specified
    Out-File -FilePath $outfile -append -InputObject "    <Target>"
    $actioncomps | % {
      $actioncomp = $_
      if ($actioncomp -match ".") {$actioncomp = $actioncomp.Split(".")[0]}
      Out-File -FilePath $outfile -append -InputObject "        <ComputerName>$actioncomp</ComputerName>"
      }
      Out-File -FilePath $outfile -append -InputObject "    </Target>"
    }  
Out-File -FilePath $outfile -append -InputObject "	</SingleAction>"
Out-File -FilePath $outfile -append -InputObject "</BES>"

start $outfile
#Examples (using old filename)
# .\BESRestartParamsChangeA.ps1 -DateTime "01/10/2020 19:00"
# .\BESRestartParamsChangeA.ps1 -DateTime "01/10/2020 20:00"
# .\BESRestartParamsChangeA.ps1 -DateTime "01/10/2020 20:30"
# .\BESRestartParamsChangeA.ps1 -DateTime "01/10/2020 7:00 pm"
