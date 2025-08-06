importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js');

// Initialize the Firebase app in the service worker
firebase.initializeApp({
  apiKey: "AIzaSyCFekRvH0YL4hKxOwwsjTar4OeN6wWcMpE",
  authDomain: "traiteurmanagement-bdd43.firebaseapp.com",
  projectId: "traiteurmanagement-bdd43",
  storageBucket: "traiteurmanagement-bdd43.firebasestorage.app",
  messagingSenderId: "707485444506",
  appId: "1:707485444506:web:9555a169f1e780bd6c3223",
});

const messaging = firebase.messaging();