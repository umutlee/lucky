import express from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { validateDateParam, validateYearMonthParams } from '../middleware/validators';
import { AlmanacService } from '../services/almanac-service';

const router = express.Router();
const almanacService = AlmanacService.getInstance();

// 獲取每日黃曆
router.get('/daily/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const almanac = await almanacService.getDailyAlmanac(date);
    res.json(almanac);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// 獲取月曆
router.get('/monthly/:year/:month', validateYearMonthParams, async (req: AuthenticatedRequest, res) => {
  try {
    const { year, month } = req.params;
    const monthlyAlmanac = await almanacService.getMonthlyAlmanac(year, month);
    res.json(monthlyAlmanac);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// 獲取節氣信息
router.get('/solar-terms/:year', async (req: AuthenticatedRequest, res) => {
  try {
    const { year } = req.params;
    const solarTerms = await almanacService.getSolarTerms(year);
    res.json(solarTerms);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// 獲取農曆日期
router.get('/lunar-date/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const lunarDate = await almanacService.getLunarDate(date);
    res.json(lunarDate);
  } catch (error) {
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router; 