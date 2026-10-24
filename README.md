# Stitch Tally

A knitting row counter for Android: projects, a tap-anywhere row counter, linked and repeating
counters, volume-button counting, a knitting timer with a session log, and pattern notes.

## Install on your phone

1. Copy `StitchTally.apk` to the phone (USB cable, or open it from OneDrive on the phone).
2. Tap the file. Android asks to allow installing apps from that source (Files, OneDrive…): allow it.
3. Tap **Install**. Play Protect may warn that it does not know the app; choose **Install anyway**.

## Your data

Projects are stored inside the app on the phone. Use **Save backup** on the home screen now and then.
Uninstalling the app or clearing its storage deletes your projects.

## Project layout

- `android/`: the Android app. `assets/index.html` is the app's page, `src/` the native part.
- `web/stitch-tally.html`: the earlier web version, published on claude.ai.
- `tools/serve.ps1`: serves the app page on http://localhost:8765 for testing in a browser.
- `BACKLOG.md`: bugs and wishes to work on.

## Rebuilding after changes

The app page is `android/assets/index.html`; the native part is `android/src/.../MainActivity.java`.

```powershell
& .\android\build.ps1 -VersionCode 2 -VersionName 1.1
```

Raise `-VersionCode` each time so the phone accepts it as an update, and tag the release in git
(`git tag v1.1`) so you can tell which code is on the phone. Keep
`android/stitchtally.keystore` and `android/keystore.properties`: updates must be signed with the
same key, or Android refuses to install them over the existing app. Git ignores both files on
purpose (they are your private signing key), so back them up yourself.
