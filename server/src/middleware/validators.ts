import { Request, Response, NextFunction } from 'express';
import { DateUtils } from '../utils/date-utils';

export const validateDateParam = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const date = req.params.date;
  
  if (!DateUtils.validateDateFormat(date)) {
    res.status(400).json({
      error: 'Bad Request',
      message: 'Invalid date format. Use YYYY-MM-DD'
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
  
  if (!DateUtils.validateYearMonth(year, month)) {
    res.status(400).json({
      error: 'Bad Request',
      message: 'Invalid year or month format'
    });
    return;
  }

  next();
}; 