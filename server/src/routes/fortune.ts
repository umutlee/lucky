import express from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { validateDateParam } from '../middleware/validators';
import { FortuneService } from '../services/fortune-service';

const router = express.Router();
const fortuneService = FortuneService.getInstance();

// 獲取每日運勢
router.get('/daily/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const fortune = await fortuneService.getDailyFortune(date);
    res.json(fortune);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// 獲取學業運勢
router.get('/study/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const fortune = await fortuneService.getStudyFortune(date);
    res.json(fortune);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// 獲取事業運勢
router.get('/career/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const fortune = await fortuneService.getCareerFortune(date);
    res.json(fortune);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// 獲取愛情運勢
router.get('/love/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const fortune = await fortuneService.getLoveFortune(date);
    res.json(fortune);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router; 