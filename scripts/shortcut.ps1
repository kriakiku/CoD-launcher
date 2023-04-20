####
# Create shortcut to launcher with icon
####
$shortcutName = "CoD Warzone 2.0"
$targetPath = "$PSScriptRoot\run.bat"
$shortcutPath = ([Environment]::GetFolderPath("Desktop")+"\$shortcutName.lnk")
$iconsPath = (Split-Path -Path $PSScriptRoot -Parent) + "\icons"
$iconsDefault = "DEFAULT.ico"

####
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create shortuct
function Update-Shortcut {
    # Rename prev. file
    if (Test-Path -Path $shortcutPath -PathType Leaf) {
        $prefix = (Get-Date -Date ((Get-Date).DateTime) -UFormat %s)
        Rename-Item -Path $shortcutPath -NewName "Backup-$prefix-$shortcutName.lnk"
    }

    # Create shortcut
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)

    # Set icon
    $pickedIcon = Get-PickShortcutIcon
    if ($null -ne $pickedIcon) {
        $shortcut.IconLocation = "$iconsPath\$pickedIcon"
        Write-Host "$iconsPath\$pickedIcon"
    }

    # Save shortuct
    $shortcut.TargetPath = $targetPath
    $shortcut.Save()
}

# List of icons
function Get-IconList {
    $items = Get-ChildItem -Path $iconsPath
    Write-Output $items
}

# Icon picker
function Get-PickShortcutIcon {
    # Header
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Pick launcher icon'
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'

    # Confirm Button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(185,130)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Pick'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    # Cancel button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(10,130)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

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

    # Logic
    $form.Controls.Add($listBox)
    $form.Topmost = $true
    $result = $form.ShowDialog()

    # Get picked icon
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        if ($null -ne $listBox.SelectedItem) {
            $pickedIcon = $listBox.SelectedItem
        }
    }

    if ($null -ne $pickedIcon) {
        Write-Output $pickedIcon
    }

}

Update-Shortcut
