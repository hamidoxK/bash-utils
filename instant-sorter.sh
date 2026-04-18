#!/bin/bash

# --- HARDCODED DESKTOP PRIVILEGES ---
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

# ==========================================
# Instant Sorter - Automated Downloads Organizer
# ==========================================

# --- CONFIGURATION ---
TARGET="$HOME/Downloads"
LOG="$HOME/.instant-sorter.log"

# Setup base structure safely (Removed Torrents/Watch, kept Torrents)
mkdir -p "$TARGET"/{Images,Videos,Audio,Archives,Others,Software,Torrents,Documents/{PDF,EPUB}}
touch "$LOG"

organize_file() {
    local src="$1"

    # --- RECURSIVE SAFETY GATE ---
    # Only sort files sitting directly in Downloads.
    # Ignore anything inside sub-folders (like extracted ZIP contents).
    local parent_dir
    parent_dir=$(dirname "$src")
    if [[ "$parent_dir" != "$TARGET" ]]; then
        return
    fi

   # --- RULE 2, 4 & 6: STRICT SAFETY LOCKS ---
    [[ ! -f "$src" ]] && return                       # Ignore directories or deleted files
    [[ "$src" != "$TARGET"* ]] && return              # Rule 4: Out-of-bounds immunity

    local filename
    filename=$(basename "$src")
    [[ "$filename" =~ ^\. ]] && return                # Ignore hidden files (.cache, etc.)

    # --- TORRENT I/O FIX ---
    # Ignore browser & torrent temporary files mid-download (!qB and aria2 added)
    [[ "$filename" =~ \.(crdownload|part|download|tmp|opdownload|!qB|aria2)$ ]] && return

    local name="${filename%.*}"                       # Filename strictly without extension
    local category_dir=""

    # --- RULE 5: ASSIGN CATEGORY (Updated for .iso and .torrent) ---
    case "${filename,,}" in
        *.jpg|*.jpeg|*.png|*.gif|*.webp|*.svg|*.ico) category_dir="$TARGET/Images" ;;
        *.mp4|*.mkv|*.avi|*.mov|*.webm)              category_dir="$TARGET/Videos" ;;
        *.mp3|*.wav|*.flac|*.m4a|*.opus)             category_dir="$TARGET/Audio" ;;
        *.zip|*.rar|*.7z|*.tar|*.gz|*.bz2|*.xz|*.tgz|*.z[0-9]*|*.r[0-9]*) category_dir="$TARGET/Archives" ;;
        *.iso|*.deb|*.appimage|*.msi|*.exe|*.rpm)    category_dir="$TARGET/Software" ;; # .iso is now here!
        *.pdf)                                       category_dir="$TARGET/Documents/PDF" ;;
        *.epub)                                      category_dir="$TARGET/Documents/EPUB" ;;
        *.doc|*.docx|*.txt|*.xls|*.xlsx|*.ppt|*.csv) category_dir="$TARGET/Documents" ;;
        *.torrent)                                   category_dir="$TARGET/Torrents" ;; # No more Watch folder!
        *)                                           category_dir="$TARGET/Others" ;;
    esac

    local final_dest=""

    # --- RULE 3: SMART GROUPING (The Partner Rule) ---
    # Exception: Do not group images OR torrents
    if [[ "$category_dir" == "$TARGET/Images" || "$category_dir" == "$TARGET/Torrents" ]]; then
        final_dest="$category_dir/$filename"
    else
        local family
        # Strip trailing numbers/separators (e.g., File_1 -> File)
        family=$(echo "$name" | sed -E 's/[-_ ]+[0-9]+$//')

        # Safety Net: If stripping removed the whole name, revert to original name
        [[ -z "$family" ]] && family="$name"

        local group_folder="$category_dir/$family"

        if [[ -d "$group_folder" ]]; then
            # Rule 3: Group folder exists; join the family.
            final_dest="$group_folder/$filename"
        else
            # Rule 3: Check for siblings using secure null-terminated pipelines
            local siblings=()
            while IFS= read -r -d '' sib; do
                siblings+=("$sib")
            done < <(find "$category_dir" -maxdepth 1 -type f -name "${family}*" ! -name "$filename" -print0 2>/dev/null | head -z -n 1)

            if [[ ${#siblings[@]} -gt 0 ]]; then
                # Sibling found! Create folder and move the sibling(s)
                mkdir -p "$group_folder"
                find "$category_dir" -maxdepth 1 -type f -name "${family}*" -exec mv -t "$group_folder/" {} + 2>/dev/null
                final_dest="$group_folder/$filename"
            else
                # No siblings yet, stay in the main category folder
                final_dest="$category_dir/$filename"
            fi
        fi
    fi

    # --- EXECUTE & ANTI-OVERWRITE (THE LOOP KILLER) ---
    # This specifically stops the notification spam. It ONLY acts if the file is in the wrong place.
    if [[ "$src" != "$final_dest" ]]; then

        # Prevent overwriting existing files
        if [[ -f "$final_dest" ]]; then
            local dest_dir="$(dirname "$final_dest")"
            local f_ext="${filename##*.}"
            local f_base="${filename%.*}"
            local counter=1

            # Handle files with no extension
            if [[ "$filename" == "$f_base" ]]; then
                while [[ -f "$dest_dir/${f_base}_${counter}" ]]; do
                    ((counter++))
                done
                final_dest="$dest_dir/${f_base}_${counter}"
            else
                # Handle standard files with extensions
                while [[ -f "$dest_dir/${f_base}_${counter}.${f_ext}" ]]; do
                    ((counter++))
                done
                final_dest="$dest_dir/${f_base}_${counter}.${f_ext}"
            fi

            filename="$(basename "$final_dest")"
        fi

        # Last-second safeguard: Ensure destination path actually exists
        mkdir -p "$(dirname "$final_dest")"

        # MOVE THE FILE
        if mv "$src" "$final_dest" 2>/dev/null; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Organized: $(basename "$src") -> $final_dest" >> "$LOG"

            # FEATURE 1: Desktop Notification
            notify-send -i folder "Instant Sorter" "Moved: $(basename "$src")\nTo: $(basename "$(dirname "$final_dest")")" 2>/dev/null

            # FEATURE 5: Auto-extract ZIP files and trash the original
            if [[ "$final_dest" == *.zip ]]; then
                local extract_dir="${final_dest%.*}"
                mkdir -p "$extract_dir"
                if unzip -q "$final_dest" -d "$extract_dir" 2>/dev/null; then
                    rm "$final_dest"
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Extracted & Cleaned: $(basename "$final_dest")" >> "$LOG"
                    notify-send -i archive-extract "Instant Sorter" "Extracted: $(basename "$final_dest")" 2>/dev/null
                fi
            fi
        fi
    fi
}

# --- RULE 1: STARTUP SWEEP ---
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running Startup Sweep..." >> "$LOG"

# Updated to remove the Torrents/Watch folder
CHECK_DIRS=(
    "$TARGET"
    "$TARGET/Images"
    "$TARGET/Videos"
    "$TARGET/Audio"
    "$TARGET/Archives"
    "$TARGET/Others"
    "$TARGET/Software"
    "$TARGET/Documents"
    "$TARGET/Documents/PDF"
    "$TARGET/Documents/EPUB"
    "$TARGET/Torrents"
)

for d in "${CHECK_DIRS[@]}"; do
    if [[ -d "$d" ]]; then
        find "$d" -maxdepth 1 -type f -print0 2>/dev/null | while IFS= read -r -d '' f; do
            organize_file "$f"
        done
    fi
done

# --- LIVE MONITOR ---
/usr/bin/inotifywait -m -r -e close_write,moved_to --format "%w%f" "$TARGET" 2>/dev/null | \
while IFS= read -r detected; do
    sleep 0.5
    organize_file "$detected"
done
