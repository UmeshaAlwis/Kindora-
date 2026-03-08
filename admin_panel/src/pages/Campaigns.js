import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';
import {
  Box,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Chip,
  TextField,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  CircularProgress,
  Alert,
  Snackbar,
  TablePagination,
  InputAdornment,
  LinearProgress,
  Tooltip,
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import AddIcon from '@mui/icons-material/Add';
import SearchIcon from '@mui/icons-material/Search';

const emptyForm = {
  charity_id: '',
  title: '',
  description: '',
  target_amount: '',
  raised_amount: '',
  status: 'active',
};

const Campaigns = () => {
  const [campaigns, setCampaigns] = useState([]);
  const [charities, setCharities] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [dialog, setDialog] = useState(false);
  const [deleteDialog, setDeleteDialog] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [selectedCampaign, setSelectedCampaign] = useState(null);
  const [form, setForm] = useState(emptyForm);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  useEffect(() => {
    fetchCampaigns();
    fetchCharities();
  }, [statusFilter]);

  const fetchCampaigns = async () => {
    setLoading(true);
    try {
      let query = supabase
        .from('campaigns')
        .select(`*, charities:charity_id (name)`)
        .order('created_at', { ascending: false });

      if (statusFilter !== 'all') query = query.eq('status', statusFilter);
      const { data, error } = await query;
      if (error) throw error;
      setCampaigns(data || []);
    } catch (err) {
      console.error(err);
      showSnackbar('Failed to fetch campaigns', 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchCharities = async () => {
    const { data } = await supabase.from('charities').select('id, name').order('name');
    setCharities(data || []);
  };

  const showSnackbar = (message, severity = 'success') => {
    setSnackbar({ open: true, message, severity });
  };

  const handleOpenCreate = () => {
    setForm(emptyForm);
    setIsEditing(false);
    setDialog(true);
  };

  const handleOpenEdit = (campaign) => {
    setSelectedCampaign(campaign);
    setForm({
      charity_id: campaign.charity_id || '',
      title: campaign.title || '',
      description: campaign.description || '',
      target_amount: campaign.target_amount || '',
      raised_amount: campaign.raised_amount || '',
      status: campaign.status || 'active',
    });
    setIsEditing(true);
    setDialog(true);
  };

  const handleSave = async () => {
    try {
      const payload = {
        charity_id: form.charity_id,
        title: form.title,
        description: form.description,
        target_amount: Number(form.target_amount),
        raised_amount: Number(form.raised_amount) || 0,
        status: form.status,
      };

      let error;
      if (isEditing) {
        ({ error } = await supabase.from('campaigns').update(payload).eq('id', selectedCampaign.id));
      } else {
        ({ error } = await supabase.from('campaigns').insert([payload]));
      }
      if (error) throw error;
      showSnackbar(`Campaign ${isEditing ? 'updated' : 'created'} successfully`);
      setDialog(false);
      fetchCampaigns();
    } catch (err) {
      showSnackbar(`Failed to ${isEditing ? 'update' : 'create'} campaign`, 'error');
    }
  };

  const handleDelete = (campaign) => {
    setSelectedCampaign(campaign);
    setDeleteDialog(true);
  };

  const confirmDelete = async () => {
    try {
      const { error } = await supabase.from('campaigns').delete().eq('id', selectedCampaign.id);
      if (error) throw error;
      showSnackbar('Campaign deleted');
      setDeleteDialog(false);
      fetchCampaigns();
    } catch (err) {
      showSnackbar('Failed to delete campaign', 'error');
    }
  };

  const filtered = campaigns.filter(
    (c) =>
      (c.title || '').toLowerCase().includes(search.toLowerCase()) ||
      (c.charities?.name || '').toLowerCase().includes(search.toLowerCase())
  );

  const getProgress = (raised, target) => {
    if (!target || target === 0) return 0;
    return Math.min(100, (raised / target) * 100);
  };

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>
          Campaigns Management
        </Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenCreate}>
          New Campaign
        </Button>
      </Box>

      <Box display="flex" gap={2} mb={3} flexWrap="wrap">
        <TextField
          size="small"
          placeholder="Search campaigns..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          sx={{ minWidth: 250 }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon color="action" />
              </InputAdornment>
            ),
          }}
        />
        <TextField
          select
          size="small"
          label="Status"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          sx={{ minWidth: 150 }}
        >
          <MenuItem value="all">All</MenuItem>
          <MenuItem value="active">Active</MenuItem>
          <MenuItem value="completed">Completed</MenuItem>
          <MenuItem value="paused">Paused</MenuItem>
        </TextField>
      </Box>

      {loading ? (
        <Box display="flex" justifyContent="center" py={6}>
          <CircularProgress />
        </Box>
      ) : (
        <Paper elevation={0} sx={{ border: '1px solid', borderColor: 'divider' }}>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Title</TableCell>
                  <TableCell>Charity</TableCell>
                  <TableCell>Progress</TableCell>
                  <TableCell align="right">Target (LKR)</TableCell>
                  <TableCell align="right">Raised (LKR)</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Created</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filtered.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} align="center" sx={{ py: 4 }}>
                      <Typography color="text.secondary">No campaigns found</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  filtered
                    .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                    .map((campaign) => {
                      const progress = getProgress(
                        Number(campaign.raised_amount),
                        Number(campaign.target_amount)
                      );
                      return (
                        <TableRow key={campaign.id} hover>
                          <TableCell>
                            <Typography fontWeight={600}>{campaign.title}</Typography>
                            <Typography variant="caption" color="text.secondary">
                              {campaign.description?.substring(0, 50)}
                              {(campaign.description?.length || 0) > 50 ? '...' : ''}
                            </Typography>
                          </TableCell>
                          <TableCell>{campaign.charities?.name || '—'}</TableCell>
                          <TableCell sx={{ minWidth: 140 }}>
                            <Box display="flex" alignItems="center" gap={1}>
                              <LinearProgress
                                variant="determinate"
                                value={progress}
                                sx={{
                                  flex: 1,
                                  height: 8,
                                  borderRadius: 4,
                                  backgroundColor: 'rgba(0,0,0,0.06)',
                                  '& .MuiLinearProgress-bar': {
                                    borderRadius: 4,
                                    backgroundColor:
                                      progress >= 100
                                        ? '#4CAF50'
                                        : progress >= 50
                                        ? '#FFC107'
                                        : '#6C63FF',
                                  },
                                }}
                              />
                              <Typography variant="caption" fontWeight={600}>
                                {progress.toFixed(0)}%
                              </Typography>
                            </Box>
                          </TableCell>
                          <TableCell align="right">
                            {Number(campaign.target_amount).toLocaleString()}
                          </TableCell>
                          <TableCell align="right">
                            {Number(campaign.raised_amount).toLocaleString()}
                          </TableCell>
                          <TableCell>
                            <Chip
                              label={campaign.status}
                              size="small"
                              color={
                                campaign.status === 'active'
                                  ? 'success'
                                  : campaign.status === 'completed'
                                  ? 'primary'
                                  : 'default'
                              }
                              variant="outlined"
                            />
                          </TableCell>
                          <TableCell>
                            {new Date(campaign.created_at).toLocaleDateString()}
                          </TableCell>
                          <TableCell align="right">
                            <Tooltip title="Edit">
                              <IconButton
                                size="small"
                                color="primary"
                                onClick={() => handleOpenEdit(campaign)}
                              >
                                <EditIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                            <Tooltip title="Delete">
                              <IconButton
                                size="small"
                                color="error"
                                onClick={() => handleDelete(campaign)}
                              >
                                <DeleteIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                          </TableCell>
                        </TableRow>
                      );
                    })
                )}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination
            component="div"
            count={filtered.length}
            page={page}
            onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage}
            onRowsPerPageChange={(e) => {
              setRowsPerPage(parseInt(e.target.value, 10));
              setPage(0);
            }}
          />
        </Paper>
      )}

      {/* Create / Edit Dialog */}
      <Dialog open={dialog} onClose={() => setDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{isEditing ? 'Edit Campaign' : 'Create Campaign'}</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2.5} pt={1}>
            <TextField
              label="Title"
              fullWidth
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              required
            />
            <TextField
              label="Description"
              fullWidth
              multiline
              rows={3}
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
            />
            <TextField
              select
              label="Charity"
              fullWidth
              value={form.charity_id}
              onChange={(e) => setForm({ ...form, charity_id: e.target.value })}
              required
            >
              {charities.map((c) => (
                <MenuItem key={c.id} value={c.id}>
                  {c.name}
                </MenuItem>
              ))}
            </TextField>
            <Box display="flex" gap={2}>
              <TextField
                label="Target Amount (LKR)"
                type="number"
                fullWidth
                value={form.target_amount}
                onChange={(e) => setForm({ ...form, target_amount: e.target.value })}
                required
              />
              <TextField
                label="Raised Amount (LKR)"
                type="number"
                fullWidth
                value={form.raised_amount}
                onChange={(e) => setForm({ ...form, raised_amount: e.target.value })}
              />
            </Box>
            <TextField
              select
              label="Status"
              fullWidth
              value={form.status}
              onChange={(e) => setForm({ ...form, status: e.target.value })}
            >
              <MenuItem value="active">Active</MenuItem>
              <MenuItem value="completed">Completed</MenuItem>
              <MenuItem value="paused">Paused</MenuItem>
            </TextField>
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSave}>
            {isEditing ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Delete Dialog */}
      <Dialog open={deleteDialog} onClose={() => setDeleteDialog(false)}>
        <DialogTitle>Confirm Delete</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to delete campaign <strong>{selectedCampaign?.title}</strong>?
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setDeleteDialog(false)}>Cancel</Button>
          <Button variant="contained" color="error" onClick={confirmDelete}>
            Delete
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert
          onClose={() => setSnackbar({ ...snackbar, open: false })}
          severity={snackbar.severity}
          variant="filled"
        >
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default Campaigns;
