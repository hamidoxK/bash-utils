Instant Sorter
Real-time Smart Organizer for Linux
A standalone Bash utility that monitors your Downloads directory and organizes files instantly using the Linux kernel inotify API.

System Requirements
To use this script, your system must have:

inotify-tools: To watch file events.

libnotify: To send desktop alerts.

Bash 4.0+: To run the logic.

Quick Start
Permissions:
Make the script executable:

chmod +x instant-sorter.sh

Manual Run:
Start it in the background:

./instant-sorter.sh &

Check Logs:
Monitor actions in real-time:

tail -f ~/.instant-sorter.log

Smart Logic Rules
Safety: Ignores hidden files and active .part or !qB downloads.

Grouping: Detects "siblings" (Part1, Part2) and moves them to a shared folder.

Conflict: Never overwrites. If a file exists, it appends _1, _2 to the name.

Universal: Uses $HOME and $(id -u) to work on any user account.

Universal Autostart (Systemd)
To run this script on boot, create a service file at:

~/.config/systemd/user/instant-sorter.service

Paste this template:

Ini, TOML
[Unit]
Description=Instant Sorter
After=default.target

[Service]
Type=simple
ExecStart=/bin/bash /FULL/PATH/TO/instant-sorter.sh
Restart=always

[Install]
WantedBy=default.target
Then enable it:

systemctl --user daemon-reload

systemctl --user enable --now instant-sorter.service

Category Map
Images: Photos, icons, and vectors.

Videos: Movies and screen recordings.

Audio: Music and voice clips.

Archives: Zips, Tarballs, and ISOs.

Software: AppImages, Debs, and Exe files.

Documents: PDFs, Epubs, and Office files.

Torrents: Native .torrent file support.
