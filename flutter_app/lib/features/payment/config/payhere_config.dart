/// PayHere Payment Gateway Configuration
/// Configured with actual sandbox merchant credentials
class PayHereConfig {
  // Sandbox Configuration (Testing)
  static const String sandboxMerchantId = '1216572';
  static const String sandboxMerchantSecret =
      'OTgxNjU2MjA0MTM2OTUwODIzMjExOTAzNDU3Nzc1MjE3NzYzNDc=';

  // Production Configuration (Live) - Update after testing
  static const String productionMerchantId = '1216572';
  static const String productionMerchantSecret =
      'OTgxNjU2MjA0MTM2OTUwODIzMjExOTAzNDU3Nzc1MjE3NzYzNDc=';

  // Environment
  static const bool isProduction = false; // Set to true for production

  // PayHere URLs
  static const String sandboxCheckoutUrl =
      'https://sandbox.payhere.lk/pay/checkout';
  static const String productionCheckoutUrl =
      'https://www.payhere.lk/pay/checkout';

  // Callback URLs (configure in PayHere dashboard)
  static const String sandboxReturnUrl = 'https://kindora.lk/payment/return';
  static const String sandboxNotifyUrl = 'https://kindora.lk/payment/notify';
  static const String sandboxCancelUrl = 'https://kindora.lk/payment/cancel';

  static const String productionReturnUrl = 'https://kindora.lk/payment/return';
  static const String productionNotifyUrl = 'https://kindora.lk/payment/notify';
  static const String productionCancelUrl = 'https://kindora.lk/payment/cancel';

  // Getters for current environment
  static String get merchantId =>
      isProduction ? productionMerchantId : sandboxMerchantId;

  static String get merchantSecret =>
      isProduction ? productionMerchantSecret : sandboxMerchantSecret;

  static String get checkoutUrl =>
      isProduction ? productionCheckoutUrl : sandboxCheckoutUrl;

  static String get returnUrl =>
      isProduction ? productionReturnUrl : sandboxReturnUrl;

  static String get notifyUrl =>
      isProduction ? productionNotifyUrl : sandboxNotifyUrl;

  static String get cancelUrl =>
      isProduction ? productionCancelUrl : sandboxCancelUrl;

  static String get environmentName => isProduction ? 'Production' : 'Sandbox';

  static const String appName = 'Kindora - Charity Platform';
  static const String currency = 'LKR';
}
