// Kalibra's service worker: network-first with an offline fallback.
//
// Online, the app's own code goes to the network, so an installed PWA
// always runs the latest deploy (the reason Flutter's own cache-first worker
// was turned off). Each successful response is also copied into a cache, and
// when the network is down or too slow the cached copy is served instead —
// so the app still opens in a supermarket or gym with no signal. Your data
// is not involved: it lives in IndexedDB, never in this cache.
//
// The Flutter engine (CanvasKit, ~3 MB compressed — the bulk of every cold
// start) is the exception: it's cache-first, since it only changes when the
// Flutter version does. flutter_bootstrap.js, which always loads before it,
// names the engine revision the build expects; when that changes the engine
// cache is emptied, so a new build never runs on an old engine.
//
// Every cache call is best effort: if the browser's cache storage is
// unavailable or broken (private mode, corrupted profile, quota), requests
// fall through to the plain network instead of failing the app's load.
const CACHE = 'kalibra-v1';
const ENGINE_CACHE = 'kalibra-engine';
const ENGINE_REVISION_KEY = '__engine-revision__';
const NETWORK_TIMEOUT_MS = 4000;

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      try {
        for (const key of await caches.keys()) {
          if (key !== CACHE && key !== ENGINE_CACHE) await caches.delete(key);
        }
        // Engine files cached network-first by the previous version of this
        // worker now live in ENGINE_CACHE; drop the stale copies.
        const cache = await caches.open(CACHE);
        for (const request of await cache.keys()) {
          if (isEngineFile(new URL(request.url))) await cache.delete(request);
        }
      } catch (_) {
        // Cache storage unavailable: nothing to clean up.
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
    event.respondWith(cacheFirst(CACHE, request));
    return;
  }
  // Everything else the app needs is same-origin (CanvasKit and the brand
  // fonts included).
  if (url.origin !== self.location.origin) return;

  if (isEngineFile(url)) {
    event.respondWith(cacheFirst(ENGINE_CACHE, request));
    return;
  }
  event.respondWith(networkFirst(request, url));
});

function isEngineFile(url) {
  return url.pathname.includes('/canvaskit/');
}

async function openCache(name) {
  try {
    return await caches.open(name);
  } catch (_) {
    return null;
  }
}

async function cachedResponse(cache, request) {
  if (!cache) return undefined;
  try {
    return await cache.match(request, { ignoreSearch: true });
  } catch (_) {
    return undefined;
  }
}

function store(cache, request, response) {
  if (!cache || !response.ok || response.type !== 'basic') return;
  cache.put(request, response.clone()).catch(() => {});
}

async function cacheFirst(cacheName, request) {
  const cache = await openCache(cacheName);
  const cached = await cachedResponse(cache, request);
  if (cached) return cached;
  const response = await fetch(request);
  // fonts.gstatic.com responses are CORS ("cors" type), not "basic".
  if (cache && response.ok) cache.put(request, response.clone()).catch(() => {});
  return response;
}

// Empties the engine cache when the build just fetched expects a different
// engine than the one cached.
async function syncEngineRevision(bootstrapResponse) {
  const match = /"engineRevision"\s*:\s*"([0-9a-f]+)"/.exec(await bootstrapResponse.text());
  if (!match) return;
  const engine = await openCache(ENGINE_CACHE);
  if (!engine) return;
  const stored = await cachedResponse(engine, ENGINE_REVISION_KEY);
  if (stored && (await stored.text()) === match[1]) return;
  try {
    await caches.delete(ENGINE_CACHE);
    const fresh = await caches.open(ENGINE_CACHE);
    await fresh.put(ENGINE_REVISION_KEY, new Response(match[1]));
  } catch (_) {
    // Best effort: worst case the engine is refetched from the network.
  }
}

async function networkFirst(request, url) {
  const cache = await openCache(CACHE);
  const network = fetch(request).then(async (response) => {
    if (response.ok && response.type === 'basic' && url.pathname.endsWith('/flutter_bootstrap.js')) {
      // Awaited before the page gets the script, so the stale engine is gone
      // before the page asks for it.
      await syncEngineRevision(response.clone()).catch(() => {});
    }
    store(cache, request, response);
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
    const cached = await cachedResponse(cache, request);
    if (cached) return cached;
    // Nothing cached (first visit while offline, or no cache storage): keep
    // waiting on the network.
    return network;
  }
}
