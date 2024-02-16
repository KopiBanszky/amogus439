'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"amogus.png": "0139c9eee385d2b4cc789b5d47e54279",
"assets/AssetManifest.bin": "e5eed341dcb55bbc959b60a3016aea66",
"assets/AssetManifest.bin.json": "cb8a815b5120c5f88bbf1c24f690f81e",
"assets/AssetManifest.json": "bb26473dd073415c98b87a4ed10bf647",
"assets/assets/AND.png": "efeb64937f441356f8971d77aecd3abb",
"assets/assets/background.jpg": "c558c7b95f213d35d16b28e6c48fb00f",
"assets/assets/bg.png": "93d65e53e4f224057237a30ec19dfb00",
"assets/assets/btn.png": "9878111ecaf45bb98ed2004d683d98da",
"assets/assets/caller.png": "8df90b5214c6afe0b29f20fdf8293aec",
"assets/assets/dead.png": "b0465c69b86524e7b609124f34dae63b",
"assets/assets/fonts/DeliciousHandrawn-Regular.ttf": "89d6244aa25566cf8c695f9926b5cb1d",
"assets/assets/impostor.png": "31633c024fe48565eec9b2d5ba7902d2",
"assets/assets/light.png": "4552ec4c06138ca71e3bb7dfab751cae",
"assets/assets/lights.png": "ba29c1d5adcba40302ba0a7efd8d3127",
"assets/assets/NAND.png": "a34c8d3950b237e490fd04724c9dface",
"assets/assets/navigation.png": "5a2790aaacca0619e025542b482deed6",
"assets/assets/NOR.png": "189525d0b1556894399088a23dfbec85",
"assets/assets/OR.png": "52eb04267a4a86b8a711ffe0edce64a2",
"assets/assets/place.png": "b06501d0a79d26604d98dba6dc54bed7",
"assets/assets/player.png": "2759040d9b53b610a8d81d3323d90c79",
"assets/assets/reactor.png": "4c5039c5bc9e0e0ccf7d9da55429f648",
"assets/assets/reporter.png": "67c88da57a00dab979fae2c35d5dce05",
"assets/assets/sabotage.png": "bcd1dc5407fbd6ba8b7b66ced36e3e75",
"assets/assets/switch.png": "2ed83097554bc878b26e9e10b1676603",
"assets/assets/task.png": "3b0b5f9e51949e4ab38a87b4f5ef29a2",
"assets/assets/task2.png": "65638bfb46b2403da60952463f874abe",
"assets/assets/taskicon0.png": "865633c50ff52b4bebee4fb70faf5dc7",
"assets/assets/taskicon1.png": "89a4e3c598628174a954ae199a8a1a6f",
"assets/assets/taskicon12.png": "7eea4373a18aec83e32d57b40efb5d99",
"assets/assets/XNOR.png": "c7f9cc81efeafabab45da9c537b72d36",
"assets/assets/XOR.png": "1bb5d7d8491ac820ece3780996fcecde",
"assets/FontManifest.json": "f8700ac7091b3e1d43415af52df9f644",
"assets/fonts/MaterialIcons-Regular.otf": "9e37756ac910a60191a6e4c92fcc7b67",
"assets/NOTICES": "b0773c88a3ed0ef9556cf072a3f5a4c3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "65403a8cb641c07ec2f48dd99cf033ae",
"flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
"icons/Icon-192.png": "973ce16bcc5af4b79d64962c21f209e7",
"icons/Icon-512.png": "fe30b783ac7d1a423fd2b2049d330c22",
"icons/Icon-maskable-192.png": "973ce16bcc5af4b79d64962c21f209e7",
"icons/Icon-maskable-512.png": "fe30b783ac7d1a423fd2b2049d330c22",
"index.html": "0b5da7020070bddc2ed53f69b4cea746",
"/": "0b5da7020070bddc2ed53f69b4cea746",
"main.dart.js": "43bdc1c7a80fdaae6df720a454f63325",
"manifest.json": "3a0ce58cda5fbdbdc189be03f05620a3",
"version.json": "7617c21c2f6206206d0ee473e36a814a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
