const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // Verifica si el usuario está autenticado
  if (!context.auth) {
    return { error: "No estás autenticado" };
  }

  const uid = data.uid;

  if (!uid) {
    return { error: "El UID es necesario" };
  }

  try {
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    return { message: `Rol de administrador asignado a ${uid}` };
  } catch (error) {
    return { error: "Error al asignar el rol de administrador: " + error.message };
  }
});
