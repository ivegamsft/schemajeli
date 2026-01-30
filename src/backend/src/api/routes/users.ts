import { Router } from 'express';

const router = Router();

/**
 * @route   GET /api/v1/users
 * @desc    Get all users
 * @access  Private (Admin only)
 */
router.get('/', (req, res) => {
  res.status(501).json({ message: 'Get users - to be implemented' });
});

/**
 * @route   GET /api/v1/users/:id
 * @desc    Get user by ID
 * @access  Private
 */
router.get('/:id', (req, res) => {
  res.status(501).json({ message: 'Get user by ID - to be implemented' });
});

/**
 * @route   POST /api/v1/users
 * @desc    Create new user
 * @access  Private (Admin only)
 */
router.post('/', (req, res) => {
  res.status(501).json({ message: 'Create user - to be implemented' });
});

/**
 * @route   PUT /api/v1/users/:id
 * @desc    Update user
 * @access  Private (Admin or self)
 */
router.put('/:id', (req, res) => {
  res.status(501).json({ message: 'Update user - to be implemented' });
});

/**
 * @route   DELETE /api/v1/users/:id
 * @desc    Delete user
 * @access  Private (Admin only)
 */
router.delete('/:id', (req, res) => {
  res.status(501).json({ message: 'Delete user - to be implemented' });
});

export default router;
