/** source/routes/posts.ts */
import express from 'express';
import dgt_controller from '../controllers/contract'
const router = express.Router();

router.get('/deposit', dgt_controller.deposit)

export default router;