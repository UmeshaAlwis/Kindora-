/**
 * Storage utilities for handling IndexedDB lock errors and cleanup
 */

/**
 * Clear IndexedDB databases safely
 */
export const clearIndexedDB = async () => {
  return new Promise((resolve) => {
    if (!window.indexedDB) {
      resolve(true);
      return;
    }

    try {
      const databases = await indexedDB.databases();
      
      databases.forEach(db => {
        const req = indexedDB.deleteDatabase(db.name);
        req.onerror = () => console.warn(`Failed to delete IndexedDB: ${db.name}`);
        req.onsuccess = () => console.log(`Cleared IndexedDB: ${db.name}`);
      });

      resolve(true);
    } catch (err) {
      console.warn('Error clearing IndexedDB:', err);
      resolve(true);
    }
  });
};

/**
 * Clear localStorage safely
 */
export const clearLocalStorage = () => {
  try {
    localStorage.clear();
    console.log('LocalStorage cleared');
    return true;
  } catch (err) {
    console.warn('Error clearing localStorage:', err);
    return true;
  }
};

/**
 * Clear sessionStorage safely
 */
export const clearSessionStorage = () => {
  try {
    sessionStorage.clear();
    console.log('SessionStorage cleared');
    return true;
  } catch (err) {
    console.warn('Error clearing sessionStorage:', err);
    return true;
  }
};

/**
 * Full storage cleanup (use only if necessary)
 */
export const clearAllStorage = async () => {
  clearLocalStorage();
  clearSessionStorage();
  await clearIndexedDB();
  console.log('All storage cleared');
};

/**
 * Check if we can access storage without locking
 */
export const checkStorageAccess = () => {
  try {
    const test = '__storage_test__';
    localStorage.setItem(test, test);
    localStorage.removeItem(test);
    return true;
  } catch (err) {
    console.warn('Storage access error:', err);
    return false;
  }
};
