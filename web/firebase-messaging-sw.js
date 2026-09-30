// Unified Service Worker for AVM Global Consultants

// In-memory cache to prevent duplicate notifications within short time windows (e.g. rapid FCM bursts)
const recentNotificationCache = new Map();

function shouldDisplayNotification(tag) {
  const now = Date.now();
  // Clean up entries older than 30 seconds
  for (const [key, timestamp] of recentNotificationCache.entries()) {
    if (now - timestamp > 30000) {
      recentNotificationCache.delete(key);
    }
  }

  if (tag && recentNotificationCache.has(tag)) {
    const lastTime = recentNotificationCache.get(tag);
    if (now - lastTime < 10000) {
      console.log('[SW] Suppressed duplicate notification for tag:', tag);
      return false;
    }
  }

  if (tag) {
    recentNotificationCache.set(tag, now);
  }
  return true;
}

// 1. Primary Notification Click Handler - Directly opens the target URL in Chrome
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

  let targetUrl = 'https://avmglobalconsultants.com/jobs';
  try {
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      targetUrl = rawUrl;
    } else {
      targetUrl = new URL(rawUrl, self.location.origin).href;
    }
  } catch (_) {
    targetUrl = 'https://avmglobalconsultants.com/jobs';
  }

  console.log('[SW] Opening target URL on click:', targetUrl);

  event.waitUntil(
    clients.openWindow(targetUrl)
  );
});

// 2. Direct Web Push Listener (Handles all background push events with strict deduplication)
self.addEventListener('push', (event) => {
  console.log('[SW] Direct push event received:', event);

  let title = 'Job Alert | AVM Global Consultants';
  let body = 'A new opening matching your search is live now!';
  let targetUrl = 'https://avmglobalconsultants.com/jobs';
  let iconUrl = self.location.origin + '/icons/Icon-192.png';
  let tag = 'avm_job_alert';

  if (event.data) {
    try {
      const payload = event.data.json();
      console.log('[SW] Push JSON payload:', payload);

      const notif = payload.notification || {};
      const data = payload.data || {};
      const webpushNotif = payload.webpush?.notification || {};

      title = notif.title || data.title || data.jobTitle || title;
      body = notif.body || data.body || body;

      const rawUrl = payload.fcmOptions?.link ||
                     payload.webpush?.fcmOptions?.link ||
                     data.url ||
                     data.link ||
                     data.click_action ||
                     notif.click_action ||
                     '/jobs';

      if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
        targetUrl = rawUrl;
      } else {
        targetUrl = new URL(rawUrl, self.location.origin).href;
      }

      // Unique tag prevents duplicate alerts and collapses multiple messages into one
      tag = webpushNotif.tag ||
            data.tag ||
            (data.jobId ? `job_${data.jobId}` : `alert_${title.replace(/\s+/g, '_').toLowerCase()}`);
    } catch (e) {
      console.warn('[SW] Push parse exception:', e);
      try {
        const text = event.data.text();
        if (text) body = text;
      } catch (_) {}
    }
  }

  // De-duplicate check
  if (!shouldDisplayNotification(tag)) {
    return;
  }

  const notificationOptions = {
    body: body,
    icon: iconUrl,
    badge: iconUrl,
    tag: tag,
    renotify: false,
    data: {
      url: targetUrl
    }
  };

  const showPromise = self.registration.showNotification(title, notificationOptions)
    .catch((err) => {
      console.error('[SW] Primary showNotification failed, trying minimal notification:', err);
      return self.registration.showNotification(title, {
        body: body,
        tag: tag,
        data: { url: targetUrl }
      });
    });

  event.waitUntil(showPromise);
});

// 3. Import Firebase Compat SDKs
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCOztdrT-qeNyAswj5IH6XMVDy7PgXTqIA",
  authDomain: "avmglobal-consultants-113.firebaseapp.com",
  projectId: "avmglobal-consultants-113",
  storageBucket: "avmglobal-consultants-113.firebasestorage.app",
  messagingSenderId: "650421354673",
  appId: "1:650421354673:web:5d6ccc5d8ed821000fa290",
  measurementId: "G-HE4YBL8GCQ"
});

const messaging = firebase.messaging();

self.addEventListener('install', (event) => {
  console.log('[SW] Service Worker installing, activating immediately...');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[SW] Service Worker activated, claiming clients...');
  event.waitUntil(clients.claim());
});

// 4. Background Message Handler for Firebase SDK (No-op logging as raw push handler handles display safely)
messaging.onBackgroundMessage((payload) => {
  console.log('[SW] onBackgroundMessage logged:', payload);
});
