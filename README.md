# Create-ADUserAndEnableMailbox.ps1

This PowerShell script automates the process of creating a new Active Directory (AD) user and provisioning an Exchange mailbox for that user.  
It is designed for system administrators who want to streamline onboarding and enforce consistent mailbox configurations.

---

## Features

- Creates a new AD user with specified attributes.
- Optionally clones group memberships from an existing user.
- Enables an Exchange mailbox for the new user.
- Sets the primary SMTP address.
- Applies mailbox quota settings.
- Forces synchronization of recipient attributes in Exchange.

---

## Requirements

- Run **only** from the **Exchange Server** or a system with the **Exchange Management Shell** installed and properly configured.
- Must have **administrative privileges** in both **Active Directory** and **Exchange**.
- Tested on **Exchange Server 2016** and **Exchange Server 2019**.
- PowerShell 5.1 or later recommended.

---

## Parameters to Update Before Running

Inside the script, replace the following placeholder values:

| Parameter          | Description                             | Example               |
|-------------------|-----------------------------------------|-----------------------|
| `$firstName`       | First name of the new user              | `"John"`              |
| `$lastName`        | Last name of the new user               | `"Doe"`               |
| `$username`        | sAMAccountName / UPN prefix             | `"jdoe"`              |
| `$smtpDomain`      | Your email domain                       | `"example.com"`       |
| `$existingUser`    | Existing AD user to copy groups from    | `"templateuser"`      |
| `$initialPassword` | Default password for the new account    | `"Welcome@123"`       |
| `$mailboxDatabase` | Exchange mailbox database name          | `"MailboxDatabase01"` |

---

## Usage

1. Open **Exchange Management Shell** on the Exchange Server.
2. Run the script:

```powershell
.\Create-ADUserAndEnableMailbox.ps1
```

3. Monitor the output for success messages or errors.

---

## Disclaimer

This script is provided as-is, with no warranties.  
Always test in a non-production environment before deploying to live systems.

Script Author: [aviado1](https://github.com/aviado1)
