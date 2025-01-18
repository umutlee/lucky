import express, { Request, Response } from 'express';
import { FortuneService } from '../services/fortune-service';
import { validateApiKey, rateLimit } from '../middleware/auth';
import { validateDateParam, validateFortuneParams } from '../middleware/validators';
import { logger } from '../utils/logger';

const router = express.Router();
const fortuneService = FortuneService.getInstance();

// 將認證和請求限制中間件應用到所有路由
router.use(validateApiKey);
router.use(rateLimit);

/**
 * 獲取每日運勢
 * @route GET /api/v1/fortune/daily/:date
 */
router.get('/daily/:date', 
  validateDateParam,
  validateFortuneParams,
  async (req: Request, res: Response) => {
    try {
      const { date } = req.params;
      const { zodiac, constellation } = req.query;
      
      const fortune = await fortuneService.getDailyFortune(
        date,
        zodiac as string || '',
        constellation as string || ''
      );

      res.json(fortune);
    } catch (error: any) {
      logger.error(`Error getting daily fortune: ${error.message}`);
      res.status(500).json({
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * 獲取學業運勢
 * @route GET /api/v1/fortune/study/:date
 */
router.get('/study/:date',
  validateDateParam,
  validateFortuneParams,
  async (req: Request, res: Response) => {
    try {
      const { date } = req.params;
      const { zodiac, constellation } = req.query;
      
      const fortune = await fortuneService.getStudyFortune(
        date,
        zodiac as string || '',
        constellation as string || ''
      );

      res.json(fortune);
    } catch (error: any) {
      logger.error(`Error getting study fortune: ${error.message}`);
      res.status(500).json({
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * 獲取事業運勢
 * @route GET /api/v1/fortune/career/:date
 */
router.get('/career/:date',
  validateDateParam,
  validateFortuneParams,
  async (req: Request, res: Response) => {
    try {
      const { date } = req.params;
      const { zodiac, constellation } = req.query;
      
      const fortune = await fortuneService.getCareerFortune(
        date,
        zodiac as string || '',
        constellation as string || ''
      );

      res.json(fortune);
    } catch (error: any) {
      logger.error(`Error getting career fortune: ${error.message}`);
      res.status(500).json({
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * 獲取愛情運勢
 * @route GET /api/v1/fortune/love/:date
 */
router.get('/love/:date',
  validateDateParam,
  validateFortuneParams,
  async (req: Request, res: Response) => {
    try {
      const { date } = req.params;
      const { zodiac, constellation } = req.query;
      
      const fortune = await fortuneService.getLoveFortune(
        date,
        zodiac as string || '',
        constellation as string || ''
      );

      res.json(fortune);
    } catch (error: any) {
      logger.error(`Error getting love fortune: ${error.message}`);
      res.status(500).json({
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

export default router; 