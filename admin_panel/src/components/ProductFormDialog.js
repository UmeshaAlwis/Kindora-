import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Box,
  Grid,
  MenuItem,
  CircularProgress,
  Typography,
  Paper,
} from '@mui/material';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import toast from 'react-hot-toast';
import { productService } from '../services/productService';

const ProductFormDialog = ({ open, onClose, onSave, editingProduct = null }) => {
  const [loading, setLoading] = useState(false);
  const [imageLoading, setImageLoading] = useState(false);
  const [uploadStatus, setUploadStatus] = useState(''); // 'compressing', 'uploading', ''
  const [previewImage, setPreviewImage] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    stock_quantity: '',
    image_url: '',
  });

  const categories = ['Apparel', 'Accessories', 'Home', 'Limited Edition', 'Other'];

  useEffect(() => {
    if (editingProduct) {
      setFormData(editingProduct);
      setPreviewImage(editingProduct.image_url);
    } else {
      resetForm();
    }
  }, [editingProduct, open]);

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      price: '',
      category: '',
      stock_quantity: '',
      image_url: '',
    });
    setPreviewImage(null);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === 'price' || name === 'stock_quantity' ? parseFloat(value) || '' : value,
    }));
  };

  const handleImageUpload = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      toast.error('Please upload an image file');
      return;
    }

    // Validate file size (max 5MB - before compression)
    if (file.size > 5 * 1024 * 1024) {
      toast.error('Image size must be less than 5MB');
      return;
    }

    try {
      setImageLoading(true);
      
      // Show compression status
      setUploadStatus('Compressing image...');

      // Create a temporary ID for upload
      const tempId = editingProduct?.id || `temp-${Date.now()}`;
      
      // Upload will handle compression internally
      const { url, error } = await productService.uploadProductImage(file, tempId);

      if (error) {
        toast.error('Failed to upload image');
        setUploadStatus('');
        return;
      }

      setFormData((prev) => ({
        ...prev,
        image_url: url,
      }));

      // Create canvas preview
      const reader = new FileReader();
      reader.onload = (event) => {
        setPreviewImage(event.target.result);
        setUploadStatus('');
        toast.success('Image uploaded successfully!');
      };
      reader.readAsDataURL(file);
    } catch (error) {
      console.error('Error uploading image:', error);
      toast.error('Error uploading image');
      setUploadStatus('');
    } finally {
      setImageLoading(false);
    }
  };

  const handleSubmit = async () => {
    // Validation
    if (!formData.name.trim()) {
      toast.error('Product name is required');
      return;
    }

    if (!formData.price || parseFloat(formData.price) <= 0) {
      toast.error('Valid price is required');
      return;
    }

    if (!formData.stock_quantity || parseInt(formData.stock_quantity) < 0) {
      toast.error('Valid stock quantity is required');
      return;
    }

    if (!formData.category) {
      toast.error('Please select a category');
      return;
    }

    try {
      setLoading(true);

      const productData = {
        name: formData.name.trim(),
        description: formData.description.trim(),
        price: parseFloat(formData.price),
        category: formData.category,
        stock_quantity: parseInt(formData.stock_quantity),
        image_url: formData.image_url,
      };

      await onSave(productData);
      resetForm();
      onClose();
    } catch (err) {
      console.error('Submit error:', err);
      toast.error('Failed to save product');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        {editingProduct ? 'Edit Product' : 'Add New Product'}
      </DialogTitle>

      <DialogContent sx={{ pt: 2 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {/* Product Name */}
          <TextField
            fullWidth
            label="Product Name"
            name="name"
            value={formData.name}
            onChange={handleInputChange}
            placeholder="Enter product name"
            required
          />

          {/* Description */}
          <TextField
            fullWidth
            label="Description"
            name="description"
            value={formData.description}
            onChange={handleInputChange}
            placeholder="Enter product description"
            multiline
            rows={3}
          />

          {/* Price and Stock */}
          <Grid container spacing={2}>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Price ($)"
                name="price"
                type="number"
                value={formData.price}
                onChange={handleInputChange}
                placeholder="0.00"
                inputProps={{ step: '0.01', min: '0' }}
                required
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Stock Quantity"
                name="stock_quantity"
                type="number"
                value={formData.stock_quantity}
                onChange={handleInputChange}
                placeholder="0"
                inputProps={{ min: '0' }}
                required
              />
            </Grid>
          </Grid>

          {/* Category */}
          <TextField
            fullWidth
            label="Category"
            name="category"
            select
            value={formData.category}
            onChange={handleInputChange}
            required
          >
            {categories.map((cat) => (
              <MenuItem key={cat} value={cat}>
                {cat}
              </MenuItem>
            ))}
          </TextField>

          {/* Image Upload */}
          <Box>
            <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600 }}>
              Product Image
            </Typography>
            <Paper
              sx={{
                p: 2,
                textAlign: 'center',
                border: '2px dashed #ccc',
                cursor: 'pointer',
                transition: 'all 0.3s',
                '&:hover': { borderColor: '#1976d2', bgcolor: '#f5f5f5' },
              }}
              component="label"
            >
              <input
                hidden
                accept="image/*"
                type="file"
                onChange={handleImageUpload}
                disabled={imageLoading}
              />
              {imageLoading ? (
                <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 1 }}>
                  <CircularProgress size={40} />
                  <Typography variant="body2" sx={{ fontWeight: 500 }}>
                    {uploadStatus || 'Uploading...'}
                  </Typography>
                </Box>
              ) : (
                <>
                  <CloudUploadIcon sx={{ fontSize: 40, color: '#1976d2', mb: 1 }} />
                  <Typography variant="body2">
                    Click to upload or drag and drop
                  </Typography>
                  <Typography variant="caption" color="textSecondary">
                    PNG, JPG, GIF (Max 5MB)
                  </Typography>
                </>
              )}
            </Paper>

            {/* Image Preview */}
            {previewImage && (
              <Box sx={{ mt: 2, textAlign: 'center' }}>
                <Typography variant="caption" color="textSecondary">
                  Preview:
                </Typography>
                <img
                  src={previewImage}
                  alt="Preview"
                  style={{
                    maxWidth: '100%',
                    maxHeight: '200px',
                    marginTop: '8px',
                    borderRadius: '4px',
                  }}
                />
              </Box>
            )}
          </Box>
        </Box>
      </DialogContent>

      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose} disabled={loading}>
          Cancel
        </Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={loading || imageLoading}
        >
          {loading ? <CircularProgress size={24} /> : 'Save Product'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ProductFormDialog;
