class BillPaymentModel {
  final String id;
  final String billId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? reference;
  final String? note;

  BillPaymentModel({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.reference,
    this.note,
  });

  // Factory methods and toMap/fromMap implementations
} 