<#
.SYNOPSIS
    Creates a new Active Directory (AD) user and enables a mailbox for that user in Microsoft Exchange Server.

.DESCRIPTION
    This script performs two main tasks:
    1. Creates a new AD user, optionally cloning group memberships from an existing user.
    2. Enables a mailbox for the new user, sets the primary SMTP address, applies mailbox quotas,
       and forces synchronization of recipient attributes.

    ⚠️ IMPORTANT:
    - This script must be executed directly from the Exchange Server or from a management workstation 
      where the Exchange Management Shell is installed.
    - Ensure the executing user has the necessary permissions in both Active Directory and Exchange.

.NOTES
    Author: Example Author
    Date:   2025-04-06
    Environment: Exchange Server PowerShell
#>

# ----------------------------
# PART 1: Create AD User
# ----------------------------

# Example parameters (replace with real values before use)
$firstName       = "John"
$lastName        = "Doe"
$username        = "jdoe"
$jobTitle        = "IT Analyst"
$mobile          = "050-1234567"
$existingUser    = "templateuser"
$initialPassword = "Welcome@123"

# Get group memberships from existing user (optional clone)
$groups = Get-ADUser -Identity $existingUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Create the AD user
New-ADUser `
    -Name "$firstName $lastName" `
    -DisplayName "$firstName $lastName" `
    -GivenName $firstName `
    -Surname $lastName `
    -SamAccountName $username `
    -UserPrincipalName "$username@example.com" `
    -Title "$jobTitle" `
    -MobilePhone $mobile `
    -AccountPassword (ConvertTo-SecureString $initialPassword -AsPlainText -Force) `
    -ChangePasswordAtLogon $false `
    -PasswordNeverExpires $true `
    -ScriptPath "logon.bat" `
    -HomeDirectory "\\server\Users\$username" `
    -HomeDrive "U:" `
    -Enabled $true

# Add user to same groups as the existing user
foreach ($group in $groups) {
    Add-ADGroupMember -Identity $group -Members $username
}

Write-Host "✅ AD user '$username' created and added to groups." -ForegroundColor Green

# ----------------------------
# PART 2: Enable Exchange Mailbox
# ----------------------------

# Load Exchange snap-in (if needed; adjust for your environment)
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn -ErrorAction SilentlyContinue

$mailboxDatabase = "MailboxDatabase01"
$smtpDomain      = "example.com"
$smtpAddress     = "$username@$smtpDomain"

# Ensure AD user exists
$userExists = Get-ADUser -Identity "$username" -ErrorAction SilentlyContinue
if (-not $userExists) {
    Write-Host "❌ Error: AD user '$username' does not exist. Exiting." -ForegroundColor Red
    exit 1
}

# Enable Exchange mailbox
Enable-Mailbox -Identity "$username" -Database "$mailboxDatabase"
Write-Host "📬 Mailbox enabled for '$username'." -ForegroundColor Green

# Wait to allow mailbox provisioning to complete
Start-Sleep -Seconds 30

# Confirm mailbox was created
$mailboxExists = Get-Mailbox -Identity "$username" -ErrorAction SilentlyContinue
if ($mailboxExists) {
    Set-Mailbox "$username" -EmailAddresses "SMTP:$smtpAddress"

    Set-Mailbox "$username" `
        -IssueWarningQuota 10GB `
        -ProhibitSendQuota 11GB `
        -ProhibitSendReceiveQuota 13GB

    Update-Recipient -Identity "$username"

    Write-Host "📦 Mailbox configured successfully for '$username'." -ForegroundColor Cyan
} else {
    Write-Host "❌ Error: Mailbox for '$username' not found after creation." -ForegroundColor Red
    exit 1
}

Write-Host "🎉 User '$username' fully provisioned with mailbox and settings." -ForegroundColor Green
