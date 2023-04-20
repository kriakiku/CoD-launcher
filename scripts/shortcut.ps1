####
# Create shortcut to launcher with icon
####
$shortcutName = "CoD Warzone 2.0"
$targetPath = "$PSScriptRoot\launcher.ps1"
$shortcutPath = ([Environment]::GetFolderPath("Desktop")+"\$shortcutName.lnk")
$iconsPath = (Split-Path -Path $PSScriptRoot -Parent) + "\icons"
$iconsDefault = "DEFAULT.ico"
$defaultApplicationPath = "steam://rungameid/1938090"
$defaultLocalePattern = "en"
$defaultFallbackLocale = "en-US"

####
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create shortuct
function Update-Shortcut {
    # Get props
    $props = Get-PickShortcutProps
    if ($null -eq $props) {
        return 
    }

    # Rename prev. file
    if (Test-Path -Path $shortcutPath -PathType Leaf) {
        $prefix = (Get-Date -Date ((Get-Date).DateTime) -UFormat %s)
        Rename-Item -Path $shortcutPath -NewName "Backup-$prefix-$shortcutName.lnk"
    }

    # Create shortcut
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)

    # Set icon
    $icon = $props[0]
    if ($null -ne $icon) {
        $shortcut.IconLocation = "$iconsPath\$icon"
    }

    # Save shortuct
    $path = $props[1]
    $localePattern = $props[2]
    $fallbackLocale = $props[3]
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetPath`" `"$path`" `"$localePattern`" `"$fallbackLocale`""

    $shortcut.Save()
}

# List of icons
function Get-IconList {
    $items = Get-ChildItem -Path $iconsPath
    Write-Output $items
}

# Icon picker
function Get-PickShortcutProps {
    # Header
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Pick launcher settings'
    $form.Size = New-Object System.Drawing.Size(300,480)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'Fixed3D'
    $form.MaximizeBox = $false


    ####
    # Icon picker
    ####

    # Label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,10)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Pick icon from list:'
    $form.Controls.Add($label)

    # Info
    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point(10,105)
    $info.Size = New-Object System.Drawing.Size(280,20)
    $info.Text = '* Or you can add custom icon to the icons folder'
    $form.Controls.Add($info)

    # List of icons
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,30)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 80

    # Fill icons
    $icons = Get-IconList
    $pickedIcon = $null
    foreach ($icon in $icons) {
        [void] $listBox.Items.Add($icon)

        if ("$icon" -eq $iconsDefault) {
            $pickedIcon = $icon
            $listBox.SelectedItem = $icon
        }
    }


    ####
    # Application Path picker
    ####

    # Label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,140)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Path to application:'
    $form.Controls.Add($label)

    # Patch to application
    $path = New-Object System.Windows.Forms.TextBox
    $path.Location = New-Object System.Drawing.Point(10,160)
    $path.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($path)
    $path.Text = $defaultApplicationPath

    # Info
    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point(10,185)
    $info.Size = New-Object System.Drawing.Size(280,25)
    $info.Text = '* You can find the path by looking at the shortcut property of the application you need'
    $form.Controls.Add($info)


    ####
    # Locale Pattern
    ####

    # Label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,230)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Locale region pattern to avoid creating a new locale:'
    $form.Controls.Add($label)

    # Patch to application
    $localePattern = New-Object System.Windows.Forms.TextBox
    $localePattern.Location = New-Object System.Drawing.Point(10,250)
    $localePattern.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($localePattern)
    $localePattern.Text = $defaultLocalePattern

    # Info
    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point(10,275)
    $info.Size = New-Object System.Drawing.Size(280,40)
    $info.Text = "* Leave the value blank if you need a locale without a region (such as uk, ru); en (English: en-US, en-GB)"
    $form.Controls.Add($info)


    ####
    # Fallback Locale
    ####

    # Label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,320)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'The locale that will be added to the system as fallback:'
    $form.Controls.Add($label)

    # Patch to application
    $fallbackLocale = New-Object System.Windows.Forms.TextBox
    $fallbackLocale.Location = New-Object System.Drawing.Point(10,340)
    $fallbackLocale.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($fallbackLocale)
    $fallbackLocale.Text = $defaultFallbackLocale

    # Info
    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point(10,365)
    $info.Size = New-Object System.Drawing.Size(280,40)
    $info.Text = "* Value examples: en-US (English), de-DE (German), uk (Ukranian), ru (Russian)."
    $form.Controls.Add($info)


    ####
    # Control buttons
    ####

    # Confirm Button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(185,405)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Confirm'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(10,405)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)


    ####
    # Logic
    ####

    $form.Controls.Add($listBox)
    $form.Topmost = $true
    $result = $form.ShowDialog()

    # Get picked icon
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        if ($null -ne $listBox.SelectedItem) {
            $pickedIcon = $listBox.SelectedItem
        }
    }

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Write-Output $null
    }
    
    elseif ($null -ne $pickedIcon) {
        Write-Output $pickedIcon $path.Text $localePattern.Text $fallbackLocale.Text
    }

}

Update-Shortcut
