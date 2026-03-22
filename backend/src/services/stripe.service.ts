import Stripe from 'stripe';
import Logger from '../utils/logger';

const logger = new Logger('StripeService');

export interface StripePaymentRequest {
  amount: number; // smallest currency unit (e.g. cents for LKR/USD)
  currency: string;
  description: string;
  customerEmail: string;
  customerName: string;
  successUrl: string;
  cancelUrl: string;
  metadata?: Record<string, any>;
}

export interface StripePaymentResponse {
  success: boolean;
  sessionId?: string;
  clientSecret?: string;
  paymentUrl?: string;
  error?: string;
}

export interface StripeWebhookPayload {
  type: string;
  data: {
    object: {
      id: string;
      amount: number;
      currency: string;
      status: string;
      metadata?: Record<string, any>;
      payment_intent?: string;
    };
  };
}

export class StripeService {
  private static stripe: Stripe;

  /**
   * Initialize Stripe
   */
  static initialize() {
    const secretKey = process.env.STRIPE_SECRET_KEY;
    if (!secretKey) {
      throw new Error('STRIPE_SECRET_KEY not configured in environment variables');
    }

    this.stripe = new Stripe(secretKey);

    logger.info('✓ Stripe initialized');
    return this.stripe;
  }

  /**
   * Get Stripe instance
   */
  static getInstance(): Stripe {
    if (!this.stripe) {
      return this.initialize();
    }
    return this.stripe;
  }

  /**
   * Create payment intent (for server-side payment)
   */
  static async createPaymentIntent(request: StripePaymentRequest) {
    try {
      const stripe = this.getInstance();

      const paymentIntent = await stripe.paymentIntents.create({
        amount: request.amount, // Amount in cents
        currency: request.currency.toLowerCase(),
        description: request.description,
        receipt_email: request.customerEmail,
        metadata: {
          customerName: request.customerName,
          ...request.metadata,
        },
      });

      logger.info(`Payment intent created: ${paymentIntent.id}`);

      return {
        success: true,
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      };
    } catch (error) {
      logger.error('Payment intent creation failed:', error);
      return {
        success: false,
        error: (error as any).message,
      };
    }
  }

  /**
   * Create checkout session (for hosted payment page)
   */
  static async createCheckoutSession(request: StripePaymentRequest) {
    try {
      const stripe = this.getInstance();

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: [
          {
            price_data: {
              currency: request.currency.toLowerCase(),
              product_data: {
                name: request.description,
              },
              unit_amount: request.amount,
            },
            quantity: 1,
          },
        ],
        mode: 'payment',
        success_url: request.successUrl,
        cancel_url: request.cancelUrl,
        customer_email: request.customerEmail,
        metadata: request.metadata,
      });

      logger.info(`Checkout session created: ${session.id}`);

      return {
        success: true,
        sessionId: session.id,
        paymentUrl: session.url,
      };
    } catch (error) {
      logger.error('Checkout session creation failed:', error);
      return {
        success: false,
        error: (error as any).message,
      };
    }
  }

  /**
   * Retrieve payment intent
   */
  static async retrievePaymentIntent(paymentIntentId: string) {
    try {
      const stripe = this.getInstance();
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      return paymentIntent;
    } catch (error) {
      logger.error(`Failed to retrieve payment intent ${paymentIntentId}:`, error);
      throw error;
    }
  }

  /**
   * Verify webhook signature
   */
  static verifyWebhookSignature(body: string, signature: string): StripeWebhookPayload | null {
    try {
      const stripe = this.getInstance();
      const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

      if (!webhookSecret) {
        throw new Error('STRIPE_WEBHOOK_SECRET not configured');
      }

      const event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
      return event as any;
    } catch (error) {
      logger.error('Webhook signature verification failed:', error);
      return null;
    }
  }

  /**
   * Handle payment success webhook
   */
  static async handlePaymentSuccess(paymentIntentId: string) {
    try {
      const paymentIntent = await this.retrievePaymentIntent(paymentIntentId);

      logger.info(`Payment successful: ${paymentIntentId}`, {
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        status: paymentIntent.status,
        metadata: paymentIntent.metadata,
      });

      return paymentIntent;
    } catch (error) {
      logger.error(`Payment success handling failed for ${paymentIntentId}:`, error);
      throw error;
    }
  }

  /**
   * Refund a payment
   */
  static async refundPayment(paymentIntentId: string, amount?: number) {
    try {
      const stripe = this.getInstance();

      const refund = await stripe.refunds.create({
        payment_intent: paymentIntentId,
        ...(amount && { amount }),
      });

      logger.info(`Refund created: ${refund.id}`);
      return refund;
    } catch (error) {
      logger.error(`Refund failed for ${paymentIntentId}:`, error);
      throw error;
    }
  }

  /**
   * Create subscription (for recurring donations)
   */
  static async createSubscription(
    customerId: string,
    priceId: string,
    metadata?: Record<string, any>
  ) {
    try {
      const stripe = this.getInstance();

      const subscription = await stripe.subscriptions.create({
        customer: customerId,
        items: [{ price: priceId }],
        metadata,
      });

      logger.info(`Subscription created: ${subscription.id}`);
      return subscription;
    } catch (error) {
      logger.error('Subscription creation failed:', error);
      throw error;
    }
  }

  /**
   * Get publishable key (for frontend)
   */
  static getPublishableKey(): string {
    const key = process.env.STRIPE_PUBLISHABLE_KEY;
    if (!key) {
      throw new Error('STRIPE_PUBLISHABLE_KEY not configured');
    }
    return key;
  }
}
