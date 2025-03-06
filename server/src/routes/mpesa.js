const express = require('express');
const router = express.Router();
const admin = require('../config/firebase');

const db = admin.firestore();

router.post('/stkCallback', async (req, res) => {
  try {
    const { Body } = req.body;
    const { stkCallback } = Body;
    const { CheckoutRequestID, ResultCode, ResultDesc } = stkCallback;

    // Find the transaction with this CheckoutRequestID
    const transactionsRef = db.collection('transactions');
    const snapshot = await transactionsRef
      .where('mpesaCheckoutRequestID', '==', CheckoutRequestID)
      .get();

    if (!snapshot.empty) {
      const transaction = snapshot.docs[0];
      const transactionData = transaction.data();

      if (ResultCode === 0) {
        // Success - Update transaction and user balance
        const batch = db.batch();
        
        // Update transaction status
        batch.update(transaction.ref, {
          status: 'completed',
          mpesaResult: stkCallback,
          completedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        // Update user balance
        const userRef = db.collection('users').doc(transactionData.userId);
        batch.update(userRef, {
          'totalBalance': admin.firestore.FieldValue.increment(transactionData.amount)
        });

        await batch.commit();
      } else {
        // Failed transaction
        await transaction.ref.update({
          status: 'failed',
          mpesaResult: stkCallback,
          failureReason: ResultDesc,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }

    res.json({ success: true });
  } catch (error) {
    console.error('STK Callback Error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.post('/b2cResult', async (req, res) => {
  try {
    const { Result } = req.body;
    const { ConversationID, ResultCode, ResultDesc } = Result;

    // Find the withdrawal transaction
    const transactionsRef = db.collection('transactions');
    const snapshot = await transactionsRef
      .where('mpesaConversationID', '==', ConversationID)
      .get();

    if (!snapshot.empty) {
      const transaction = snapshot.docs[0];
      const transactionData = transaction.data();

      if (ResultCode === 0) {
        // Success - Update transaction status
        await transaction.ref.update({
          status: 'completed',
          mpesaResult: Result,
          completedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } else {
        // Failed withdrawal - Refund the user
        const batch = db.batch();
        
        // Update transaction status
        batch.update(transaction.ref, {
          status: 'failed',
          mpesaResult: Result,
          failureReason: ResultDesc,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        // Refund user balance
        const userRef = db.collection('users').doc(transactionData.userId);
        batch.update(userRef, {
          'totalBalance': admin.firestore.FieldValue.increment(transactionData.amount)
        });

        await batch.commit();
      }
    }

    res.json({ success: true });
  } catch (error) {
    console.error('B2C Result Error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;