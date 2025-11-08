#!/bin/bash
# Main iCloud Service Launcher
# This script launches iCloud services using Epiphany browser in application mode

SERVICE="$1"

case "$SERVICE" in
    mail)
        URL=https://www.icloud.com/mail
        DESKTOP=Mail.desktop
        ;;
    contacts)
        URL=https://www.icloud.com/contacts
        DESKTOP=Contacts.desktop
        ;;
    calendar)
        URL=https://www.icloud.com/calendar
        DESKTOP=Calendar.desktop
        ;;
    photos)
        URL=https://www.icloud.com/photos
        DESKTOP=Photos.desktop
        ;;
    drive)
        URL=https://www.icloud.com/iclouddrive
        DESKTOP=Drive.desktop
        ;;
    notes)
        URL=https://www.icloud.com/notes
        DESKTOP=Notes.desktop
        ;;
    reminders)
        URL=https://www.icloud.com/reminders
        DESKTOP=Reminders.desktop
        ;;
    pages)
        URL=https://www.icloud.com/pages
        DESKTOP=Pages.desktop
        ;;
    numbers)
        URL=https://www.icloud.com/numbers
        DESKTOP=Numbers.desktop
        ;;
    keynote)
        URL=https://www.icloud.com/keynote
        DESKTOP=Keynote.desktop
        ;;
    find)
        URL=https://www.icloud.com/find
        DESKTOP=Find.desktop
        ;;
    *)
        echo "Usage: $0 {mail|contacts|calendar|photos|drive|notes|reminders|pages|numbers|keynote|find}"
        exit 1
        ;;
esac

# Launch Epiphany in application mode using the host system's epiphany
# This avoids sandboxing conflicts by running epiphany outside the flatpak sandbox
# Note: Requires epiphany-browser to be installed on the host system
exec flatpak-spawn --host epiphany --application-mode="$DESKTOP" "$URL"
