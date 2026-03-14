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
} from '@mui/material';
import MessageIcon from '@mui/icons-material/Message';
import SearchIcon from '@mui/icons-material/Search';
import VisibilityIcon from '@mui/icons-material/Visibility';
import SendIcon from '@mui/icons-material/Send';
import DeleteIcon from '@mui/icons-material/Delete';
import toast from 'react-hot-toast';

const Messages = () => {
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [replyDialogOpen, setReplyDialogOpen] = useState(false);
  const [selectedMessage, setSelectedMessage] = useState(null);
  const [replyText, setReplyText] = useState('');

  useEffect(() => {
    fetchMessages();
  }, []);

  const fetchMessages = async () => {
    try {
      setLoading(true);
      // In a real app, this would be a messages table
      // For now, we'll create mock data structure
      const mockMessages = [
        {
          id: '1',
          sender_name: 'John Smith',
          sender_email: 'john@example.com',
          subject: 'Campaign Inquiry',
          message: 'I would like to contribute to your education campaign.',
          status: 'unread',
          created_at: new Date().toISOString(),
        },
        {
          id: '2',
          sender_name: 'Jane Doe',
          sender_email: 'jane@example.com',
          subject: 'Partnership Opportunity',
          message:
            'We are interested in partnering with your organization for the upcoming campaign.',
          status: 'read',
          created_at: new Date(Date.now() - 3600000).toISOString(),
        },
      ];
      setMessages(mockMessages);
    } catch (err) {
      toast.error('Failed to fetch messages');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleViewMessage = (message) => {
    setSelectedMessage(message);
    setViewDialogOpen(true);
    // Mark as read
    if (message.status === 'unread') {
      const updated = messages.map((m) =>
        m.id === message.id ? { ...m, status: 'read' } : m
      );
      setMessages(updated);
    }
  };

  const handleReplyClick = () => {
    setViewDialogOpen(false);
    setReplyDialogOpen(true);
  };

  const handleSendReply = () => {
    if (!replyText.trim()) {
      toast.error('Please enter a message');
      return;
    }
    toast.success('Reply sent to ' + selectedMessage.sender_email);
    setReplyText('');
    setReplyDialogOpen(false);
  };

  const handleDeleteMessage = async (id) => {
    if (!window.confirm('Delete this message?')) return;
    try {
      const updated = messages.filter((m) => m.id !== id);
      setMessages(updated);
      toast.success('Message deleted');
    } catch (err) {
      toast.error('Failed to delete message');
    }
  };

  const filteredMessages = messages.filter(
    (m) =>
      (m?.sender_name || '').toLowerCase().includes(search.toLowerCase()) ||
      (m?.subject || '').toLowerCase().includes(search.toLowerCase())
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
        <Box mb={4}>
          <Typography variant="h4" fontWeight={800} color="text.primary">
            Messages
          </Typography>
          <Typography variant="body2" color="text.secondary" mt={1}>
            Manage communication from donors and partners
          </Typography>
        </Box>

        <Card sx={{ p: 3, mb: 3 }}>
          <TextField
            fullWidth
            placeholder="Search messages..."
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
                  <TableCell fontWeight={800}>From</TableCell>
                  <TableCell>Subject</TableCell>
                  <TableCell>Email</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Date</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredMessages.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                      <Box display="flex" flexDirection="column" alignItems="center" gap={1}>
                        <MessageIcon sx={{ fontSize: 40, color: 'text.disabled' }} />
                        <Typography color="text.secondary">No messages found</Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredMessages.map((msg) => (
                    <TableRow key={msg.id} hover>
                      <TableCell fontWeight={600}>{msg.sender_name}</TableCell>
                      <TableCell>
                        <Typography
                          variant="body2"
                          fontWeight={msg.status === 'unread' ? 700 : 400}
                        >
                          {msg.subject}
                        </Typography>
                      </TableCell>
                      <TableCell>{msg.sender_email}</TableCell>
                      <TableCell>
                        <Chip
                          label={msg.status}
                          color={msg.status === 'unread' ? 'warning' : 'default'}
                          variant="outlined"
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="caption">
                          {new Date(msg.created_at).toLocaleDateString()}
                        </Typography>
                      </TableCell>
                      <TableCell align="right">
                        <Button
                          size="small"
                          variant="outlined"
                          startIcon={<VisibilityIcon />}
                          onClick={() => handleViewMessage(msg)}
                          sx={{ mr: 1 }}
                        >
                          View
                        </Button>
                        <Button
                          size="small"
                          variant="outlined"
                          color="error"
                          startIcon={<DeleteIcon />}
                          onClick={() => handleDeleteMessage(msg.id)}
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

        <Dialog open={viewDialogOpen} onClose={() => setViewDialogOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Message Details</DialogTitle>
          <DialogContent>
            {selectedMessage && (
              <Box display="flex" flexDirection="column" gap={2} pt={2}>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    From
                  </Typography>
                  <Typography fontWeight={600}>{selectedMessage.sender_name}</Typography>
                  <Typography variant="body2">{selectedMessage.sender_email}</Typography>
                </Box>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Subject
                  </Typography>
                  <Typography fontWeight={600}>{selectedMessage.subject}</Typography>
                </Box>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Message
                  </Typography>
                  <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap', mt: 1 }}>
                    {selectedMessage.message}
                  </Typography>
                </Box>
              </Box>
            )}
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setViewDialogOpen(false)}>Close</Button>
            <Button
              variant="contained"
              startIcon={<SendIcon />}
              onClick={handleReplyClick}
            >
              Reply
            </Button>
          </DialogActions>
        </Dialog>

        <Dialog open={replyDialogOpen} onClose={() => setReplyDialogOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Reply to {selectedMessage?.sender_name}</DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" gap={2} pt={2}>
              <TextField
                label="Subject"
                fullWidth
                value={`RE: ${selectedMessage?.subject || ''}`}
                disabled
              />
              <TextField
                label="Your Reply"
                fullWidth
                multiline
                rows={6}
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                placeholder="Type your reply here..."
              />
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setReplyDialogOpen(false)}>Cancel</Button>
            <Button variant="contained" onClick={handleSendReply}>
              Send Reply
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </motion.div>
  );
};

export default Messages;
