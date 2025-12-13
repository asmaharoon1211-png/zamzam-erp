// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// placeholder: create product (callable)
export const createProduct = functions.https.onCall(async (data, context) => {
  // Basic auth check
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  const db = admin.firestore();
  const productRef = db.collection('products').doc();
  await productRef.set({
    name: data.name || 'Unnamed',
    sku: data.sku || '',
    salePrice: data.salePrice || 0,
    purchasePrice: data.purchasePrice || 0,
    currentStock: data.currentStock || 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { id: productRef.id };
});

export const updateStock = functions.https.onCall(async (data, context) => {
    // Placeholder
    return { success: true };
});

export const recordSale = functions.https.onCall(async (data, context) => {
    // Placeholder
    return { success: true };
});

export const recordPurchase = functions.https.onCall(async (data, context) => {
    // Placeholder
    return { success: true };
});
