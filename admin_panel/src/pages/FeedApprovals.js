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
  TextareaAutosize,
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import SearchIcon from '@mui/icons-material/Search';
import InfoIcon from '@mui/icons-material/Info';
import VisibilityIcon from '@mui/icons-material/Visibility';
import toast from 'react-hot-toast';

const FeedApprovals = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [selectedPost, setSelectedPost] = useState(null);

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = async () => {
    try {
      setLoading(true);
      // Mock data for ended campaign posts awaiting approval
      const mockPosts = [
        {
          id: '1',
          campaign_name: 'Build School Education Fund',
          campaign_status: 'Completed',
          post_title: 'Thank you for supporting education!',
          post_content:
            'We have successfully completed the construction of 3 new classrooms. A total of 150 students now have access to quality education facilities.',
          author: 'John Smith',
          created_at: new Date(Date.now() - 86400000).toISOString(),
          status: 'pending',
          funds_raised: 25000,
          funds_goal: 25000,
        },
        {
          id: '2',
          campaign_name: 'Clean Water Initiative',
          campaign_status: 'Completed',
          post_title: 'Water project impact report',
          post_content:
            'Over 500 families now have access to clean drinking water. The community has reported a 40% decrease in water-borne illnesses.',
          author: 'Jane Doe',
          created_at: new Date(Date.now() - 172800000).toISOString(),
          status: 'pending',
          funds_raised: 15000,
          funds_goal: 15000,
        },
        {
          id: '3',
          campaign_name: 'Medical Camp Program',
          campaign_status: 'Completed',
          post_title: 'Medical camp conclusion report',
          post_content:
            'Successfully conducted medical camps in 5 villages. Provided free medical checkups to over 1000 patients.',
          author: 'Dr. Anderson',
          created_at: new Date(Date.now() - 259200000).toISOString(),
          status: 'pending',
          funds_raised: 18000,
          funds_goal: 18000,
        },
      ];
      setPosts(mockPosts);
    } catch (err) {
      toast.error('Failed to fetch posts');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (id) => {
    try {
      const updated = posts.map((p) =>
        p.id === id ? { ...p, status: 'approved' } : p
      );
      setPosts(updated);
      toast.success('Post approved and published to feed');
    } catch (err) {
      toast.error('Failed to approve post');
    }
  };

  const handleDecline = async (id) => {
    try {
      const updated = posts.map((p) =>
        p.id === id ? { ...p, status: 'declined' } : p
      );
      setPosts(updated);
      toast.success('Post declined');
    } catch (err) {
      toast.error('Failed to decline post');
    }
  };

  const handleViewPost = (post) => {
    setSelectedPost(post);
    setViewDialogOpen(true);
  };

  const filteredPosts = posts.filter(
    (p) =>
      (p?.post_title || '').toLowerCase().includes(search.toLowerCase()) ||
      (p?.campaign_name || '').toLowerCase().includes(search.toLowerCase())
  );

  const pendingPosts = filteredPosts.filter((p) => p.status === 'pending');
  const approvedPosts = filteredPosts.filter((p) => p.status === 'approved');
  const declinedPosts = filteredPosts.filter((p) => p.status === 'declined');

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
          <Typography variant="h4" fontWeight={800} color="text.primary" mb={2}>
            Campaign Feed Approvals
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Approve or decline posts from completed charity campaigns
          </Typography>
        </Box>

        <Box display="flex" gap={2} mb={3} flexWrap="wrap" alignItems="center">
          <TextField
            fullWidth
            sx={{ maxWidth: 400 }}
            placeholder="Search posts..."
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
            <Chip label={`Pending: ${pendingPosts.length}`} color="warning" variant="outlined" />
            <Chip label={`Approved: ${approvedPosts.length}`} color="success" variant="outlined" />
            <Chip label={`Declined: ${declinedPosts.length}`} color="error" variant="outlined" />
          </Box>
        </Box>

        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                  <TableCell fontWeight={800}>Post Title</TableCell>
                  <TableCell>Campaign</TableCell>
                  <TableCell>Author</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Date</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredPosts.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                      <Box display="flex" flexDirection="column" alignItems="center" gap={1}>
                        <InfoIcon color="disabled" sx={{ fontSize: 40 }} />
                        <Typography color="text.secondary">No posts to review</Typography>
                      </Box>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredPosts.map((post) => (
                    <TableRow
                      key={post.id}
                      hover
                      sx={{
                        backgroundColor:
                          post.status === 'pending' ? 'rgba(255, 193, 7, 0.05)' : 'transparent',
                      }}
                    >
                      <TableCell fontWeight={600}>{post.post_title}</TableCell>
                      <TableCell>{post.campaign_name}</TableCell>
                      <TableCell>{post.author}</TableCell>
                      <TableCell>
                        <Chip
                          label={post.status}
                          color={
                            post.status === 'pending'
                              ? 'warning'
                              : post.status === 'approved'
                              ? 'success'
                              : 'error'
                          }
                          variant="outlined"
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="caption">
                          {new Date(post.created_at).toLocaleDateString()}
                        </Typography>
                      </TableCell>
                      <TableCell align="right">
                        <Button
                          size="small"
                          variant="outlined"
                          startIcon={<VisibilityIcon />}
                          onClick={() => handleViewPost(post)}
                          sx={{ mr: 1 }}
                        >
                          View
                        </Button>
                        {post.status === 'pending' && (
                          <Box display="flex" gap={0.5} justifyContent="flex-end">
                            <Button
                              size="small"
                              variant="contained"
                              color="success"
                              startIcon={<CheckCircleIcon />}
                              onClick={() => handleApprove(post.id)}
                            >
                              Approve
                            </Button>
                            <Button
                              size="small"
                              variant="outlined"
                              color="error"
                              startIcon={<CancelIcon />}
                              onClick={() => handleDecline(post.id)}
                            >
                              Decline
                            </Button>
                          </Box>
                        )}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Card>

        <Dialog
          open={viewDialogOpen}
          onClose={() => setViewDialogOpen(false)}
          maxWidth="sm"
          fullWidth
        >
          <DialogTitle>Post Details</DialogTitle>
          <DialogContent>
            {selectedPost && (
              <Box display="flex" flexDirection="column" gap={2.5} pt={2}>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Campaign
                  </Typography>
                  <Typography fontWeight={600}>{selectedPost.campaign_name}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    Status: {selectedPost.campaign_status}
                  </Typography>
                </Box>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Title
                  </Typography>
                  <Typography fontWeight={600}>{selectedPost.post_title}</Typography>
                </Box>
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Post Content
                  </Typography>
                  <Typography variant="body2" sx={{ mt: 1, whiteSpace: 'pre-wrap' }}>
                    {selectedPost.post_content}
                  </Typography>
                </Box>
                <Box display="flex" gap={2}>
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Author
                    </Typography>
                    <Typography fontWeight={600}>{selectedPost.author}</Typography>
                  </Box>
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Funds Raised
                    </Typography>
                    <Typography fontWeight={600}>
                      ${selectedPost.funds_raised.toLocaleString()} / $
                      {selectedPost.funds_goal.toLocaleString()}
                    </Typography>
                  </Box>
                </Box>
              </Box>
            )}
          </DialogContent>
          <DialogActions sx={{ p: 2 }}>
            <Button onClick={() => setViewDialogOpen(false)}>Close</Button>
            {selectedPost?.status === 'pending' && (
              <>
                <Button
                  variant="contained"
                  color="error"
                  startIcon={<CancelIcon />}
                  onClick={() => {
                    handleDecline(selectedPost.id);
                    setViewDialogOpen(false);
                  }}
                >
                  Decline
                </Button>
                <Button
                  variant="contained"
                  color="success"
                  startIcon={<CheckCircleIcon />}
                  onClick={() => {
                    handleApprove(selectedPost.id);
                    setViewDialogOpen(false);
                  }}
                >
                  Approve
                </Button>
              </>
            )}
          </DialogActions>
        </Dialog>
      </Box>
    </motion.div>
  );
};

export default FeedApprovals;
