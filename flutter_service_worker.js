'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "manifestNew.json": "c9bbb8c78423a757c5d24ea7624d301f",
"icons/ms-icon-310x310.png": "ef49c69396a3682fa0f3552fe0a62295",
"icons/ms-icon-144x144.png": "03cb6a464b9de3884a9588650ad19069",
"icons/apple-icon-57x57.png": "44f25c31839f92248f60283eb77300f0",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/ms-icon-70x70.png": "55eed5f8c3fccbb2672d195476f0f4fd",
"icons/apple-icon-60x60.png": "61e2866e801bdf32812f02ca564f9967",
"icons/ms-icon-150x150.png": "9428fc29ae1fa4203a9b2ad91d636a7d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/logo.png": "4b97c18135696f758ff3aee979f868a0",
"icons/favicon.ico": "08822f987fbdfd71899a65a52396a665",
"icons/favicon-32x32.png": "afdb03f64703e64549130cb7e6d05571",
"icons/android-icon-36x36.png": "c8c1a9501a578189511b62e79b10cdd2",
"icons/apple-icon-76x76.png": "9fca8b9369f7f3ad24f0587627887679",
"icons/apple-icon-114x114.png": "fc8c1355ebab8976c784ff3ee339a8e2",
"icons/favicon-16x16.png": "946e900f62cf26ffc4175c1836a05c8b",
"icons/apple-icon-152x152.png": "f5c0f3670c7275593168804379b6efe6",
"icons/android-icon-72x72.png": "6897cc4c9449ec5e16d500fa116ba27d",
"icons/favicon-96x96.png": "ddc95cea97d7935d55f001530eb58217",
"icons/android-icon-96x96.png": "ddc95cea97d7935d55f001530eb58217",
"icons/apple-icon-120x120.png": "ca03c14cb6a2bea906c4d40e9ed1bf7e",
"icons/apple-icon.png": "40a725fc3a5c94cd633357e1be3b2983",
"icons/apple-icon-72x72.png": "6897cc4c9449ec5e16d500fa116ba27d",
"icons/apple-icon-precomposed.png": "40a725fc3a5c94cd633357e1be3b2983",
"icons/maskable_icon.png": "2aa317aa071e7f177e3ad4d17550260f",
"icons/apple-icon-180x180.png": "36f0c06bc3c0426768ae6928cc6bfb76",
"icons/android-icon-48x48.png": "ccf3c09abeb056bc026bc72f5ae06ee6",
"icons/android-icon-144x144.png": "03cb6a464b9de3884a9588650ad19069",
"icons/apple-icon-144x144.png": "03cb6a464b9de3884a9588650ad19069",
"icons/android-icon-192x192.png": "a56213619e01ceed53e250fea8a621b6",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"manifest.json": "866423ca399670ddabf78f2b481b8164",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/NOTICES": "55345b9f5ad847fe515a4a1c6f2cb8fa",
"assets/assets/logo.png": "4b97c18135696f758ff3aee979f868a0",
"assets/assets/bg.jpg": "0d324ef2fb8f18bb182b8d87f9fe9fa5",
"assets/AssetManifest.json": "cc0f6691475f6f3a49ebcae21eafe059",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"index.html": "926c68d6c57ad88840fb48093330e20d",
"/": "926c68d6c57ad88840fb48093330e20d",
"manifestOld.json": "c885216032e1339f3a784d5b4c04d441",
"version.json": "48a7e5be1d2de4d49df45f9555c4eea3",
"main.dart.js": "38468b8ef12f9f2f6cb21695cfab4dc5",
"manifestOldOld.json": "20a337711a02d3ae22eab71882a7c504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
