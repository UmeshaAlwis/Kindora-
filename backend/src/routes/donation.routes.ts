import { Router } from 'express';

const router = Router();

// Donation routes
router.get('/', (req, res) => {
  res.json({ message: 'Get all donations' });
});

router.post('/', (req, res) => {
  res.json({ message: 'Create donation' });
});

router.get('/:id', (req, res) => {
  res.json({ message: `Get donation ${req.params.id}` });
});

export default router;
