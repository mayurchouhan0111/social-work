require('dotenv').config();
const express = require('express');
const sgMail = require('@sendgrid/mail');
const admin = require('firebase-admin'); // Firebase Admin SDK

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// --- SendGrid Setup ---
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Admin email
const ADMIN_EMAIL = 'mayurchouhan8055@gmail.com';

// --- Firebase Admin Initialization (only once) ---
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY)
    ),
    // databaseURL: "https://<DATABASE_NAME>.firebaseio.com" // Uncomment if needed
  });
}

// --- Notify Admin Route ---
app.post('/notify-admin', async (req, res) => {
  const { itemId, collectionType, itemData } = req.body;

  if (!itemId || !collectionType || !itemData) {
    return res.status(400).json({
      error: 'Missing required fields: itemId, collectionType, itemData'
    });
  }

  console.log(`Received new item notification: ${collectionType}/${itemId}`);

  try {
    const RENDER_SERVICE_BASE_URL =
      process.env.RENDER_EXTERNAL_URL || `http://localhost:${PORT}`;
    const secureToken =
      process.env.SECURE_TOKEN || 'YOUR_SECURE_TOKEN_FOR_APPROVAL';

    const acceptLink = `${RENDER_SERVICE_BASE_URL}/handle-approval?action=accept&itemId=${itemId}&collectionType=${collectionType}&token=${secureToken}`;
    const rejectLink = `${RENDER_SERVICE_BASE_URL}/handle-approval?action=reject&itemId=${itemId}&collectionType=${collectionType}&token=${secureToken}`;

    const emailSubject = `New ${collectionType.replace(
      '_',
      ' '
    )} for Approval: ${itemData.title || itemId}`;
    const emailBody = `
      <h1>New Item for Approval</h1>
      <p>A new item has been added to the ${collectionType.replace(
        '_',
        ' '
      )} collection:</p>
      <ul>
        <li><strong>ID:</strong> ${itemId}</li>
        <li><strong>Title:</strong> ${itemData.title || 'N/A'}</li>
        <li><strong>Description:</strong> ${itemData.description || 'N/A'}</li>
      </ul>
      <p>Please review and take action:</p>
      <p><a href="${acceptLink}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Accept</a></p>
      <p><a href="${rejectLink}" style="background-color: #f44336; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reject</a></p>
      <br>
      <p>This email was sent from your Treasure Hunt app backend.</p>
    `;

    const msg = {
      to: ADMIN_EMAIL,
      from: 'no-reply@yourdomain.com', // ⚠️ Use verified sender email in SendGrid
      subject: emailSubject,
      html: emailBody
    };

    await sgMail.send(msg);
    console.log('Admin notification email sent successfully.');
    res.status(200).json({ message: 'Admin notification email sent!' });
  } catch (error) {
    console.error('Error sending email:', error.message);
    if (error.response) {
      console.error(error.response.body);
    }
    res.status(500).json({ error: 'Failed to send email.' });
  }
});

// --- Handle Approval Route ---
app.get('/handle-approval', async (req, res) => {
  const { action, itemId, collectionType, token } = req.query;

  const SECURE_TOKEN =
    process.env.SECURE_TOKEN || 'YOUR_SECURE_TOKEN_FOR_APPROVAL';

  if (!action || !itemId || !collectionType || !token || token !== SECURE_TOKEN) {
    return res
      .status(400)
      .send('Invalid or missing parameters, or unauthorized token.');
  }

  let newStatus;
  if (action === 'accept') {
    newStatus = 'accepted';
  } else if (action === 'reject') {
    newStatus = 'rejected';
  } else {
    return res.status(400).send('Invalid action specified.');
  }

  console.log(`Admin action: ${action} for item ${itemId} in ${collectionType}`);

  try {
    const docRef = admin.firestore().collection(collectionType).doc(itemId);
    await docRef.update({ status: newStatus });

    console.log(
      `Successfully updated item ${itemId} status to ${newStatus} in Firestore.`
    );
    return res
      .status(200)
      .send(`Item ${itemId} has been ${newStatus}. Thank you!`);
  } catch (error) {
    console.error(
      `Error updating item ${itemId} status in Firestore:`,
      error.message
    );
    return res
      .status(500)
      .send('Internal Server Error during Firestore update.');
  }
});

// --- Start Server ---
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
