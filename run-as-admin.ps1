########################## Pegar o controle da chave de registro ##########################

$nomeUsuario = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$usuario = new-object System.Security.Principal.NTAccount($nomeUsuario)
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
Set-location HKCR:\AppID\
(get-acl '{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}').setowner($usuario)

########################## Atribuir permissão ao admin ##########################

$acl = Get-Acl "HKCR:\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}"
#$usuario = new-object System.Security.Principal.NTAccount($nomeUsuario)       
$access = [System.Security.AccessControl.RegistryRights]"FullControl"
$inheritance = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$propagation = [System.Security.AccessControl.PropagationFlags]"None"
$type = [System.Security.AccessControl.AccessControlType]"Allow"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($usuario,$access,$inheritance,$propagation,$type)
$acl.AddAccessRule($rule)
$acl | Set-Acl

############# Renomear o valor de Runas ##########################
Rename-ItemProperty -Path 'HKCR:\AppID\{CDCBCFCA-3CDC-436f-A4E2-0E02075250C2}' -Name Runas -NewName Runas_old

############# Abrir explorer.exe como admin ##########################
start-process explorer.exe /separate -verb RunAs
