// Kalibra's service worker: network-first with an offline fallback.
//
// Online, every request goes to the network, so an installed PWA always
// runs the latest deploy (the reason Flutter's own cache-first worker was
// turned off). Each successful response is also copied into a cache, and
// when the network is down or too slow the cached copy is served instead —
// so the app still opens in a supermarket or gym with no signal. Your data
// is not involved: it lives in IndexedDB, never in this cache.
const CACHE = 'kalibra-v1';
const NETWORK_TIMEOUT_MS = 4000;

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      for (const key of await caches.keys()) {
        if (key !== CACHE) await caches.delete(key);
      }
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  // Flutter's engine pulls its own fallback fonts (Roboto, Noto symbols)
  // from here. Their URLs are versioned and never change, so cache-first.
  if (url.host === 'fonts.gstatic.com') {
    event.respondWith(cacheFirst(request));
    return;
  }
  // Everything else the app needs is same-origin (CanvasKit and the brand
  // fonts included).
  if (url.origin !== self.location.origin) return;

  event.respondWith(networkFirst(request));
});

async function cacheFirst(request) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response.ok) cache.put(request, response.clone());
  return response;
}

async function networkFirst(request) {
  const cache = await caches.open(CACHE);
  const network = fetch(request).then((response) => {
    if (response.ok && response.type === 'basic') {
      cache.put(request, response.clone());
    }
    return response;
  });
  // The race below may already have moved on; don't leave a rejection unhandled.
  network.catch(() => {});

  try {
    return await Promise.race([
      network,
      new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), NETWORK_TIMEOUT_MS)),
    ]);
  } catch (_) {
    const cached = await cache.match(request, { ignoreSearch: true });
    if (cached) return cached;
    // Nothing cached yet (first visit while offline): keep waiting on the network.
    return network;
  }
}
