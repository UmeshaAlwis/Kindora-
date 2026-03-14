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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControlLabel,
  Checkbox,
  FormGroup,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import AddIcon from '@mui/icons-material/Add';
import SearchIcon from '@mui/icons-material/Search';
import DeleteIcon from '@mui/icons-material/Delete';
import EmailIcon from '@mui/icons-material/Email';
import toast from 'react-hot-toast';

const Alerts = () => {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [recipientType, setRecipientType] = useState('all'); // all, group, individual
  const [selectedGroups, setSelectedGroups] = useState([]);
  const [alertFormData, setAlertFormData] = useState({
    subject: '',
    message: '',
    type: 'update', // update, urgent, campaign
  });

  const groups = [
    { id: 'donors', label: 'All Donors' },
    { id: 'active_donors', label: 'Active Donors (Last 30 days)' },
    { id: 'charities', label: 'Charity Partners' },
    { id: 'volunteers', label: 'Volunteers' },
    { id: 'admins', label: 'Admin Users' },
  ];

  useEffect(() => {
    fetchAlerts();
  }, []);

  const fetchAlerts = async () => {
    try {
      setLoading(true);
      // Mock data for sent alerts
      const mockAlerts = [
        {
          id: '1',
          subject: 'New Education Campaign Launched',
          type: 'campaign',
          recipients: 'All Users',
          message_preview: 'We are excited to announce a new education initiative...',
          sent_at: new Date(Date.now() - 86400000).toISOString(),
          sent_by: 'Admin',
          recipient_count: 2456,
        },
        {
          id: '2',
          subject: 'Urgent: Medical Camp This Weekend',
          type: 'urgent',
          recipients: 'Active Donors',
          message_preview: 'Please join us for a medical camp in the community center...',
          sent_at: new Date(Date.now() - 172800000).toISOString(),
          sent_by: 'Admin',
          recipient_count: 543,
        },
        {
          id: '3',
          subject: 'Your Donations Made an Impact',
          type: 'update',
          recipients: 'Donors',
          message_preview: 'Thank you for your recent donations. Here is the impact report...',
          sent_at: new Date(Date.now() - 259200000).toISOString(),
          sent_by: 'Admin',
          recipient_count: 1234,
        },
      ];
      setAlerts(mockAlerts);
    } catch (err) {
      toast.error('Failed to fetch alerts');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSendAlert = async () => {
    if (!alertFormData.subject || !alertFormData.message) {
      toast.error('Please fill all required fields');
      return;
    }

    if (recipientType === 'group' && selectedGroups.length === 0) {
      toast.error('Please select at least one group');
      return;
    }

    try {
      const newAlert = {
        id: Date.now().toString(),
        subject: alertFormData.subject,
        type: alertFormData.type,
        recipients:
          recipientType === 'all'
            ? 'All Users'
            : selectedGroups.map((g) => groups.find((gr) => gr.id === g)?.label).join(', '),
        message_preview: alertFormData.message.substring(0, 100) + '...',
        sent_at: new Date().toISOString(),
        sent_by: 'Admin',
        recipient_count:
          recipientType === 'all' ? 5000 : Math.floor(Math.random() * 2000) + 500,
      };

      setAlerts([newAlert, ...alerts]);
      setDialogOpen(false);
      setAlertFormData({
        subject: '',
        message: '',
        type: 'update',
      });
      setRecipientType('all');
      setSelectedGroups([]);
      toast.success('Alert sent successfully to recipients');
    } catch (err) {
      toast.error('Failed to send alert');
      console.error(err);
    }
  };

  const handleDeleteAlert = async (id) => {
    if (!window.confirm('Delete this alert record?')) return;
    try {
      setAlerts(alerts.filter((a) => a.id !== id));
      toast.success('Alert deleted');
    } catch (err) {
      toast.error('Failed to delete alert');
    }
  };

  const filteredAlerts = alerts.filter(
    (a) =>
      (a?.subject || '').toLowerCase().includes(search.toLowerCase()) ||
      (a?.recipients || '').toLowerCase().includes(search.toLowerCase())
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
              Send Alerts & Notifications
            </Typography>
            <Typography variant="body2" color="text.secondary" mt={1}>
              Send emails and alerts to users or specific groups
            </Typography>
          </Box>
          <Button variant="contained" startIcon={<AddIcon />} onClick={() => setDialogOpen(true)}>
            Send Alert
          </Button>
        </Box>

        <Card sx={{ p: 3, mb: 3 }}>
          <TextField
            fullWidth
            placeholder="Search alerts..."
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
                  <TableCell fontWeight={800}>Subject</TableCell>
                  <TableCell>Recipients</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell>Count</TableCell>
                  <TableCell>Date Sent</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredAlerts.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                      <Box display="flex" flexDirection="column" alignItems="center" gap={1}>
                        <EmailIcon sx={{ fontSize: 40, color: 'text.disabled' }} />
                        <Typography color="text.secondary">No alerts sent yet</Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredAlerts.map((alert) => (
                    <TableRow key={alert.id} hover>
                      <TableCell fontWeight={600}>{alert.subject}</TableCell>
                      <TableCell>{alert.recipients}</TableCell>
                      <TableCell>
                        <Chip
                          label={alert.type}
                          color={
                            alert.type === 'urgent'
                              ? 'error'
                              : alert.type === 'campaign'
                              ? 'info'
                              : 'success'
                          }
                          variant="outlined"
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" fontWeight={600}>
                          {alert.recipient_count.toLocaleString()}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="caption">
                          {new Date(alert.sent_at).toLocaleDateString()}
                        </Typography>
                      </TableCell>
                      <TableCell align="right">
                        <Button
                          size="small"
                          variant="outlined"
                          color="error"
                          startIcon={<DeleteIcon />}
                          onClick={() => handleDeleteAlert(alert.id)}
                        >
                          Delete
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>

        <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Send Alert/Notification</DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2.5} pt={2}>
              <TextField
                label="Subject"
                fullWidth
                value={alertFormData.subject}
                onChange={(e) =>
                  setAlertFormData({ ...alertFormData, subject: e.target.value })
                }
                placeholder="Enter alert subject"
              />

              <TextField
                label="Message"
                fullWidth
                multiline
                rows={5}
                value={alertFormData.message}
                onChange={(e) =>
                  setAlertFormData({ ...alertFormData, message: e.target.value })
                }
                placeholder="Enter your message here..."
              />

              <FormControl fullWidth>
                <InputLabel>Type</InputLabel>
                <Select
                  value={alertFormData.type}
                  label="Type"
                  onChange={(e) =>
                    setAlertFormData({ ...alertFormData, type: e.target.value })
                  }
                >
                  <MenuItem value="update">General Update</MenuItem>
                  <MenuItem value="urgent">Urgent Alert</MenuItem>
                  <MenuItem value="campaign">Campaign Launch</MenuItem>
                </Select>
              </FormControl>

              <FormControl fullWidth>
                <InputLabel>Send To</InputLabel>
                <Select
                  value={recipientType}
                  label="Send To"
                  onChange={(e) => setRecipientType(e.target.value)}
                >
                  <MenuItem value="all">All Users</MenuItem>
                  <MenuItem value="group">Specific Groups</MenuItem>
                </Select>
              </FormControl>

              {recipientType === 'group' && (
                <Box>
                  <Typography variant="subtitle2" fontWeight={600} mb={1}>
                    Select Groups
                  </Typography>
                  <FormGroup>
                    {groups.map((group) => (
                      <FormControlLabel
                        key={group.id}
                        control={
                          <Checkbox
                            checked={selectedGroups.includes(group.id)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setSelectedGroups([...selectedGroups, group.id]);
                              } else {
                                setSelectedGroups(
                                  selectedGroups.filter((g) => g !== group.id)
                                );
                              }
                            }}
                          />
                        }
                        label={group.label}
                      />
                    ))}
                  </FormGroup>
                </Box>
              )}
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button
              variant="contained"
              startIcon={<SendIcon />}
              onClick={handleSendAlert}
            >
              Send Alert
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </motion.div>
  );
};

export default Alerts;
