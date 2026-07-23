const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.onRentalRequestApproved = functions.firestore
    .document('rentalRequests/{docId}')
    .onWrite(async (change, context) => {
      const after = change.after.data();

      if (!after) return;
      if (after.status !== 'approved') return;
      if (after.notificationSent) return;

      const renterId = after.renterId;
      const itemName = after.itemName || 'an item';

      if (!renterId) return;

      try {
        const renterDoc = await admin.firestore()
            .collection('users')
            .doc(renterId)
            .get();

        const fcmToken = renterDoc.data()?.fcmToken;
        if (!fcmToken) {
          console.log(`No FCM token for user ${renterId}`);
          return;
        }

        const message = {
          token: fcmToken,
          notification: {
            title: 'Rental Approved!',
            body: `Your request for ${itemName} has been approved by the owner.`,
          },
          data: {
            screen: '/manage-requests',
          },
        };

        await admin.messaging().send(message);

        await change.after.ref.update({
          notificationSent: true,
          notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Notification sent to ${renterId} for ${itemName}`);
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    });
