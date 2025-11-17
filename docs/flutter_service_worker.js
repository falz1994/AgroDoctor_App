'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "fb112133b7173d1b7d00cf07ab6d81c3",
"assets/AssetManifest.bin.json": "55eefd8075b2078903f39d32bb0db92c",
"assets/AssetManifest.json": "74d4ed8fab0f197ff596705ae91c6a63",
"assets/assets/bilwi1.jpg": "8add6deeee8a91d6c2865db7fef34407",
"assets/assets/bilwi2.jpg": "a6de5a3f7fa1660fb15bc58092d1d236",
"assets/assets/bilwi3.jpg": "bc1f928ccdc54e2029be27e3a0c81215",
"assets/assets/centroamerica.json": "a9a864e986b248506260b85c226af1fc",
"assets/assets/esteli1.jpg": "a0654c9dc77468feb15522fc8bdb3ba1",
"assets/assets/esteli2.jpg": "951131b9c1d007ff2ede24b656ac8667",
"assets/assets/esteli3.jpg": "4d16584f51b3ddf4edadf8abbf2502d9",
"assets/assets/esteli4.jpg": "d653128918d0b398d261a0a796f8b7f9",
"assets/assets/gadm41_NIC_2.json": "cb363cd1c5a279ac81559894235dd797",
"assets/assets/google_logo.png": "4fff0b13826e8c0e38863d9914240792",
"assets/assets/granada1.jpeg": "74ad090e1e787919c82214a811168e27",
"assets/assets/granada2.jpeg": "acb9b36b50bfdbbf606856601ecac19e",
"assets/assets/granada3.png": "8abe1cf8a4604ed43747d63200cb1ee7",
"assets/assets/h1.jpg": "ef016a95cf48bdab349d3447f1b87d0c",
"assets/assets/h2.jpg": "d5c966bfbc2922ddbd677686294bf5be",
"assets/assets/h3.jpg": "ff4793b538bee9327c1e2400684c5fae",
"assets/assets/heroes1.jpg": "c21d26d8875ef644ecb81773c4c42c22",
"assets/assets/heroes2.jpg": "6a6c89a7e1f28e02501e39daf066b5de",
"assets/assets/heroes3.jpg": "bc9ad70c0b4a5c235ff648fd5651e444",
"assets/assets/index.html": "1bd5c1783555dc2e3eb26bb768b71e5f",
"assets/assets/logo.png": "3af439934ef390aaeaa05bbe92526d26",
"assets/assets/mapa_hospitales_nicaragua.html": "a30f44ae9703952b6d8f960839df8452",
"assets/assets/models/class_names.txt": "73c8a5c4a47e2d4d9b710a658b15458b",
"assets/assets/models/model_mobilenetv3_large_dynamic.tflite": "0773c494bce24f70b7e9f1e954096d4d",
"assets/assets/sanrafa1.jpeg": "2fd664135f04158418af49a568d319e6",
"assets/assets/sanrafa2.jpeg": "84fc64e9eb273b4561df679b2f68026f",
"assets/assets/sanrafa3.jpeg": "84670f8d4b77ccca2b1ff925342cb9fe",
"assets/assets/waslala1.jpg": "ae1ec5a0c2c1bf419cc904cb69c149d9",
"assets/assets/waslala2.jpg": "04703c8d08df0e1cc24ef60517cd7637",
"assets/assets/waslala3.jpg": "08560632f2b31796ae0014977f81ea9e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "bbbaecf17b422d4e2333b61f2523aae3",
"assets/NOTICES": "e2c4cc192537b53b488cc06252fbe0a5",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"CORS": "d3c8a5c4e3bdca7ecd513e1b24ac6511",
"favicon.png": "8d4414bf1fa687c948625b717d34537a",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "035a1f13a4688ac73dc503b1f7b35321",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "e99180f494f7c3e7be9fb5d14f4ab55a",
"/": "e99180f494f7c3e7be9fb5d14f4ab55a",
"index.html.bak": "3d8c74e9f6540f9f20c35667cf08060d",
"main.dart.js": "cf0ffde87b090e263b41e91795f3bb33",
"manifest.json": "bf24c84c3bf99672a631c4f84464e793",
"version.json": "15235b5108d6a877ef74fe3317a96bf7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
  for (var resourceKey of Object.keys(RESOURCES)) {
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
