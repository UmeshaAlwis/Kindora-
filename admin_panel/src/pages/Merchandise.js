import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { supabase } from '../supabaseClient';
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
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from '@mui/material';
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';
import EditIcon from '@mui/icons-material/Edit';
import SearchIcon from '@mui/icons-material/Search';
import AddIcon from '@mui/icons-material/Add';
import toast from 'react-hot-toast';

const Merchandise = () => {
  const [merchandise, setMerchandise] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    quantity_available: '',
    quantity_sold: '',
    status: 'Available',
  });

  useEffect(() => {
    fetchMerchandise();
  }, []);

  const fetchMerchandise = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('merchandise')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setMerchandise(data || []);
    } catch (err) {
      toast.error('Failed to fetch merchandise');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (item = null) => {
    if (item) {
      setEditingId(item.id);
      setFormData({
        name: item.name,
        description: item.description || '',
        price: item.price,
        quantity_available: item.quantity_available,
        quantity_sold: item.quantity_sold || 0,
        status: item.status,
      });
    } else {
      setEditingId(null);
      setFormData({
        name: '',
        description: '',
        price: '',
        quantity_available: '',
        quantity_sold: '',
        status: 'Available',
      });
    }
    setDialogOpen(true);
  };

  const handleSave = async () => {
    if (!formData.name || !formData.price) {
      toast.error('Please fill all required fields');
      return;
    }

    try {
      if (editingId) {
        const { error } = await supabase
          .from('merchandise')
          .update(formData)
          .eq('id', editingId);
        if (error) throw error;
        toast.success('Item updated');
      } else {
        const { error } = await supabase.from('merchandise').insert([formData]);
        if (error) throw error;
        toast.success('Item created');
      }
      setDialogOpen(false);
      fetchMerchandise();
    } catch (err) {
      toast.error('Failed to save item');
      console.error(err);
    }
  };

  const handleDeleteItem = async (id) => {
    if (!window.confirm('Delete this item?')) return;
    try {
      const { error } = await supabase.from('merchandise').delete().eq('id', id);
      if (error) throw error;
      toast.success('Item deleted');
      fetchMerchandise();
    } catch (err) {
      toast.error('Failed to delete item');
    }
  };

  const filteredMerchandise = merchandise.filter((m) =>
    (m?.name || '').toLowerCase().includes(search.toLowerCase())
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
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={4}>
          <Box>
            <Typography variant="h4" fontWeight={800} color="text.primary">
              Merchandise Management
            </Typography>
            <Typography variant="body2" color="text.secondary" mt={1}>
              Manage merchandise inventory and orders
            </Typography>
          </Box>
          <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
            Add Item
          </Button>
        </Box>

        <Card sx={{ p: 3, mb: 3 }}>
          <TextField
            fullWidth
            placeholder="Search merchandise..."
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

        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell fontWeight={800}>Item Name</TableCell>
                  <TableCell>Price</TableCell>
                  <TableCell>Available</TableCell>
                  <TableCell>Sold</TableCell>
                  <TableCell>Stock %</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredMerchandise.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                      <Box display="flex" flexDirection="column" alignItems="center" gap={1}>
                        <ShoppingBagIcon sx={{ fontSize: 40, color: 'text.disabled' }} />
                        <Typography color="text.secondary">No merchandise found</Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredMerchandise.map((item) => {
                    const total = Number(item.quantity_available) + Number(item.quantity_sold);
                    const stockPercent =
                      total > 0
                        ? Math.round((Number(item.quantity_available) / total) * 100)
                        : 0;
                    return (
                      <TableRow key={item.id} hover>
                        <TableCell fontWeight={600}>{item.name}</TableCell>
                        <TableCell>${Number(item.price).toFixed(2)}</TableCell>
                        <TableCell>{item.quantity_available}</TableCell>
                        <TableCell>{item.quantity_sold}</TableCell>
                        <TableCell>
                          <Box
                            sx={{
                              background: `linear-gradient(90deg, #FF751F ${100 - stockPercent}%, #f5f5f5 ${100 - stockPercent}%)`,
                              borderRadius: 1,
                              px: 2,
                              py: 0.5,
                              textAlign: 'center',
                              fontWeight: 600,
                              color: 100 - stockPercent > 50 ? '#fff' : '#000',
                            }}
                          >
                            {100 - stockPercent}%
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={item.status}
                            color={item.status === 'Available' ? 'success' : 'default'}
                            variant="outlined"
                            size="small"
                          />
                        </TableCell>
                        <TableCell align="right">
                          <Button
                            size="small"
                            variant="outlined"
                            startIcon={<EditIcon />}
                            onClick={() => handleOpenDialog(item)}
                            sx={{ mr: 1 }}
                          >
                            Edit
                          </Button>
                          <Button
                            size="small"
                            variant="outlined"
                            color="error"
                            onClick={() => handleDeleteItem(item.id)}
                          >
                            Delete
                          </Button>
                        </TableCell>
                      </TableRow>
                    );
                  })
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>

        <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>{editingId ? 'Edit Item' : 'Add Merchandise Item'}</DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2.5} pt={1}>
              <TextField
                label="Item Name"
                fullWidth
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              />
              <TextField
                label="Description"
                fullWidth
                multiline
                rows={3}
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              />
              <TextField
                label="Price"
                type="number"
                fullWidth
                inputProps={{ step: '0.01' }}
                value={formData.price}
                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
              />
              <TextField
                label="Quantity Available"
                type="number"
                fullWidth
                value={formData.quantity_available}
                onChange={(e) => setFormData({ ...formData, quantity_available: e.target.value })}
              />
              <TextField
                label="Quantity Sold"
                type="number"
                fullWidth
                value={formData.quantity_sold}
                onChange={(e) => setFormData({ ...formData, quantity_sold: e.target.value })}
              />
              <TextField
                select
                label="Status"
                fullWidth
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value })}
              >
                <MenuItem value="Available">Available</MenuItem>
                <MenuItem value="Out of Stock">Out of Stock</MenuItem>
                <MenuItem value="Discontinued">Discontinued</MenuItem>
              </TextField>
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button variant="contained" onClick={handleSave}>
              Save
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </motion.div>
  );
};

export default Merchandise;
