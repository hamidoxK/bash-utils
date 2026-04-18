Instant Sorter
Automated Downloads Organizer
Instant Sorter is a lightweight Bash script for Linux.
It monitors your Downloads folder in real-time.
It sorts files into folders and groups related files together.

🛠️ Required Tools
You need to install two small tools for this to work.
Choose the command for your Linux version:

For Mint, Ubuntu, or Debian:

Bash
sudo apt update
sudo apt install inotify-tools libnotify-bin
For Fedora:

Bash
sudo dnf install inotify-tools libnotify
For Arch Linux:

Bash
sudo pacman -S inotify-tools libnotify
🚀 How to Setup
1. Prepare the Script
Move your script to a folder and make it "runnable":

Bash
mkdir -p ~/My_bash_scripts
# Move your file into that folder, then run:
chmod +x ~/My_bash_scripts/instant-sorter.sh
2. Make it Start Automatically
Create a "service" so it runs in the background:

Run: mkdir -p ~/.config/systemd/user

Run: nano ~/.config/systemd/user/instant-sorter.service

Paste this short block inside:

Ini, TOML
[Unit]
Description=Instant Sorter
After=default.target

[Service]
Type=simple
ExecStart=/bin/bash %h/My_bash_scripts/instant-sorter.sh
Restart=always

[Install]
WantedBy=default.target
3. Start the Sorter
Run these 3 commands one by one:

Bash
systemctl --user daemon-reload
systemctl --user enable instant-sorter.service
systemctl --user start instant-sorter.service
📂 Where do files go?
The script creates these folders in your Downloads:

Images: Photos and icons

Videos: Movies and clips

Audio: Music and sounds

Archives: Zip and Rar files

Software: AppImages, Debs, and Exe

Documents: PDF, EPUB, and Text

Torrents: .torrent files

📝 Check the Logs
If you want to see what the script is doing:

Bash
tail -f ~/.instant-sorter.log
