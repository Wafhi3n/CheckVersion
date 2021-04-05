
$modId = @(
    @("cb84074d-5007-4207-b662-c35a5f7be240","Better balanced Game","https://api.github.com/repos/iElden/BetterBalancedGame/releases/latest"),
    @("c88cba8b-8311-4d35-90c3-51a4a5d6654f","better balanced Start","https://api.github.com/repos/d-jackthenarrator/Civ6-BBS/releases/latest")
    @("c6e5ad32-0600-4a98-a7cd-5854a1abcaaf","Better Spectator Mod","https://api.github.com/repos/d-jackthenarrator/Civ6-BSM/releases/latest"),
    @("619ac86e-d99d-4bf3-b8f0-8c5b8c402176","Multiplayer Helper","https://api.github.com/repos/d-jackthenarrator/Civ6-MPH/releases/latest")
  ) 
function LoadModule ($m) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        #write-host "Module $m is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m 
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m 
            }
            else {
                # If module is not imported, not available and not in online gallery then abort
                write-host "Module $m not imported, not available and not in online gallery, exiting."
                EXIT 1
            }
        }
    }
}
function GetRemoteData(){
    param(
        $uri
    )
    $info=Invoke-RestMethod -Uri $uri
    return  $info
}
function IsLastestVersionInstalled{
    param(
        $Id,
        $version
    )
    $query = "SELECT Disabled FROM Mods a JOIN ModGroupItems b ON a.ModRowId = b.ModRowId where ModId = '$Id' and Version = '$version' "
    $dataSource=$documents+"\My Games\Sid Meier's Civilization VI\Mods.sqlite"
    $results = Invoke-SqliteQuery -Query $query -DataSource $dataSource
    return $results
}
function main(){
    $v=1;
    $d=1;
    $documents=[environment]::getfolderpath("mydocuments")
    $modId | ForEach-Object {
        $remoteData=GetRemoteData ($PSItem[2])
        $versionGit=$remoteData.tag_name
        $prettyVersion=$versionGit;
        if ($PSItem[0] -eq 'cb84074d-5007-4207-b662-c35a5f7be240'){
            $versionGit=$versionGit.split('.');
            $versionGit=$($versionGit[0]+"."+$versionGit[1].PadLeft(2,"0")+"."+$versionGit[2])
        }
        $versionGit= $versionGit -replace '[^0-9]',""
        $data=IsLastestVersionInstalled $PSItem[0] $versionGit
        if(!$data){
            write-host $PSItem[1] $prettyVersion "non install�, pensez � mettre � jour le mod ou � l'installer"
            write-host "Voici le lien pour une installation hors steam : "$remoteData.html_url
            $d=0;
        }elseif($data.disabled  -ne 0 ){
            Write-Host $PSItem[1] "est desactiv�"
            $d=0;
        }                 
    }
    if($d -And $v){
        write-host "Les mods sont � jour, bravo."
    }
    Read-Host -Prompt "Appuyer sur Entr�e pour quitter."
}
LoadModule PSSQLite
main


