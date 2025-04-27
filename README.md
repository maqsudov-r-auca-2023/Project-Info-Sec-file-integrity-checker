# File Integrity Checker

*File Integrity Checker* is a Bash-based tool for monitoring and verifying the integrity of files on a Linux system. It computes checksums of specified files and compares them to a known baseline to detect any unauthorized changes. With features like colorized terminal output, automated cron scheduling, logging, and email alerts, this script helps ensure you are quickly notified of any modifications to your critical files.

## Features

- **Colorized Terminal Output:** Results are displayed with colored text for quick understanding (e.g., green for normal status and red for integrity issues).
- **File Integrity Checking:** Uses cryptographic hash comparisons (such as MD5 or SHA) to detect if files have been modified, added, or removed since the last baseline snapshot.
- **Cron Automation:** Designed to run at regular intervals via cron, allowing continuous monitoring without manual intervention.
- **Logging:** Records the results of each integrity check to a log file, creating an audit trail of changes over time.
- **Email Notifications:** Sends an email alert immediately when any file change is detected, so you can respond promptly to potential issues.

## Requirements

Make sure you have the following available on your system:

- **Linux OS** – The script is intended to run on a Linux environment.
- **Bash** – A Bash shell (the integrity checker script is written in Bash).
- **Cron** – Cron service for scheduling automated checks (optional, but needed for automation).
- **mailutils** – Command-line mail utility for sending emails (required for email notifications). Ensure the `mail` (or `mailx`) command is available after installing this.

## Installation

To set up the File Integrity Checker on your system, follow these steps:

1. **Clone the repository**: Download or clone the project repository to your local machine. For example:  
   ```bash https://github.com/maqsudov-r-auca-2023/Project-Info-Sec-file-integrity-checker.git 
   ```  

2. **Navigate to the project directory**:  
   ```bash
   cd File-Integrity-Checker
   ```
3. **Make the script executable**: Grant execute permission to the main script:  
   ```bash
   chmod +x file_integrity_checker.sh
   ```
4. **Install mailutils (if not already installed)**: This is needed for the script to send email. On Debian/Ubuntu you can install it with:  
   ```bash
   sudo apt update && sudo apt install mailutils
   ```  
   *(For other Linux distributions, install the equivalent package for the mail command, such as `mailx`.)*

## Usage

### Initializing the Hash Database (Baseline)

Before you can check file integrity, you need to generate a baseline of hashes for the files you want to monitor. Run the script in "initialize" mode to create this baseline database of file checksums. For example:  

```bashhttps://github.com/maqsudov-r-auca-2023/Information-Security.git
./file_integrity_checker.sh --init
```  

This will scan the specified directories/files and record their cryptographic hashes in a baseline file (for example, `file_integrity_baseline.db`). Keep this baseline file in a safe location; it represents the "known good" state of your files. **Note:** You typically only need to do this initialization once (or whenever you want to redefine what is considered the normal state of your files).

### Running Integrity Checks Manually

Once a baseline is established, you can run the integrity checker at any time to verify the files against the saved baseline. Simply execute the script without any flags:  

```bash
./file_integrity_checker.sh
```  

The script will compute the current hashes of the monitored files and compare them to the baseline database:  
- If **no changes** are detected, you'll see a confirmation message (printed in green text) indicating that all files match the baseline and are intact.  
- If **changes** are detected, the script will clearly list the files that were added, removed, or modified. These entries will be highlighted (for example, in red text for modified files) to draw attention. For each changed file, the output will indicate the type of change (modification, addition, or deletion).  

After running, you should review the output to see if any changes were unexpected. If a change is expected and legitimate (for instance, you intentionally updated a file), you should update the baseline by re-running the script with the `--init` flag to avoid false alerts in the future.

### Logging

Each time the script runs (whether manually or via cron), it appends the results to a log file (for example, `integrity.log`). The log contains timestamps and details of each run, including which files changed (if any) or a note that no changes were found. This provides an audit trail of file integrity over time. You can check this log periodically to review past integrity checks or to investigate when a change first occurred. Make sure the script has write permission to its log file location. By default, the log file will be created in the same directory as the script (you can change the log file path inside the script if needed).

## Automation with Cron

For continuous monitoring, you can set up a cron job to run the File Integrity Checker automatically at regular intervals. For example, to run the script every 30 minutes, add a cron entry like this:

```bash
*/30 * * * * /path/to/File-Integrity-Checker/file_integrity_checker.sh
``` 

To do this, open your crontab with `crontab -e` and add the above line. Make sure to replace `/path/to/File-Integrity-Checker/file_integrity_checker.sh` with the actual full path to the script on your system. Once added and saved, the cron daemon will execute the script every 30 minutes (at :00 and :30 each hour).

A few things to keep in mind when using cron: 

- **Permissions:** Ensure that the user account running the cron job has permission to read all the files you are monitoring and to write to the log file. If monitoring system files, you might need to run the cron job as root or a privileged user.  
- **Environment:** Cron runs in a limited environment. If your script relies on certain environment variables or paths, you might need to specify them in the script or in the crontab entry. Usually, calling the script by its full path (as above) is sufficient.  
- **Output:** The script's output will be handled by the script's own logging and email features. Cron by default will email any output to the user (if an MTA is configured); to avoid duplicate emails for normal operation, the script is already handling notifications. You can redirect cron output to a file or `/dev/null` if desired. For example:  
  ```bash
  */30 * * * * /path/to/file_integrity_checker.sh >> /path/to/integrity.log 2>&1
  ```  
  But if you're using the script's internal logging, additional redirection is optional.

With cron automation in place, the integrity checker will run in the background at the specified interval, and you will be alerted according to the logging and email settings without needing to run the tool manually each time.

## Email Notifications

A core feature of this tool is its ability to send email alerts when file changes are detected. The script uses the `mail` command (provided by **mailutils**) to send out an email notification whenever it finds a discrepancy. Here's how the email notification works:

- **Triggering an Email:** When a file is added, removed, or modified compared to the baseline (i.e., when the current hash doesn't match the stored hash, or a file's presence has changed), the script will automatically compose an email alert. The email typically includes a list of the files that changed and the time the check was performed.
- **Recipient Configuration:** By default, the email might be sent to the local system user or a placeholder address. You should configure the script to use your desired email address as the recipient for alerts. This is usually done by editing a variable in the script (for example, an `EMAIL` or `TO_ADDRESS` variable at the top of the script). Set this to an address that you check regularly. You can also customize the email subject line in the script (e.g., "File Integrity Alert on [Your System]") for clarity.
- **Mail Setup:** Ensure that your system can actually send out emails. Installing **mailutils** provides the `mail` command, but you may need an SMTP server or a local mail transfer agent (like Postfix or Sendmail) configured on your machine to relay the messages. On many Linux systems, installing mailutils and having a working internet connection is enough for sending basic emails, but if you're not receiving emails, double-check your mail configuration or logs.
- **When Emails Are Sent:** The script is designed to send an email **only** when a change is detected (to avoid spamming you when everything is normal). This means if an integrity check finds no issues, it will log the result but not send an email. If issues are found, you'll get an immediate alert in your inbox describing what was detected. This allows you to take prompt action if an unauthorized or unexpected change occurs.

By setting up email notifications, you can have peace of mind that you'll be alerted in near-real-time to any critical file changes, even if you aren't actively watching the terminal or log file.

## Author

- **Rahmonbek Maqsudov** – ID: 11244, Group: SFW-122
