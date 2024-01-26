Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Security Features Checker by Anonre"
$form.Size = New-Object System.Drawing.Size(700, 450)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# Define controls
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter the path(s) to the thick client application(s), separated by commas:"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10, 20)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$textBox.Size = New-Object System.Drawing.Size(580, 30)

$addButton = New-Object System.Windows.Forms.Button
$addButton.Text = "Add File"
$addButton.Location = New-Object System.Drawing.Point(600, 50)
$addButton.Size = New-Object System.Drawing.Size(70, 30)
$addButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$addButton.BackColor = [System.Drawing.Color]::FromArgb(66, 139, 202)
$addButton.ForeColor = [System.Drawing.Color]::White
$addButton.Add_Click({
    # Handle Add File button click
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*"
    $fileDialog.Multiselect = $true

    if ($fileDialog.ShowDialog() -eq "OK") {
        $selectedFiles = $fileDialog.FileNames -join ' '
        $textBox.Text += " $selectedFiles"
    }
})

$checkButton = New-Object System.Windows.Forms.Button
$checkButton.Text = "Check Security Features"
$checkButton.Location = New-Object System.Drawing.Point(10, 90)
$checkButton.Size = New-Object System.Drawing.Size(660, 40)
$checkButton.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$checkButton.BackColor = [System.Drawing.Color]::Green
$checkButton.ForeColor = [System.Drawing.Color]::White
$checkButton.Add_Click({
    # Handle Check Security Features button click
    $filePaths = $textBox.Text -split ' ' | ForEach-Object { $_.Trim() }

    # Clear the result text box
    $resultTextBox.Text = ""

    # Check security features for each file
    foreach ($filePath in $filePaths) {
        Test-SecurityFeatures $filePath
    }
})

$resultTextBox = New-Object System.Windows.Forms.TextBox
$resultTextBox.Multiline = $true
$resultTextBox.ScrollBars = "Vertical"
$resultTextBox.ReadOnly = $true
$resultTextBox.Location = New-Object System.Drawing.Point(10, 140)
$resultTextBox.Size = New-Object System.Drawing.Size(660, 260)

# Add controls to the form
$form.Controls.Add($label)
$form.Controls.Add($textBox)
$form.Controls.Add($addButton)
$form.Controls.Add($checkButton)
$form.Controls.Add($resultTextBox)

# Function to test security features
function Test-SecurityFeatures($filePath) {
    try {
        # Trim the file path to remove leading and trailing spaces
        $trimmedFilePath = $filePath.Trim()

        # Check if the trimmed file path is not empty
        if (-not [string]::IsNullOrWhiteSpace($trimmedFilePath)) {
            # Get the file object
            $file = Get-Item $trimmedFilePath

            # Get the file header using Get-Command
            $fileHeader = Get-Command $file.FullName -ErrorAction Stop

            # Check if the file header contains the "NX_COMPAT" flag
            $nxCompatibility = $fileHeader.Definition -match "NX_COMPAT"

            # Check if DEP is enabled
            $depEnabled = $fileHeader.Definition -match "DYNAMICBASE"
            
            # Check if ASLR is enabled
            $aslrEnabled = $fileHeader.Definition -match "DYNAMICBASE"

            # Check if CFG is enabled
            $cfgEnabled = $fileHeader.Definition -match "GUARD_CF"

            # Display security features result
            $resultTextBox.AppendText("File: $($file.Name)`r`n")
            $resultTextBox.AppendText("Path: $($file.FullName)`r`n")
            $resultTextBox.AppendText("`r`n")

            $resultTextBox.AppendText("NX ( No eXecute ): ")
            if ($nxCompatibility) {
                $resultTextBox.AppendText("Enabled`r`n")
            } else {
                $resultTextBox.AppendText("Disabled`r`n")
            }

            $resultTextBox.AppendText("DEP ( Data Execution Prevention ): ")
            if ($depEnabled) {
                $resultTextBox.AppendText("Enabled`r`n")
            } else {
                $resultTextBox.AppendText("Disabled`r`n")
            }

            $resultTextBox.AppendText("ASLR ( Address Space Layout Randomization ): ")
            if ($aslrEnabled) {
                $resultTextBox.AppendText("Enabled`r`n")
            } else {
                $resultTextBox.AppendText("Disabled`r`n")
            }

            $resultTextBox.AppendText("CFG ( Control Flow Guard ): ")
            if ($cfgEnabled) {
                $resultTextBox.AppendText("Enabled`r`n")
            } else {
                $resultTextBox.AppendText("Disabled`r`n")
            }

            $resultTextBox.AppendText(("" * 50) + "`r`n")
        } else {
            $resultTextBox.AppendText("Success Scanning Inputed File`r`n")
            $resultTextBox.AppendText("`r`n")
        }
    } catch {
        $resultTextBox.AppendText("Error: $_.Exception.Message`r`n")
    }
}

# Show the form
$form.ShowDialog()
