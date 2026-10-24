// Offline support for the installed web app (iPad). Not used inside the Android app.
// Bump VERSION whenever app files change so devices pick up the new version.
const VERSION = "stitch-tally-3";
const APP_FILES = ["./", "./index.html", "./manifest.webmanifest", "./icons/apple-touch-icon.png", "./icons/icon-192.png", "./icons/icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(APP_FILES)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin === location.origin) {
    // App page: try the network first so updates arrive, fall back to the cache offline.
    if (req.mode === "navigate") {
      e.respondWith(
        fetch(req).then(res => {
          const copy = res.clone();
          caches.open(VERSION).then(c => c.put("./index.html", copy));
          return res;
        }).catch(() => caches.match("./index.html"))
      );
      return;
    }
    e.respondWith(caches.match(req).then(hit => hit || fetch(req)));
    return;
  }
  // Google Fonts: keep a copy so the fonts also work offline.
  if (url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com") {
    e.respondWith(
      caches.open(VERSION + "-fonts").then(c => c.match(req).then(hit => hit || fetch(req).then(res => {
        c.put(req, res.clone());
        return res;
      })))
    );
  }
});
