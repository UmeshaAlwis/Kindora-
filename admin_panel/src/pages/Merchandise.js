import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  Box,
  Card,
  Typography,
  Button,
  CircularProgress,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  TextField,
  InputAdornment,
  IconButton,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  Avatar,
  Badge,
} from '@mui/material';
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import SearchIcon from '@mui/icons-material/Search';
import AddIcon from '@mui/icons-material/Add';
import EyeIcon from '@mui/icons-material/Visibility';
import EyeOffIcon from '@mui/icons-material/VisibilityOff';
import RefreshIcon from '@mui/icons-material/Refresh';
import toast from 'react-hot-toast';
import ProductFormDialog from '../components/ProductFormDialog';
import { productService } from '../services/productService';

const Merchandise = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [deletingId, setDeletingId] = useState(null);
  const [realtimeActive, setRealtimeActive] = useState(false);
  let subscription = null;

  useEffect(() => {
    fetchProducts();
    setupRealTimeListener();

    return () => {
      if (subscription) {
        productService.unsubscribeFromProducts(subscription);
      }
    };
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const { data, error } = await productService.fetchAllProducts();

      if (error) throw error;
      setProducts(data || []);
    } catch (err) {
      toast.error('Failed to fetch products');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const setupRealTimeListener = () => {
    try {
      subscription = productService.subscribeToProducts((payload) => {
        console.log('Real-time update received:', payload);
        setRealtimeActive(true);

        if (payload.eventType === 'INSERT') {
          setProducts((prev) => [payload.new, ...prev]);
          toast.success('New product added!');
        } else if (payload.eventType === 'UPDATE') {
          setProducts((prev) =>
            prev.map((p) => (p.id === payload.new.id ? payload.new : p))
          );
          toast.success('Product updated!');
        } else if (payload.eventType === 'DELETE') {
          setProducts((prev) => prev.filter((p) => p.id !== payload.old.id));
          toast.success('Product deleted!');
        }
      });
    } catch (err) {
      console.error('Error setting up real-time listener:', err);
      toast.error('Real-time updates may not work');
    }
  };

  const handleAddProduct = () => {
    setEditingProduct(null);
    setFormDialogOpen(true);
  };

  const handleEditProduct = (product) => {
    setEditingProduct(product);
    setFormDialogOpen(true);
  };

  const handleSaveProduct = async (productData) => {
    try {
      if (editingProduct) {
        const { error } = await productService.updateProduct(
          editingProduct.id,
          productData
        );
        if (error) throw error;
        toast.success('Product updated successfully!');
      } else {
        const { error } = await productService.createProduct(productData);
        if (error) throw error;
        toast.success('Product created successfully!');
      }
      fetchProducts();
    } catch (err) {
      console.error('Error saving product:', err);
      toast.error('Failed to save product');
    }
  };

  const handleDeleteClick = (id) => {
    setDeletingId(id);
    setDeleteConfirmOpen(true);
  };

  const handleConfirmDelete = async () => {
    try {
      const { error } = await productService.deleteProduct(deletingId);
      if (error) throw error;
      toast.success('Product deleted successfully!');
      setDeleteConfirmOpen(false);
      setDeletingId(null);
      fetchProducts();
    } catch (err) {
      console.error('Error deleting product:', err);
      toast.error('Failed to delete product');
    }
  };

  const handleToggleStatus = async (product) => {
    try {
      const { error } = await productService.updateProduct(product.id, {
        is_active: !product.is_active,
      });
      if (error) throw error;
      toast.success(`Product ${product.is_active ? 'deactivated' : 'activated'}!`);
      fetchProducts();
    } catch (err) {
      console.error('Error toggling status:', err);
      toast.error('Failed to update product status');
    }
  };

  const filteredProducts = products.filter((p) =>
    (p?.name || '').toLowerCase().includes(search.toLowerCase())
  );

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.6 }}>
      <Box>
        {/* Header */}
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={4}>
          <Box>
            <Typography variant="h4" fontWeight={800} color="text.primary">
              Product Management
            </Typography>
            <Typography variant="body2" color="text.secondary" mt={1}>
              Manage products that appear on the Merch Page
            </Typography>
          </Box>
          <Box display="flex" gap={1}>
            <Tooltip title="Refresh products">
              <IconButton
                onClick={fetchProducts}
                color="primary"
                sx={{
                  border: '1px solid',
                  borderColor: 'divider',
                  '&:hover': { bgcolor: 'action.hover' },
                }}
              >
                <RefreshIcon />
              </IconButton>
            </Tooltip>
            <Button
              variant="contained"
              startIcon={<AddIcon />}
              onClick={handleAddProduct}
              size="large"
            >
              Add Product
            </Button>
          </Box>
        </Box>

        {/* Real-time Status */}
        {realtimeActive && (
          <Card
            sx={{
              p: 2,
              mb: 3,
              bgcolor: '#e8f5e9',
              border: '1px solid #4caf50',
              display: 'flex',
              alignItems: 'center',
              gap: 1,
            }}
          >
            <Box
              sx={{
                width: 8,
                height: 8,
                borderRadius: '50%',
                bgcolor: '#4caf50',
                animation: 'pulse 2s infinite',
                '@keyframes pulse': {
                  '0%, 100%': { opacity: 1 },
                  '50%': { opacity: 0.5 },
                },
              }}
            />
            <Typography variant="body2" color="success.dark">
              Real-time sync active - Changes will appear instantly
            </Typography>
          </Card>
        )}

        {/* Search Bar */}
        <Card sx={{ p: 3, mb: 3 }}>
          <TextField
            fullWidth
            placeholder="Search products by name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
          />
        </Card>

        {/* Products Table */}
        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell>Image</TableCell>
                  <TableCell>Product Name</TableCell>
                  <TableCell>Category</TableCell>
                  <TableCell align="right">Price</TableCell>
                  <TableCell align="center">Stock</TableCell>
                  <TableCell align="center">Rating</TableCell>
                  <TableCell align="center">Status</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredProducts.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} align="center" sx={{ py: 6 }}>
                      <Box display="flex" flexDirection="column" alignItems="center" gap={1}>
                        <ShoppingBagIcon sx={{ fontSize: 48, color: 'text.disabled' }} />
                        <Typography variant="h6" color="text.secondary">
                          No products found
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          Add your first product to get started
                        </Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredProducts.map((product) => (
                    <TableRow key={product.id} hover>
                      {/* Product Image */}
                      <TableCell>
                        {product.image_url ? (
                          <Avatar
                            variant="rounded"
                            src={product.image_url}
                            sx={{ width: 50, height: 50 }}
                          />
                        ) : (
                          <Avatar
                            variant="rounded"
                            sx={{ width: 50, height: 50, bgcolor: 'action.disabledBackground' }}
                          >
                            <ShoppingBagIcon />
                          </Avatar>
                        )}
                      </TableCell>

                      {/* Product Name */}
                      <TableCell>
                        <Typography fontWeight={600}>{product.name}</Typography>
                        <Typography variant="caption" color="text.secondary" noWrap>
                          {product.description?.substring(0, 50)}...
                        </Typography>
                      </TableCell>

                      {/* Category */}
                      <TableCell>
                        <Chip label={product.category} variant="outlined" size="small" />
                      </TableCell>

                      {/* Price */}
                      <TableCell align="right">
                        <Typography fontWeight={600} color="primary.main">
                          ${Number(product.price).toFixed(2)}
                        </Typography>
                      </TableCell>

                      {/* Stock */}
                      <TableCell align="center">
                        <Badge
                          badgeContent={product.stock_quantity}
                          color={product.stock_quantity > 0 ? 'success' : 'error'}
                        >
                          <ShoppingBagIcon fontSize="small" />
                        </Badge>
                      </TableCell>

                      {/* Rating */}
                      <TableCell align="center">
                        {product.average_rating > 0 ? (
                          <Box>
                            <Typography variant="body2" fontWeight={600}>
                              {product.average_rating.toFixed(1)}★
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                              ({product.review_count})
                            </Typography>
                          </Box>
                        ) : (
                          <Typography variant="caption" color="text.secondary">
                            No reviews
                          </Typography>
                        )}
                      </TableCell>

                      {/* Status */}
                      <TableCell align="center">
                        <Chip
                          label={product.is_active ? 'Active' : 'Inactive'}
                          color={product.is_active ? 'success' : 'default'}
                          variant="outlined"
                          size="small"
                        />
                      </TableCell>

                      {/* Actions */}
                      <TableCell align="right">
                        <Tooltip title={product.is_active ? 'Deactivate' : 'Activate'}>
                          <IconButton
                            size="small"
                            onClick={() => handleToggleStatus(product)}
                            color="primary"
                          >
                            {product.is_active ? <EyeIcon /> : <EyeOffIcon />}
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Edit">
                          <IconButton
                            size="small"
                            onClick={() => handleEditProduct(product)}
                            color="primary"
                          >
                            <EditIcon />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Delete">
                          <IconButton
                            size="small"
                            onClick={() => handleDeleteClick(product.id)}
                            color="error"
                          >
                            <DeleteIcon />
                          </IconButton>
                        </Tooltip>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>

        {/* Product Form Dialog */}
        <ProductFormDialog
          open={formDialogOpen}
          onClose={() => setFormDialogOpen(false)}
          onSave={handleSaveProduct}
          editingProduct={editingProduct}
        />

        {/* Delete Confirmation Dialog */}
        <Dialog open={deleteConfirmOpen} onClose={() => setDeleteConfirmOpen(false)}>
          <DialogTitle>Delete Product</DialogTitle>
          <DialogContent>
            <Typography>
              Are you sure you want to delete this product? This action cannot be undone.
            </Typography>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setDeleteConfirmOpen(false)}>Cancel</Button>
            <Button onClick={handleConfirmDelete} color="error" variant="contained">
              Delete
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </motion.div>
  );
};

export default Merchandise;
