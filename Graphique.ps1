function Get-Test{
    Write-Host "Lancement de l'interface graphique"
}

function Get-CreationChampSaisi{
    param(
        [int]$LocalisationChamp,
        [String]$NomChamp,
        $Textbox1,
        $Form

    )

    $Label1 = New-Object System.Windows.Forms.Label
    $Label1.Text = $NomChamp
    $Label1.Location = New-Object System.Drawing.Point(10,$LocalisationChamp)
    $Label1.AutoSize = $true
    $Form.Controls.Add($Label1)

    
    $Textbox1.Location = New-Object System.Drawing.Point(120,$LocalisationChamp)
    $Textbox1.Size = New-Object System.Drawing.Size(150,$LocalisationChamp)
    $Form.Controls.Add($Textbox1)

    return $LocalisationChamp+40
}



function Get-CreationButton{
    param(
        [int]$LocalisationChamp,
        [String]$NomChamp,
        $Button,
        $Form
    )

    $Button.Location = New-Object System.Drawing.Point(100,$LocalisationChamp)
    $Button.Size = New-Object System.Drawing.Size(100,23)
    $Button.Text = $NomChamp
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $Form.AcceptButton = $Button
    $Form.Controls.Add($Button)



    return $LocalisationChamp+40
}



function Get-ChampDossierParcouru{
    param(
        [int]$LocalisationChamp,
        [String]$NomChamp,
        $ButtonBrowse,
        $TextBoxPath,
        $Form
    )

    # Créer le contrôle pour sélectionner un chemin de destination
    $LabelPath = New-Object System.Windows.Forms.Label
    $LabelPath.Location = New-Object System.Drawing.Point(10,$LocalisationChamp)
    $LabelPath.Size = New-Object System.Drawing.Size(100,40)
    $LabelPath.Text = $NomChamp
    $Form.Controls.Add($LabelPath)

    
    $TextBoxPath.Location = New-Object System.Drawing.Point(120,$LocalisationChamp)
    $TextBoxPath.Size = New-Object System.Drawing.Size(120,20)
    $Form.Controls.Add($TextBoxPath)

    
    $ButtonBrowse.Location = New-Object System.Drawing.Point(250,$LocalisationChamp)
    $ButtonBrowse.Size = New-Object System.Drawing.Size(30,20)
    $ButtonBrowse.Text = "..."

    # Ajouter une action pour le bouton Parcourir
    $ButtonBrowse.Add_Click({
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.Description = "Sélectionner le dossier de destination"
    if($FolderBrowserDialog.ShowDialog() -eq "OK")
    {
        $TextBoxPath.Text = $FolderBrowserDialog.SelectedPath
    }
    })


    $Form.Controls.Add($ButtonBrowse)
    

    return $LocalisationChamp+40
}

function Get-Menu_Deroulant{
    param(
        [int]$LocalisationChampY,
        [int]$LocalisationChampX,
        [int]$LongueurChamp,
        $comboBox,
        $form2,
        $Liste
    )

    # Création de la liste déroulante
    $comboBox.Location = New-Object System.Drawing.Point($LocalisationChampX, $LocalisationChampY)
    $comboBox.Size = New-Object System.Drawing.Size($LongueurChamp, 25)

    # Ajout des éléments dans la liste déroulante

    foreach($element in $Liste){
        $comboBox.Items.Add($element)
    }
    #$comboBox.Items.Add("Utilisateurs toutes les informations")
    #$comboBox.Items.Add("Utilisateurs par Liste de Distribution")


    # Ajout de l'événement pour détecter les changements dans la liste déroulante
    #$handler = {
    #    $selectedValue = $comboBox.SelectedItem.ToString()
    #    Write-Host "Nouvelle option selectionnee : $selectedValue"
    #}
    #$comboBox.add_SelectedIndexChanged($handler)

    # Ajout de la liste déroulante dans la fenêtre
    $form2.Controls.Add($comboBox)

    return $LocalisationChampY+40
}

function Set-Creation_Label{
    param(
        [int]$LocalisationChampY,
        [int]$LocalisationChampX,
        [String]$NomChamp,
        $form2
    )

    # Création du label
    $Label1 = New-Object System.Windows.Forms.Label
    $Label1.Text = $NomChamp
    $Label1.Location = New-Object System.Drawing.Point($LocalisationChampX,$LocalisationChampY)
    $Label1.AutoSize = $true
    $form2.Controls.Add($Label1)

}


#Creation d'une fenetre avec barre de chargement
function Get-CreationFenetreChargement{
    param(
        $form
    )


    # Création de la fenêtre principale
    $form.Size = New-Object System.Drawing.Size(300, 150)
    $form.StartPosition = 'CenterScreen'
    $form.Text = 'Chargement en cours'

    # Création de la barre de chargement
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Style = 'Continuous'
    $progressBar.Width = 250
    $progressBar.Height = 30
    $progressBar.Left = ($form.Width - $progressBar.Width) / 2
    $progressBar.Top = ($form.Height - $progressBar.Height) / 2
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100  

    # Ajout de la barre de chargement à la fenêtre
    $form.Controls.Add($progressBar)

    # Affichage de la fenêtre
    $form.Show()

    # Retourne la barre de chargement
    return $progressBar

}


