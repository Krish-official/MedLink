import { Request, Response, NextFunction } from 'express';
import { validationResult } from 'express-validator';
import { ResponseUtil } from '../utils/response.util';

export const validate = (req: Request, res: Response, next: NextFunction) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return ResponseUtil.error(
      res,
      'Validation failed',
      errors.array(),
      400
    );
  }

  next();
};