// firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.3.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.3.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyDRpS6PWIJE6kk0YoPlXSgGKQePdt-6GEQ",
  authDomain: "cafeteria2024-b355c.firebaseapp.com",
  projectId: "cafeteria2024-b355c",
  storageBucket: "cafeteria2024-b355c.appspot.com",
  messagingSenderId: "419688568194",
  appId: "1:419688568194:web:443b8e4bb7bb1d149d2b9b",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png', // Cambia este ícono según tu proyecto.
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
