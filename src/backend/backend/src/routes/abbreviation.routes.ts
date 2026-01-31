import { Router } from 'express';
import { AbbreviationController } from '../controllers/abbreviation.controller.js';
import { authenticate } from '../middleware/authenticate.js';
import { authorize } from '../middleware/authorize.js';

const router = Router();

// All abbreviation routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/abbreviations/stats
 * @desc    Get abbreviation statistics
 * @access  Protected (read permission)
 */
router.get(
  '/stats',
  authorize('read'),
  AbbreviationController.getAbbreviationStats
);

/**
 * @route   GET /api/v1/abbreviations/search/:abbr
 * @desc    Search abbreviation by abbreviation string
 * @access  Protected (read permission)
 */
router.get(
  '/search/:abbr',
  authorize('read'),
  AbbreviationController.searchByAbbreviation
);

/**
 * @route   POST /api/v1/abbreviations
 * @desc    Create a new abbreviation
 * @access  Protected (write permission)
 */
router.post('/', authorize('write'), AbbreviationController.createAbbreviation);

/**
 * @route   GET /api/v1/abbreviations
 * @desc    Get all abbreviations with pagination and filtering
 * @access  Protected (read permission)
 */
router.get('/', authorize('read'), AbbreviationController.getAllAbbreviations);

/**
 * @route   GET /api/v1/abbreviations/:id
 * @desc    Get abbreviation by ID
 * @access  Protected (read permission)
 */
router.get(
  '/:id',
  authorize('read'),
  AbbreviationController.getAbbreviationById
);

/**
 * @route   PUT /api/v1/abbreviations/:id
 * @desc    Update abbreviation
 * @access  Protected (write permission)
 */
router.put(
  '/:id',
  authorize('write'),
  AbbreviationController.updateAbbreviation
);

/**
 * @route   DELETE /api/v1/abbreviations/:id
 * @desc    Delete abbreviation
 * @access  Protected (delete permission)
 */
router.delete(
  '/:id',
  authorize('delete'),
  AbbreviationController.deleteAbbreviation
);

export default router;
