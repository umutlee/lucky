import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { validateApiKey } from './middleware/auth';
import { errorHandler, notFoundHandler } from './middleware/error-handler';
import fortuneRoutes from './routes/fortune';
import almanacRoutes from './routes/almanac';

// 加載環境變量
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// 中間件
app.use(express.json());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
}));

// API 路由
app.use('/api/v1/fortune', validateApiKey, fortuneRoutes);
app.use('/api/v1/almanac', validateApiKey, almanacRoutes);

// 健康檢查端點
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 處理
app.use(notFoundHandler);

// 錯誤處理
app.use(errorHandler);

// 啟動服務器
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
}); 