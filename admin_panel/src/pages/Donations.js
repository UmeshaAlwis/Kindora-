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
  Chip,
  TextField,
  MenuItem,
  CircularProgress,
  Alert,
  Snackbar,
  TablePagination,
  InputAdornment,
  Select,
  FormControl,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';

const statusColors = {
  completed: 'success',
  pending: 'warning',
};

const Donations = () => {
  const [donations, setDonations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('all');
  const [search, setSearch] = useState('');
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  useEffect(() => {
    fetchDonations();
  }, [statusFilter]);

  const fetchDonations = async () => {
    setLoading(true);
    try {
      let query = supabase
        .from('donations')
        .select(`
          *,
          profiles:user_id (name, email),
          charities:charity_id (name)
        `)
        .order('created_at', { ascending: false });

      if (statusFilter !== 'all') query = query.eq('status', statusFilter);
      const { data, error } = await query;
      if (error) throw error;
      setDonations(data || []);
    } catch (err) {
      console.error(err);
      showSnackbar('Failed to fetch donations', 'error');
    } finally {
      setLoading(false);
    }
  };

  const showSnackbar = (message, severity = 'success') => {
    setSnackbar({ open: true, message, severity });
  };

  const handleStatusChange = async (id, newStatus) => {
    try {
      const { error } = await supabase
        .from('donations')
        .update({ status: newStatus })
        .eq('id', id);
      if (error) throw error;
      showSnackbar('Donation status updated');
      fetchDonations();
    } catch (err) {
      showSnackbar('Failed to update status', 'error');
    }
  };

  const filtered = donations.filter((d) => {
    const donorName = d.profiles?.name || d.profiles?.email || '';
    const charityName = d.charities?.name || '';
    return (
      donorName.toLowerCase().includes(search.toLowerCase()) ||
      charityName.toLowerCase().includes(search.toLowerCase())
    );
  });

  return (
    <Box>
      <Typography variant="h5" gutterBottom fontWeight={700}>
        Donations Management
      </Typography>

      <Box display="flex" gap={2} mb={3} flexWrap="wrap">
        <TextField
          size="small"
          placeholder="Search by donor or charity..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          sx={{ minWidth: 280 }}
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
          <MenuItem value="pending">Pending</MenuItem>
          <MenuItem value="completed">Completed</MenuItem>
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
                  <TableCell>Donor</TableCell>
                  <TableCell>Charity</TableCell>
                  <TableCell align="right">Amount (LKR)</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Date</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filtered.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} align="center" sx={{ py: 4 }}>
                      <Typography color="text.secondary">No donations found</Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  filtered
                    .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                    .map((donation) => (
                      <TableRow key={donation.id} hover>
                        <TableCell>
                          <Typography fontWeight={600}>
                            {donation.profiles?.name || '—'}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {donation.profiles?.email || ''}
                          </Typography>
                        </TableCell>
                        <TableCell>{donation.charities?.name || '—'}</TableCell>
                        <TableCell align="right">
                          <Typography fontWeight={600}>
                            {Number(donation.amount).toLocaleString()}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <FormControl size="small" sx={{ minWidth: 120 }}>
                            <Select
                              value={donation.status}
                              onChange={(e) =>
                                handleStatusChange(donation.id, e.target.value)
                              }
                              size="small"
                              sx={{
                                '& .MuiSelect-select': { py: 0.5 },
                                fontSize: '0.85rem',
                              }}
                            >
                              <MenuItem value="pending">
                                <Chip label="Pending" size="small" color="warning" variant="outlined" />
                              </MenuItem>
                              <MenuItem value="completed">
                                <Chip label="Completed" size="small" color="success" variant="outlined" />
                              </MenuItem>
                            </Select>
                          </FormControl>
                        </TableCell>
                        <TableCell>
                          {new Date(donation.created_at).toLocaleDateString()}
                        </TableCell>
                      </TableRow>
                    ))
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

export default Donations;
