import { supabase } from '../supabaseClient';

export const productService = {
  // Fetch all active products
  async fetchProducts() {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('is_active', true)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error fetching products:', error);
      return { data: null, error };
    }
  },

  // Fetch all products (including inactive ones for admin)
  async fetchAllProducts() {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error fetching all products:', error);
      return { data: null, error };
    }
  },

  // Fetch single product
  async fetchProduct(productId) {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('id', productId)
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error fetching product:', error);
      return { data: null, error };
    }
  },

  // Create new product
  async createProduct(productData) {
    try {
      const { data: userData, error: userError } = await supabase.auth.getUser();
      if (userError || !userData.user) throw new Error('User not authenticated');

      const { data, error } = await supabase
        .from('products')
        .insert([
          {
            ...productData,
            created_by: userData.user.id,
          },
        ])
        .select()
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error creating product:', error);
      return { data: null, error };
    }
  },

  // Update product
  async updateProduct(productId, productData) {
    try {
      const { data, error } = await supabase
        .from('products')
        .update(productData)
        .eq('id', productId)
        .select()
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error updating product:', error);
      return { data: null, error };
    }
  },

  // Delete product (soft delete by setting is_active to false)
  async deleteProduct(productId) {
    try {
      const { data, error } = await supabase
        .from('products')
        .update({ is_active: false })
        .eq('id', productId)
        .select()
        .single();

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error deleting product:', error);
      return { data: null, error };
    }
  },

  // Hard delete product
  async hardDeleteProduct(productId) {
    try {
      const { error } = await supabase
        .from('products')
        .delete()
        .eq('id', productId);

      if (error) throw error;
      return { error: null };
    } catch (error) {
      console.error('Error hard deleting product:', error);
      return { error };
    }
  },

  // Compress image before upload
  async compressImage(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = (event) => {
        const img = new Image();
        img.src = event.target.result;
        img.onload = () => {
          const canvas = document.createElement('canvas');
          let { width, height } = img;

          // Resize to max 1200px while maintaining aspect ratio
          const maxDim = 1200;
          if (width > height) {
            if (width > maxDim) {
              height *= maxDim / width;
              width = maxDim;
            }
          } else if (height > maxDim) {
            width *= maxDim / height;
            height = maxDim;
          }

          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext('2d');
          ctx.drawImage(img, 0, 0, width, height);

          // Compress to jpeg with 80% quality
          canvas.toBlob(
            (blob) => {
              const compressedFile = new File([blob], file.name, {
                type: 'image/jpeg',
                lastModified: Date.now(),
              });
              resolve(compressedFile);
            },
            'image/jpeg',
            0.8
          );
        };
        img.onerror = () => reject(new Error('Failed to load image'));
      };
      reader.onerror = () => reject(new Error('Failed to read file'));
    });
  },

  // Upload product image - Using placeholder for now
  async uploadProductImage(file, productId) {
    try {
      console.log('=== IMAGE UPLOAD ===');
      console.log('File:', file.name, 'Size:', file.size);
      
      // For now, use a placeholder image URL until Supabase RLS is configured
      const placeholderUrl = `https://via.placeholder.com/300x300?text=${encodeURIComponent(file.name.split('.')[0])}`;
      
      console.log('✅ Using placeholder URL:', placeholderUrl);
      
      return { url: placeholderUrl, error: null };
    } catch (error) {
      console.error('Error processing image:', error);
      return { url: null, error };
    }
  },

  // Search products
  async searchProducts(query) {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('is_active', true)
        .or(`name.ilike.%${query}%,description.ilike.%${query}%`)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error searching products:', error);
      return { data: null, error };
    }
  },

  // Filter products by category
  async filterByCategory(category) {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('is_active', true)
        .eq('category', category)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error('Error filtering products:', error);
      return { data: null, error };
    }
  },

  // Subscribe to real-time product updates
  subscribeToProducts(callback) {
    try {
      const subscription = supabase
        .channel('products-channel')
        .on(
          'postgres_changes',
          { event: '*', schema: 'public', table: 'products' },
          (payload) => {
            callback(payload);
          }
        )
        .subscribe();

      return subscription;
    } catch (error) {
      console.error('Error subscribing to products:', error);
      return null;
    }
  },

  // Unsubscribe from real-time updates
  unsubscribeFromProducts(subscription) {
    try {
      if (subscription) {
        supabase.removeChannel(subscription);
      }
    } catch (error) {
      console.error('Error unsubscribing:', error);
    }
  },
};
