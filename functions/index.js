const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.https.onRequest((req, res) => {
  const deviceToken = req.body.device_token;
  const message = {
    notification: {
      title: "Nuevo Pedido",
      body: "Tienes un nuevo pedido",
    },
    token: deviceToken, // Token del dispositivo al que enviarás la notificación
  };

  admin.messaging()
    .send(message)
    .then((response) => {
      console.log("Notificación enviada con éxito:", response);
      res.status(200).send("Notificación enviada");
    })
    .catch((error) => {
      console.error("Error al enviar la notificación:", error);
      res.status(500).send("Error al enviar la notificación");
    });
});
