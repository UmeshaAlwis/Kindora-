import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { supabase } from '../supabaseClient';
import {
  Box,
  Card,
  Typography,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  CircularProgress,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  InputAdornment,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import SearchIcon from '@mui/icons-material/Search';
import toast from 'react-hot-toast';


const Campaigns = () => {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    amount_goal: '',
    raised_amount: '',
    status: 'Active',
  });

  useEffect(() => {
    fetchCampaigns();
  }, []);

  const fetchCampaigns = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('campaigns')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setCampaigns(data || []);
    } catch (err) {
      toast.error('Failed to fetch campaigns');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (campaign = null) => {
    if (campaign) {
      setEditingId(campaign.id);
      setFormData({
        name: campaign.name,
        description: campaign.description || '',
        amount_goal: campaign.amount_goal,
        raised_amount: campaign.raised_amount || 0,
        status: campaign.status,
      });
    } else {
      setEditingId(null);
      setFormData({
        name: '',
        description: '',
        amount_goal: '',
        raised_amount: '',
        status: 'Active',
      });
    }
    setDialogOpen(true);
  };

  const handleSave = async () => {
    if (!formData.name || !formData.amount_goal) {
      toast.error('Please fill all required fields');
      return;
    }

    try {
      if (editingId) {
        const { error } = await supabase
          .from('campaigns')
          .update(formData)
          .eq('id', editingId);
        if (error) throw error;
        toast.success('Campaign updated');
      } else {
        const { error } = await supabase.from('campaigns').insert([formData]);
        if (error) throw error;
        toast.success('Campaign created');
      }
      setDialogOpen(false);
      fetchCampaigns();
    } catch (err) {
      toast.error('Failed to save campaign');
      console.error(err);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure?')) return;
    try {
      const { error } = await supabase.from('campaigns').delete().eq('id', id);
      if (error) throw error;
      toast.success('Campaign deleted');
      fetchCampaigns();
    } catch (err) {
      toast.error('Failed to delete campaign');
    }
  };

  const filteredCampaigns = campaigns.filter((c) =>
    (c?.name || '').toLowerCase().includes(search.toLowerCase())
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
          <Typography variant="h4" fontWeight={800} color="text.primary">
            Campaign Management
          </Typography>
          <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenDialog()}>
            New Campaign
          </Button>
        </Box>

        <Card sx={{ p: 3, mb: 3 }}>
          <TextField
            fullWidth
            placeholder="Search campaigns..."
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
                  <TableCell fontWeight={800}>Campaign Name</TableCell>
                  <TableCell>Target Amount</TableCell>
                  <TableCell>Raised</TableCell>
                  <TableCell>Progress</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredCampaigns.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                      <Typography color="text.secondary">No campaigns found</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredCampaigns.map((campaign) => {
                    const progress = Math.round(
                      (Number(campaign.raised_amount) / Number(campaign.amount_goal)) * 100
                    );
                    return (
                      <TableRow key={campaign.id} hover>
                        <TableCell fontWeight={600}>{campaign.name}</TableCell>
                        <TableCell>${Number(campaign.amount_goal).toLocaleString()}</TableCell>
                        <TableCell>${Number(campaign.raised_amount).toLocaleString()}</TableCell>
                        <TableCell>
                          <Box
                            sx={{
                              background: `linear-gradient(90deg, #0C0C79 ${progress}%, #f5f5f5 ${progress}%)`,
                              borderRadius: 2,
                              px: 2,
                              py: 1,
                              minWidth: 60,
                              textAlign: 'center',
                              fontWeight: 600,
                              color: progress > 50 ? '#fff' : '#000',
                            }}
                          >
                            {progress}%
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={campaign.status}
                            color={campaign.status === 'Active' ? 'success' : 'default'}
                            variant="outlined"
                            size="small"
                          />
                        </TableCell>
                        <TableCell align="right">
                          <Button
                            size="small"
                            variant="outlined"
                            startIcon={<EditIcon />}
                            onClick={() => handleOpenDialog(campaign)}
                            sx={{ mr: 1 }}
                          >
                            Edit
                          </Button>
                          <Button
                            size="small"
                            variant="outlined"
                            color="error"
                            startIcon={<DeleteIcon />}
                            onClick={() => handleDelete(campaign.id)}
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
          <DialogTitle>{editingId ? 'Edit Campaign' : 'Create Campaign'}</DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2.5} pt={1}>
              <TextField
                label="Campaign Name"
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
                label="Target Amount"
                type="number"
                fullWidth
                value={formData.amount_goal}
                onChange={(e) => setFormData({ ...formData, amount_goal: e.target.value })}
              />
              <TextField
                label="Raised Amount"
                type="number"
                fullWidth
                value={formData.raised_amount}
                onChange={(e) => setFormData({ ...formData, raised_amount: e.target.value })}
              />
              <TextField
                select
                label="Status"
                fullWidth
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                SelectProps={{}}
              >
                <option value="Active">Active</option>
                <option value="Completed">Completed</option>
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

export default Campaigns;
