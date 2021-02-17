$Host.UI.RawUI.WindowTitle = "Run As Admin"
set-executionpolicy remotesigned -force

Write-Host "------------------------------------------------------------"
Write-Host "     (c) 2021 - https://gitlab.com/vpess/Run-as-Admin"
Write-Host "------------------------------------------------------------`n"

Write-Host "Criando ambiente admin. Aguarde..."
Start-Sleep -s 1

$nomeUsuario = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$usuario = new-object System.Security.Principal.NTAccount($nomeUsuario)
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR | Out-Null
Set-location HKCR:\AppID\
(get-acl '{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}').setowner($usuario)
Start-Sleep -s 1


$acl = Get-Acl "HKCR:\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}"       
$access = [System.Security.AccessControl.RegistryRights]"FullControl"
$inheritance = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$propagation = [System.Security.AccessControl.PropagationFlags]"None"
$type = [System.Security.AccessControl.AccessControlType]"Allow"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($usuario,$access,$inheritance,$propagation,$type)
$acl.AddAccessRule($rule)
$acl | Set-Acl

Rename-ItemProperty -Path 'HKCR:\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}' -Name Runas -NewName Runas_
Start-Sleep -s 1

function selec {

    param (
    [string]$Titulo = 'Menu'
    )
    
    Write-Host "`n============================ Run As Admin ===========================`n" -ForegroundColor Blue
    
    Write-Host "	[1] Windows Explorer"
    Write-Host "	[2] Desinstalar um programa"
    Write-Host "	[3] Gerenciamento do Sistema (permissões, drivers, etc)"
    Write-Host "	[4] Painel de Controle"
    Write-Host "	[5] Propriedades do sistema (criação de variável)"
    Write-Host "	[q] para fechar o script" -ForegroundColor Red
    
    Write-Host "`n=====================================================================" -ForegroundColor Blue
    
     $selection = Read-Host "`nSelecione uma das opções acima"
     switch ($selection)
     {
    
         '1' {explorer.exe /separate -verb RunAs
            Start-Sleep -s 1
            return selec}
    
         '2' {start-process appwiz.cpl -verb RunAs
            Start-Sleep -s 1
            return selec}
    
         '3' {start-process compmgmt.msc -verb RunAs
            Start-Sleep -s 1
            return selec}

         '4' {start-process control -verb RunAs
            Start-Sleep -s 1
            return selec}

         '5' {start-process sysdm.cpl -verb RunAs
            Start-Sleep -s 1
            return selec}
    
         'q'{
            Write-Host "`nSaindo..." -ForegroundColor Red
            Start-sleep -s 2
            return
         }
    
         default {
    
            if ($selection -ige 6 -or $selection -ne 'q'){
                 Write-Host "`n>>> Selecione apenas opções que estejam no menu!" -ForegroundColor Red
                 Start-Sleep -s 2
                 return selec
                 }
            }
     }
    
}
    
    selec





<#Referências:

- https://www.alkanesolutions.co.uk/2016/06/29/set-registry-key-permissions-powershell/
- https://stackoverflow.com/questions/12044432/how-do-i-take-ownership-of-a-registry-key-via-powershell
- https://stackoverflow.com/questions/46586382/hide-powershell-output

#>
