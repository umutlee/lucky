import express from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { validateDateParam, validateYearMonthParams } from '../middleware/validators';
import { AlmanacService } from '../services/almanac-service';
import { logger } from '../utils/logger';

const router = express.Router();
const almanacService = AlmanacService.getInstance();

// 獲取每日黃曆
router.get('/daily/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    logger.info(`Fetching daily almanac for date: ${date}`);
    
    const almanac = await almanacService.getDailyAlmanac(date);
    res.json(almanac);
  } catch (error) {
    logger.error('Error fetching daily almanac:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

// 獲取月曆
router.get('/monthly/:year/:month', validateYearMonthParams, async (req: AuthenticatedRequest, res) => {
  try {
    const { year, month } = req.params;
    logger.info(`Fetching monthly almanac for year: ${year}, month: ${month}`);
    
    const monthlyAlmanac = await almanacService.getMonthlyAlmanac(
      parseInt(year, 10),
      parseInt(month, 10)
    );
    res.json(monthlyAlmanac);
  } catch (error) {
    logger.error('Error fetching monthly almanac:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

// 獲取節氣信息
router.get('/solar-terms/:year', async (req: AuthenticatedRequest, res) => {
  try {
    const { year } = req.params;
    logger.info(`Fetching solar terms for year: ${year}`);
    
    const solarTerms = await almanacService.getSolarTerms(parseInt(year, 10));
    res.json(solarTerms);
  } catch (error) {
    logger.error('Error fetching solar terms:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

// 獲取農曆日期
router.get('/lunar-date/:date', validateDateParam, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    logger.info(`Converting date to lunar date: ${date}`);
    
    const lunarDate = await almanacService.getLunarDate(date);
    res.json(lunarDate);
  } catch (error) {
    logger.error('Error converting to lunar date:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

export default router; 