import express from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { validateDateParam, validateFortuneParams } from '../middleware/validators';
import { FortuneService } from '../services/fortune-service';
import { logger } from '../utils/logger';

const router = express.Router();
const fortuneService = FortuneService.getInstance();

// 獲取每日運勢
router.get('/daily/:date', validateDateParam, validateFortuneParams, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const { zodiac, constellation } = req.query;
    
    const fortune = await fortuneService.getDailyFortune(
      date,
      zodiac as string || '',
      constellation as string || ''
    );
    
    logger.info(`Daily fortune calculated for date: ${date}, zodiac: ${zodiac}, constellation: ${constellation}`);
    res.json(fortune);
  } catch (error) {
    logger.error('Error calculating daily fortune:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

// 獲取學業運勢
router.get('/study/:date', validateDateParam, validateFortuneParams, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const { zodiac, constellation } = req.query;
    
    const fortune = await fortuneService.getStudyFortune(
      date,
      zodiac as string || '',
      constellation as string || ''
    );
    
    logger.info(`Study fortune calculated for date: ${date}, zodiac: ${zodiac}, constellation: ${constellation}`);
    res.json(fortune);
  } catch (error) {
    logger.error('Error calculating study fortune:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

// 獲取事業運勢
router.get('/career/:date', validateDateParam, validateFortuneParams, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const { zodiac, constellation } = req.query;
    
    const fortune = await fortuneService.getCareerFortune(
      date,
      zodiac as string || '',
      constellation as string || ''
    );
    
    logger.info(`Career fortune calculated for date: ${date}, zodiac: ${zodiac}, constellation: ${constellation}`);
    res.json(fortune);
  } catch (error) {
    logger.error('Error calculating career fortune:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

// 獲取愛情運勢
router.get('/love/:date', validateDateParam, validateFortuneParams, async (req: AuthenticatedRequest, res) => {
  try {
    const { date } = req.params;
    const { zodiac, constellation } = req.query;
    
    const fortune = await fortuneService.getLoveFortune(
      date,
      zodiac as string || '',
      constellation as string || ''
    );
    
    logger.info(`Love fortune calculated for date: ${date}, zodiac: ${zodiac}, constellation: ${constellation}`);
    res.json(fortune);
  } catch (error) {
    logger.error('Error calculating love fortune:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
      isOperational: true
    });
  }
});

export default router; 