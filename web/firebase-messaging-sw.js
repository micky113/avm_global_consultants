// Standalone Push Service Worker for AVM Global Consultants
// Fast, robust, and 100% compliant with standard Web Push specs

self.addEventListener('install', (event) => {
  console.log('[SW] Service Worker installing, activating immediately...');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[SW] Service Worker activated, claiming clients...');
  event.waitUntil(clients.claim());
});

// Helper to normalize and resolve destination URLs to the current origin
function sanitizeUrl(rawUrl) {
  if (!rawUrl) return self.location.origin + '/jobs';
  try {
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      const parsed = new URL(rawUrl);
      return self.location.origin + parsed.pathname + parsed.search + parsed.hash;
    }
    return new URL(rawUrl, self.location.origin).href;
  } catch (_) {
    return self.location.origin + '/jobs';
  }
}

// Push event listener: Guaranteed to display notification for every push
self.addEventListener('push', (event) => {
  console.log('[SW] Push event received:', event);

  let title = 'Job Alert | AVM Global Consultants';
  let body = 'A new opening matching your search is live now!';
  let targetUrl = self.location.origin + '/jobs';
  let icon = '/icons/Icon-192.png';
  let badge = '/icons/Icon-192.png';
  let tag = 'job-alert';

  if (event.data) {
    try {
      const payload = event.data.json();
      console.log('[SW] Push payload JSON:', payload);

      const notif = payload.notification || {};
      const data = payload.data || {};

      title = notif.title || data.title || data.jobTitle || title;
      body = notif.body || data.body || body;

      const rawUrl = payload.fcmOptions?.link ||
                     data.url ||
                     data.link ||
                     data.click_action ||
                     notif.click_action ||
                     '/jobs';

      targetUrl = sanitizeUrl(rawUrl);

      if (data.jobId) {
        tag = 'job-' + data.jobId;
      }
    } catch (e) {
      console.warn('[SW] Could not parse push data as JSON, falling back to text:', e);
      try {
        const text = event.data.text();
        if (text) body = text;
      } catch (_) {}
    }
  }

  const notificationOptions = {
    body: body,
    icon: icon,
    badge: badge,
    data: {
      url: targetUrl
    },
    tag: tag,
    renotify: true,
    requireInteraction: true
  };

  event.waitUntil(
    self.registration.showNotification(title, notificationOptions)
  );
});

// Notification Click Handler: Navigates to the exact URL
self.addEventListener('notificationclick', (event) => {
  console.log('[SW] notificationclick received:', event);
  event.notification.close();

  if (event.action === 'dismiss') return;

  const data = event.notification?.data || {};
  let rawUrl = data.url ||
               data.link ||
               data.click_action ||
               data.FCM_MSG?.notification?.click_action ||
               data.FCM_MSG?.data?.url ||
               data.FCM_MSG?.data?.link ||
               data.FCM_MSG?.fcmOptions?.link ||
               '/jobs';

  const targetUrl = sanitizeUrl(rawUrl);
  console.log('[SW] Notification clicked, opening targetUrl:', targetUrl);

  event.waitUntil(
    (async () => {
      try {
        const windowClients = await clients.matchAll({
          type: 'window',
          includeUncontrolled: true
        });

        // 1. If an existing tab is open on this origin, navigate it and focus it
        for (const client of windowClients) {
          if (client.url && client.url.startsWith(self.location.origin) && 'focus' in client) {
            try {
              client.postMessage({ type: 'NAVIGATE_TO', url: targetUrl });
            } catch (_) {}
            if ('navigate' in client) {
              await client.navigate(targetUrl);
            }
            return await client.focus();
          }
        }

        // 2. Otherwise open a new tab/window
        if (clients.openWindow) {
          return await clients.openWindow(targetUrl);
        }
      } catch (err) {
        console.warn('[SW] Error focusing/navigating client:', err);
        if (clients.openWindow) {
          return await clients.openWindow(targetUrl);
        }
      }
    })()
  );
});
