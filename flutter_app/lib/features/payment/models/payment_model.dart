class Campaign {
  final String id;
  final String title;
  final String image;
  final double raisedAmount;
  final double targetAmount;
  final String description;

  Campaign({
    required this.id,
    required this.title,
    required this.image,
    required this.raisedAmount,
    required this.targetAmount,
    required this.description,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final String icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class Payment {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final double amount;
  final String paymentMethod;
  final DateTime timestamp;
  final String status;
  final String donorName;
  final String donorEmail;

  Payment({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
    required this.status,
    required this.donorName,
    required this.donorEmail,
  });
}
