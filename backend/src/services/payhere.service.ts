import axios, { AxiosInstance } from 'axios';
import crypto from 'crypto';
import Logger from '../utils/logger';

const logger = new Logger('PayHereService');

export interface PayHerePaymentRequest {
  orderId: string;
  amount: number;
  currency: string;
  merchantId: string;
  returnUrl: string;
  cancelUrl: string;
  notifyUrl: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  address: string;
  city: string;
  country: string;
  postalCode?: string;
  customOne?: string;
  customTwo?: string;
  customThree?: string;
}

export interface PayHereNotificationPayload {
  order_id: string;
  merchant_id: string;
  payment_id: string;
  payhere_amount: number;
  payhere_currency: string;
  status_code: number;
  status_message: string;
  authorization_id: string;
  md5sig: string;
  custom_one?: string;
  custom_two?: string;
  custom_three?: string;
}

export interface PayHerePaymentResponse {
  success: boolean;
  message?: string;
  paymentUrl?: string;
  orderId?: string;
  error?: string;
}

class PayHereService {
  private apiClient: AxiosInstance;
  private merchantId: string;
  private merchantSecret: string;
  private apiUrl: string;
  private returnUrl: string;
  private cancelUrl: string;
  private notifyUrl: string;

  constructor() {
    this.merchantId = process.env.PAYHERE_MERCHANT_ID || '';
    this.merchantSecret = process.env.PAYHERE_MERCHANT_SECRET || '';
    this.apiUrl = process.env.PAYHERE_API_URL || 'https://sandbox.payhere.lk';
    this.returnUrl = process.env.PAYHERE_RETURN_URL || `${process.env.API_URL}/payments/payhere/return`;
    this.cancelUrl = process.env.PAYHERE_CANCEL_URL || `${process.env.API_URL}/payments/payhere/cancel`;
    this.notifyUrl = process.env.PAYHERE_NOTIFY_URL || `${process.env.API_URL}/payments/payhere/notify`;

    this.apiClient = axios.create({
      baseURL: this.apiUrl,
      timeout: 10000,
    });
  }

  /**
   * Initialize a payment request
   */
  async initiatePayment(paymentData: PayHerePaymentRequest): Promise<PayHerePaymentResponse> {
    try {
      if (!this.merchantId || !this.merchantSecret) {
        logger.error('PayHere credentials not configured');
        return {
          success: false,
          error: 'Payment gateway not configured',
        };
      }

      // Generate payment URL parameters
      const paymentUrl = this.generatePaymentUrl(paymentData);

      logger.info(`Payment initiated for order: ${paymentData.orderId}`);

      return {
        success: true,
        paymentUrl,
        orderId: paymentData.orderId,
      };
    } catch (error) {
      logger.error('Error initiating payment:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Generate payment URL with security hash
   */
  private generatePaymentUrl(paymentData: PayHerePaymentRequest): string {
    const hashString = `${this.merchantId}${paymentData.orderId}${paymentData.amount}${paymentData.currency}${paymentData.firstName}${paymentData.email}${this.merchantSecret}`;
    const md5Hash = crypto.createHash('md5').update(hashString).digest('hex');

    const params = new URLSearchParams({
      merchant_id: this.merchantId,
      return_url: this.returnUrl,
      cancel_url: this.cancelUrl,
      notify_url: this.notifyUrl,
      order_id: paymentData.orderId,
      items: 'Donation',
      amount: paymentData.amount.toString(),
      currency: paymentData.currency,
      first_name: paymentData.firstName,
      last_name: paymentData.lastName,
      email: paymentData.email,
      phone: paymentData.phone,
      address: paymentData.address,
      city: paymentData.city,
      country: paymentData.country,
      ...(paymentData.customOne && { custom_1: paymentData.customOne }),
      ...(paymentData.customTwo && { custom_2: paymentData.customTwo }),
      ...(paymentData.customThree && { custom_3: paymentData.customThree }),
      hash: md5Hash,
    });

    return `${this.apiUrl}/pay/checkout?${params.toString()}`;
  }

  /**
   * Verify payment notification
   */
  verifyNotification(notification: PayHereNotificationPayload): boolean {
    try {
      // Create hash from notification data
      const hashString = `${notification.merchant_id}${notification.order_id}${notification.payhere_amount}${notification.payhere_currency}${notification.status_code}${this.merchantSecret}`;
      const expectedHash = crypto.createHash('md5').update(hashString).digest('hex');

      const isValid = expectedHash === notification.md5sig && notification.merchant_id === this.merchantId;

      if (isValid) {
        logger.info(`Payment verified for order: ${notification.order_id}`);
      } else {
        logger.warn(`Payment verification failed for order: ${notification.order_id}`);
      }

      return isValid;
    } catch (error) {
      logger.error('Error verifying notification:', error);
      return false;
    }
  }

  /**
   * Check payment status
   */
  async checkPaymentStatus(orderId: string): Promise<any> {
    try {
      const response = await this.apiClient.post('/merchant/api/payment/search/', {
        merchant_id: this.merchantId,
        order_id: orderId,
        merchant_secret: this.merchantSecret,
      });

      return response.data;
    } catch (error) {
      logger.error(`Error checking payment status for order: ${orderId}`, error);
      throw error;
    }
  }

  /**
   * Refund a payment
   */
  async refundPayment(paymentId: string, amount: number): Promise<any> {
    try {
      const response = await this.apiClient.post('/merchant/api/payment/refund/', {
        merchant_id: this.merchantId,
        payment_id: paymentId,
        amount: amount,
      });

      logger.info(`Refund processed for payment: ${paymentId}`);
      return response.data;
    } catch (error) {
      logger.error(`Error processing refund for payment: ${paymentId}`, error);
      throw error;
    }
  }

  /**
   * Get merchant details
   */
  async getMerchantDetails(): Promise<any> {
    try {
      const response = await this.apiClient.get('/merchant/api/info/', {
        params: {
          merchant_id: this.merchantId,
          merchant_secret: this.merchantSecret,
        },
      });

      return response.data;
    } catch (error) {
      logger.error('Error fetching merchant details', error);
      throw error;
    }
  }
}

export default new PayHereService();
