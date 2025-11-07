#!/bin/bash
# Main iCloud Service Launcher
# This script launches iCloud services using Epiphany browser

SERVICE="$1"
APPID="me.santisbon.iCloudServices"

case "$SERVICE" in
    mail)
        URL="https://www.icloud.com/mail"
        TITLE="iCloud Mail"
        ;;
    drive)
        URL="https://www.icloud.com/iclouddrive"
        TITLE="iCloud Drive"
        ;;
    calendar)
        URL="https://www.icloud.com/calendar"
        TITLE="iCloud Calendar"
        ;;
    contacts)
        URL="https://www.icloud.com/contacts"
        TITLE="iCloud Contacts"
        ;;
    photos)
        URL="https://www.icloud.com/photos"
        TITLE="iCloud Photos"
        ;;
    notes)
        URL="https://www.icloud.com/notes"
        TITLE="iCloud Notes"
        ;;
    reminders)
        URL="https://www.icloud.com/reminders"
        TITLE="iCloud Reminders"
        ;;
    find)
        URL="https://www.icloud.com/find"
        TITLE="iCloud Find My"
        ;;
    *)
        echo "Usage: $0 {mail|drive|calendar|contacts|photos|notes|reminders|find}"
        exit 1
        ;;
esac

# Launch Epiphany with the specific iCloud URL
# Using app mode for a more native feel
flatpak run --command=epiphany org.gnome.Epiphany \
    --application-mode \
    --profile="$HOME/.var/app/$APPID/icloud-$SERVICE" \
    "$URL"
