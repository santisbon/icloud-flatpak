#!/bin/bash
# Main iCloud Service Launcher
# This script launches iCloud services using Epiphany browser

SERVICE="$1"

case "$SERVICE" in
    mail)
        URL="https://www.icloud.com/mail"
        ;;
    contacts)
        URL="https://www.icloud.com/contacts"
        ;;
    calendar)
        URL="https://www.icloud.com/calendar"
        ;;
    photos)
        URL="https://www.icloud.com/photos"
        ;;
    drive)
        URL="https://www.icloud.com/iclouddrive"
        ;;
    notes)
        URL="https://www.icloud.com/notes"
        ;;
    reminders)
        URL="https://www.icloud.com/reminders"
        ;;
    pages)
        URL="https://www.icloud.com/pages"
        ;;
    numbers)
        URL="https://www.icloud.com/numbers"
        ;;
    keynote)
        URL="https://www.icloud.com/keynote"
        ;;
    find)
        URL="https://www.icloud.com/find"
        ;;
    *)
        echo "Usage: $0 {mail|contacts|calendar|photos|drive|notes|reminders|pages|numbers|keynote|find}"
        exit 1
        ;;
esac

# Launch Epiphany with the specific iCloud URL
# Using app mode for a more native feel
# Epiphany must be installed separately: flatpak install flathub org.gnome.Epiphany
# All services share ONE profile so you only log in once
exec flatpak run --command=epiphany org.gnome.Epiphany \
    --application-mode \
    --profile="$HOME/.var/app/me.santisbon.iCloudServices/data/icloud" \
    "$URL"
