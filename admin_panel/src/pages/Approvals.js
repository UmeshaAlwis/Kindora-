import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { supabase } from '../supabaseClient';
import {
  Box,
  Card,
  CardContent,
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
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import SearchIcon from '@mui/icons-material/Search';
import InfoIcon from '@mui/icons-material/Info';
import toast from 'react-hot-toast';

const Approvals = () => {
  const [approvals, setApprovals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('pending');

  useEffect(() => {
    fetchApprovals();
  }, [filter]);

  const fetchApprovals = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('campaigns')
        .select('*')
        .eq('status', filter === 'pending' ? 'Pending' : filter === 'approved' ? 'Active' : 'Rejected')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setApprovals(data || []);
    } catch (err) {
      toast.error('Failed to fetch approvals');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (id) => {
    try {
      const { error } = await supabase
        .from('campaigns')
        .update({ status: 'Active' })
        .eq('id', id);
      if (error) throw error;
      toast.success('Campaign approved');
      fetchApprovals();
    } catch (err) {
      toast.error('Failed to approve campaign');
    }
  };

  const handleReject = async (id) => {
    try {
      const { error } = await supabase
        .from('campaigns')
        .update({ status: 'Rejected' })
        .eq('id', id);
      if (error) throw error;
      toast.success('Campaign rejected');
      fetchApprovals();
    } catch (err) {
      toast.error('Failed to reject campaign');
    }
  };

  const filteredApprovals = approvals.filter((a) =>
    (a?.name || '').toLowerCase().includes(search.toLowerCase())
  );

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  const getStatusColor = (status) => {
    if (status === 'Pending') return 'warning';
    if (status === 'Active') return 'success';
    return 'error';
  };

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.6 }}>
      <Box>
        <Box mb={4}>
          <Typography variant="h4" fontWeight={800} color="text.primary" mb={2}>
            Campaign Approvals
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Review and manage campaign approval requests
          </Typography>
        </Box>

        <Box display="flex" gap={2} mb={3} flexWrap="wrap">
          <TextField
            fullWidth
            sx={{ maxWidth: 400 }}
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
          <Box display="flex" gap={1}>
            {['pending', 'approved', 'rejected'].map((status) => (
              <Button
                key={status}
                variant={filter === status ? 'contained' : 'outlined'}
                onClick={() => setFilter(status)}
              >
                {status.charAt(0).toUpperCase() + status.slice(1)}
              </Button>
            ))}
          </Box>
        </Box>

        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell fontWeight={800}>Campaign Name</TableCell>
                  <TableCell>Description</TableCell>
                  <TableCell>Target Amount</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredApprovals.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} align="center" sx={{ py: 4 }}>
                      <Box display="flex" flexDirection="column" alignItems="center" gap={1}>
                        <InfoIcon color="disabled" sx={{ fontSize: 40 }} />
                        <Typography color="text.secondary">
                          No {filter} campaigns to display
                        </Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredApprovals.map((approval) => (
                    <TableRow key={approval.id} hover>
                      <TableCell fontWeight={600}>{approval.name}</TableCell>
                      <TableCell sx={{ maxWidth: 300 }}>
                        <Typography variant="body2" noWrap>
                          {approval.description || 'No description'}
                        </Typography>
                      </TableCell>
                      <TableCell>${Number(approval.amount_goal).toLocaleString()}</TableCell>
                      <TableCell>
                        <Chip
                          label={approval.status}
                          color={getStatusColor(approval.status)}
                          variant="outlined"
                          size="small"
                        />
                      </TableCell>
                      <TableCell align="right">
                        {approval.status === 'Pending' && (
                          <Box display="flex" gap={1} justifyContent="flex-end">
                            <Button
                              size="small"
                              variant="contained"
                              color="success"
                              startIcon={<CheckCircleIcon />}
                              onClick={() => handleApprove(approval.id)}
                            >
                              Approve
                            </Button>
                            <Button
                              size="small"
                              variant="outlined"
                              color="error"
                              startIcon={<CancelIcon />}
                              onClick={() => handleReject(approval.id)}
                            >
                              Reject
                            </Button>
                          </Box>
                        )}
                        {approval.status !== 'Pending' && (
                          <Typography variant="caption" color="text.secondary">
                            {approval.status === 'Active' ? 'Approved' : 'Rejected'}
                          </Typography>
                        )}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>
      </Box>
    </motion.div>
  );
};

export default Approvals;
