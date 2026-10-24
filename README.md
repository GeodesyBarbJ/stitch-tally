# Stitch Tally

A knitting row counter for Android and iPad: projects, a tap-anywhere row counter, linked and
repeating counters, a knitting timer with a session log, and pattern notes. On Android the volume
buttons count rows; on iPad a keyboard or Bluetooth page-turner pedal can (Space or arrow keys).

## Install on your phone (Android)

1. Get `StitchTally.apk` onto the phone: by USB cable, or put it in a cloud drive (Proton Drive,
   OneDrive, Google Drive…) and open it from that drive's app on the phone.
2. Tap the file. Android asks to allow installing apps from that source (Files, or the drive's
   app): allow it.
3. Tap **Install**. Play Protect may warn that it does not know the app; choose **Install anyway**.

## Install on the iPad

1. Open **https://geodesybarbj.github.io/stitch-tally/** in **Safari**.
2. Tap **Share**, then **Add to Home Screen**.
3. Open Stitch Tally from the Home Screen icon. It works offline after the first visit.

## Syncing between phone and iPad

Each device keeps its own copy of your projects. To move them across, use any folder both
devices can reach, such as a cloud drive (Proton Drive, OneDrive, Google Drive…):

1. On the device you knitted on, tap **Save sync file** and save it to the shared folder.
   On iPad, choose **Save to Files** in the share sheet and pick the folder there.
2. On the other device, tap **Load sync file** and pick the newest file from the shared folder.

If your drive does not show up in the save or open dialog, save the file on the device first
(Downloads on Android, "On My iPad" on iPad) and upload it with the drive's own app. On the other
device, download it with the drive's app, then load it from there.

Loading keeps the newest version of each project and also applies deletions. A good habit:
load before you start knitting on a device, save when you put it down. The home screen shows
when you last saved and loaded. File names include the date and time, so the newest is easy to
spot; old sync files can be deleted at any time.

Uninstalling the Android app or removing the iPad Home Screen app deletes the projects on that
device, so keep a recent sync file.

## Project layout

- `app/`: the app page shared by the Android app and the iPad web app (`index.html`, offline
  support in `sw.js`, `manifest.webmanifest`, `icons/`).
- `android/`: the Android wrapper. `src/` holds the native part.
- `web/stitch-tally.html`: the earlier web version, published on claude.ai.
- `tools/serve.ps1`: serves a folder on http://localhost for testing in a browser.
- `tools/make-icons.ps1`: redraws the web app icons.
- `BACKLOG.md`: bugs and wishes to work on.

## Rebuilding after changes

```powershell
& .\android\build.ps1 -VersionCode 4 -VersionName 1.3
```

Raise `-VersionCode` each time so the phone accepts it as an update, and tag the release in git
(`git tag v1.3`) so you can tell which code is on the phone. When `app/` changes, also raise
`VERSION` in `app/sw.js` so the iPad picks up the new version.

Pushing to `main` on GitHub publishes `app/` to the iPad address automatically
(`.github/workflows/pages.yml`). The iPad loads the new version the next time Stitch Tally is
opened with an internet connection.

Keep `android/stitchtally.keystore` and `android/keystore.properties`: updates must be signed with
the same key, or Android refuses to install them over the existing app. Git ignores both files on
purpose (they are your private signing key), so back them up yourself.
