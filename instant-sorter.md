📂 Instant SorterReal-time Smart Organizer for LinuxA standalone Bash utility that monitors your Downloads directory and organizes files instantly using the Linux kernel's inotify API.🛠️ System RequirementsTo use this script, your system must have:inotify-tools: To watch file events.libnotify: To send desktop alerts.Bash 4.0+: To run the logic.🚀 Quick StartPermissions: Make the script executable:chmod +x instant-sorter.shManual Run: Start it in the background:./instant-sorter.sh &Check Logs: Monitor actions in real-time:tail -f ~/.instant-sorter.log🧠 Smart Logic RulesThe script follows these strict rules to ensure your data is safe:RuleActionSafetyIgnores hidden files and active .part or !qB downloads.GroupingDetects "siblings" (e.g., Part1, Part2) and moves them to a shared folder.ConflictNever overwrites. If a file exists, it appends _1, _2 to the name.UniversalUses $HOME and $(id -u) to work on any user account.⚙️ Universal Autostart (Systemd)To run this script on boot, create a service file at:~/.config/systemd/user/instant-sorter.servicePaste this template:Ini, TOML[Unit]
Description=Instant Sorter
After=default.target

[Service]
Type=simple
# Replace /FULL/PATH/TO/ with the folder where you saved the script
ExecStart=/bin/bash /FULL/PATH/TO/instant-sorter.sh
Restart=always

[Install]
WantedBy=default.target
Then enable it:Bashsystemctl --user daemon-reload
systemctl --user enable --now instant-sorter.service
📂 Category MapFiles are sorted into these default categories:Images: Photos, icons, and vectors.Videos: Movies and screen recordings.Audio: Music and voice clips.Archives: Zips, Tarballs, and ISOs.Software: AppImages, Debs, and Exe files.Documents: PDFs, Epubs, and Office files.Torrents: Native .torrent file support.
