
// Importar las funciones necesarias de Firebase
import { initializeApp } from "firebase/app";
import { getStorage } from "firebase/storage";

// Configuración de Firebase
const firebaseConfig = {
    apiKey: "AIzaSyDRpS6PWIJE6kk0YoPlXSgGKQePdt-6GEQ",
    authDomain: "cafeteria2024-b355c.firebaseapp.com",
    projectId: "cafeteria2024-b355c",
    storageBucket: "cafeteria2024-b355c.appspot.com",
    messagingSenderId: "419688568194",
    appId: "1:419688568194:web:443b8e4bb7bb1d149d2b9b",
};

// Inicializar Firebase
const app = initializeApp(firebaseConfig);

// Exportar el app y servicios que usarás
export const storage = getStorage(app);
export default app;
