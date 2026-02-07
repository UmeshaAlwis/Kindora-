import { Router } from 'express';

const router = Router();

// Message routes
router.get('/', (req, res) => {
  res.json({ message: 'Get all messages' });
});

router.post('/', (req, res) => {
  res.json({ message: 'Create message' });
});

export default router;
