import { Router } from 'express';

const router = Router();

// Charity routes
router.get('/', (req, res) => {
  res.json({ message: 'Get all charities' });
});

router.post('/', (req, res) => {
  res.json({ message: 'Create charity' });
});

router.get('/:id', (req, res) => {
  res.json({ message: `Get charity ${req.params.id}` });
});

router.put('/:id', (req, res) => {
  res.json({ message: `Update charity ${req.params.id}` });
});

export default router;
