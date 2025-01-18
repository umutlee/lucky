import { Request, Response, NextFunction } from 'express';

export const validateDateParam = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { date } = req.params;
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  
  if (!dateRegex.test(date)) {
    res.status(400).json({
      error: 'Invalid Date Format',
      message: 'Date must be in YYYY-MM-DD format',
      isOperational: true
    });
    return;
  }
  
  const dateObj = new Date(date);
  if (isNaN(dateObj.getTime())) {
    res.status(400).json({
      error: 'Invalid Date',
      message: 'The provided date is invalid',
      isOperational: true
    });
    return;
  }
  
  next();
};

export const validateYearMonthParams = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { year, month } = req.params;
  
  const yearNum = parseInt(year, 10);
  const monthNum = parseInt(month, 10);
  
  if (isNaN(yearNum) || isNaN(monthNum) || 
      monthNum < 1 || monthNum > 12 || 
      yearNum < 1900 || yearNum > 2100) {
    res.status(400).json({
      error: 'Invalid Year or Month',
      message: 'Year must be between 1900-2100, Month must be between 1-12',
      isOperational: true
    });
    return;
  }

  next();
};

export const validateFortuneParams = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { zodiac, constellation } = req.query;
  
  const validZodiacs = [
    'rat', 'ox', 'tiger', 'rabbit', 'dragon', 'snake',
    'horse', 'goat', 'monkey', 'rooster', 'dog', 'pig'
  ];
  
  const validConstellations = [
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
  ];
  
  if (zodiac && !validZodiacs.includes(zodiac as string)) {
    res.status(400).json({
      error: 'Invalid Zodiac',
      message: 'Invalid zodiac sign provided',
      validZodiacs,
      isOperational: true
    });
    return;
  }
  
  if (constellation && !validConstellations.includes(constellation as string)) {
    res.status(400).json({
      error: 'Invalid Constellation',
      message: 'Invalid constellation sign provided',
      validConstellations,
      isOperational: true
    });
    return;
  }
  
  next();
}; 