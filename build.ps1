param (

    [  Bool  ]  $Release = $False, # Build for release. Creates a ./dist folder for distribution.
    [  Bool  ]  $Clean = $True, # Clean the build directory folder before building.
    [  Bool  ]  $CopyToWow = $False, # After building, copy and extract the files to directories defined by $WowVersions.
    [ string ]  $PackageName = "ArcHUD3", # Set the package name. Default: ArcHUD3.
    [ string ]  $PackageVersion = $(Get-Content -Path .\VERSION.txt), # Set the package version. Defaults to the value in VERSION.txt.
    [ string ]  $BuildDir = ".\build", # Set the build directory. Default: .\build
    
    # Set the build destination path.
    # Defaults to $BuildDir\$PackageName-$PackageVersion.zip. 
    # Overrides package name and version.
    [ string ]  $DestinationPath = "$BuildDir\$PackageName-$PackageVersion.zip" ,
                                                                                    
    # If $CopyToWow is set to true, automatically copy and extract the package to these WoW versions.
    [ string [] ]  $WowVersions = @(
        "C:\Program Files (x86)\World of Warcraft\_retail_",
        "C:\Program Files (x86)\World of Warcraft\_classic_",
        "C:\Program Files (x86)\World of Warcraft\_classic_era_"
    )

)

#--------------------------------------------------
# Create Build Directory
#--------------------------------------------------

Write-Debug "Creating build directory: $BuildDir"

if ($Clean && Test-Path $BuildDir) {
    Remove-Item -Path $BuildDir -Recurse -Force
    New-Item -Path $BuildDir -ItemType Directory | Out-Null
}

#--------------------------------------------------
# Archive Files
#--------------------------------------------------

Write-Debug "Archiving files to: $DestinationPath"

Compress-Archive `
    -Path `
    .\Docs, `
    .\Icons, `
    .\Libs, `
    .\Locales, `
    .\Rings, `
    .\ArcHUD3.toc, `
    .\*.lua, `
    .\*.xml, `
    .\*.txt, `
    .\*.md `
    -DestinationPath `
    $DestinationPath `
    -Force

#--------------------------------------------------
# Copy To WoW Directory
#--------------------------------------------------

if ($CopyToWow) {
    for ($i = 0; $i -lt $WowVersions.Length; $i++) {
        $wowVersion = $WowVersions[$i]
        $wowVersionDir = "$wowVersion\Interface\AddOns\$PackageName"
        $wowVersionDirExists = Test-Path $wowVersionDir

        if ($wowVersionDirExists) {
            Write-Debug "Removing existing directory: $wowVersionDir"
            Remove-Item -Path $wowVersionDir -Recurse -Force
        }

        Write-Debug "Extracting package to: $wowVersionDir"
        Expand-Archive -Path $DestinationPath -DestinationPath $wowVersionDir
    }
}
