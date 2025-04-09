class StripeConfig {
  static const String publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String merchantIdentifier = 'merchant.com.xclean.app';
  
  // Configurações de moeda
  static const String currency = 'BRL';
  static const String currencySymbol = 'R\$';
  
  // Configurações de comissão
  static const double platformFeePercentage = 0.10; // 10% de comissão
  static const int platformFeeMinimum = 500; // R$ 5,00 mínimo
  
  // Configurações de pagamento
  static const bool requireShipping = false;
  static const bool requireBillingAddress = true;
  static const bool requirePhoneNumber = true;
  
  // Configurações de parcelas
  static const int maxInstallments = 12;
  static const int minInstallmentValue = 5000; // R$ 50,00
  
  // Configurações de reembolso
  static const int refundPeriodDays = 7;
  static const double refundFeePercentage = 0.05; // 5% de taxa de reembolso
} 