import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { logger } from '../../utils/logger';

/**
 * 外部 API 客戶端基礎類
 */
export class ApiClient {
  protected readonly client: AxiosInstance;
  protected readonly baseURL: string;
  protected readonly apiKey?: string;

  constructor(baseURL: string, apiKey?: string) {
    this.baseURL = baseURL;
    this.apiKey = apiKey;

    this.client = axios.create({
      baseURL,
      timeout: 5000,
      headers: {
        'Content-Type': 'application/json',
        ...(apiKey && { 'X-RapidAPI-Key': apiKey })
      }
    });

    // 添加響應攔截器用於日誌記錄
    this.client.interceptors.response.use(
      (response) => {
        logger.debug(`API call successful: ${response.config.url}`);
        return response;
      },
      (error) => {
        logger.error(`API call failed: ${error.config?.url}, Error: ${error.message}`);
        throw error;
      }
    );
  }

  /**
   * 執行 GET 請求
   */
  protected async get<T>(path: string, params?: any): Promise<T> {
    try {
      const response: AxiosResponse<T> = await this.client.get(path, { params });
      return response.data;
    } catch (error: any) {
      logger.error(`GET request failed: ${path}, Error: ${error.message}`);
      throw error;
    }
  }

  /**
   * 執行 POST 請求
   */
  protected async post<T>(path: string, data?: any): Promise<T> {
    try {
      const response: AxiosResponse<T> = await this.client.post(path, data);
      return response.data;
    } catch (error: any) {
      logger.error(`POST request failed: ${path}, Error: ${error.message}`);
      throw error;
    }
  }
} 