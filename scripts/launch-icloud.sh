#!/bin/bash
# Main iCloud Service Launcher
# This script launches iCloud services using Chromium browser

SERVICE="$1"

case "$SERVICE" in
    mail)
        URL=https://www.icloud.com/mail
        WM_CLASS=icloud-mail
        ;;
    contacts)
        URL=https://www.icloud.com/contacts
        WM_CLASS=icloud-contacts
        ;;
    calendar)
        URL=https://www.icloud.com/calendar
        WM_CLASS=icloud-calendar
        ;;
    photos)
        URL=https://www.icloud.com/photos
        WM_CLASS=icloud-photos
        ;;
    drive)
        URL=https://www.icloud.com/iclouddrive
        WM_CLASS=icloud-drive
        ;;
    notes)
        URL=https://www.icloud.com/notes
        WM_CLASS=icloud-notes
        ;;
    reminders)
        URL=https://www.icloud.com/reminders
        WM_CLASS=icloud-reminders
        ;;
    pages)
        URL=https://www.icloud.com/pages
        WM_CLASS=icloud-pages
        ;;
    numbers)
        URL=https://www.icloud.com/numbers
        WM_CLASS=icloud-numbers
        ;;
    keynote)
        URL=https://www.icloud.com/keynote
        WM_CLASS=icloud-keynote
        ;;
    find)
        URL=https://www.icloud.com/find
        WM_CLASS=icloud-find
        ;;
    *)
        echo "Usage: $0 {mail|contacts|calendar|photos|drive|notes|reminders|pages|numbers|keynote|find}"
        exit 1
        ;;
esac

# Launch Chromium in app mode with custom window class and separate profile
# --class flag sets WM_CLASS to match StartupWMClass in desktop files for proper icon matching
# --user-data-dir creates separate profile per service for separate dock icons
# Note: Each service needs its own login (one-time setup per service)
# Chromium must be installed separately: flatpak install flathub org.chromium.Chromium
exec flatpak-spawn --host flatpak run org.chromium.Chromium \
    --class="$WM_CLASS" \
    --user-data-dir="$HOME/.var/app/org.chromium.Chromium/config/icloud-${SERVICE}" \
    --app="$URL"
