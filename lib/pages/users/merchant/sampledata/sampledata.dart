import 'dart:convert';

var transaction = jsonEncode({
  "transactions": [
    {
      "transactionId": "TXN9876543210",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325001",
      "invoiceNumber": "INV202503250123",
      "timestamp": "2025-03-25T14:30:00+05:30",
      "status": "Completed",
      "transactionType": "Sale",
      "entryMode": "Chip",
      "settlementStatus": "Settled",
      "amount": {"currency": "INR", "value": 25000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {
          "brand": "RuPay",
          "last4": "5678",
          "expiryDate": "2027-09",
          "issuerBank": "State Bank of India",
          "cardType": "Debit",
          "cardholderName": "Amit Sharma"
        }
      },
      "authorization": {
        "authCode": "AUTH456789",
        "transactionReference": "REF123456789",
        "gateway": "Razorpay",
        "rrn": "123456789012",
        "stan": "654321",
        "mode": "Online"
      },
      "fees": {
        "serviceFee": {"currency": "INR", "value": 50.00},
        "processingFee": {"currency": "INR", "value": 25.00},
        "networkFee": {"currency": "INR", "value": 15.00}
      },
      "total": {
        "subtotal": {"currency": "INR", "value": 25000.00},
        "fees": {"currency": "INR", "value": 90.00},
        "grandTotal": {"currency": "INR", "value": 25090.00}
      },
      "settlement": {
        "batchId": "SETTLE20250325001",
        "settlementDate": "2025-03-26",
        "processedBy": "HDFC Bank",
        "settlementAmount": {"currency": "INR", "value": 24900.00}
      }
    },
    {
      "transactionId": "TXN9876543211",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325002",
      "invoiceNumber": "INV202503250124",
      "timestamp": "2025-03-25T15:00:00+05:30",
      "status": "Failed",
      "failureReason": "Insufficient Funds",
      "transactionType": "Sale",
      "entryMode": "Chip",
      "settlementStatus": "Not Settled",
      "amount": {"currency": "INR", "value": 5000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {
          "brand": "Visa",
          "last4": "1234",
          "expiryDate": "2025-06",
          "issuerBank": "HDFC Bank",
          "cardType": "Credit",
          "cardholderName": "Rahul Verma"
        }
      },
      "authorization": {
        "authCode": null,
        "transactionReference": "REF987654321",
        "gateway": "Paytm",
        "rrn": "987654321012",
        "stan": "765432",
        "mode": "Online"
      }
    },
    {
      "transactionId": "TXN9876543213",
      "originalTransactionId": "TXN9876543210",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325004",
      "invoiceNumber": "INV202503250126",
      "timestamp": "2025-03-25T16:00:00+05:30",
      "status": "Refunded",
      "transactionType": "Refund",
      "entryMode": "Online",
      "amount": {"currency": "INR", "value": 5000.00},
      "paymentMethod": {"type": "UPI", "upiId": "customer@upi"},
      "authorization": {
        "authCode": "AUTH987654",
        "transactionReference": "REF987654323",
        "gateway": "PhonePe",
        "rrn": "987654321345",
        "stan": "123456",
        "mode": "Online"
      },
      "fees": {
        "serviceFee": {"currency": "INR", "value": -50.00},
        "processingFee": {"currency": "INR", "value": -25.00}
      },
      "total": {
        "subtotal": {"currency": "INR", "value": -5000.00},
        "fees": {"currency": "INR", "value": -75.00},
        "grandTotal": {"currency": "INR", "value": -5075.00}
      },
      "settlement": {
        "batchId": "SETTLE20250325002",
        "settlementDate": "2025-03-26",
        "processedBy": "ICICI Bank",
        "settlementAmount": {"currency": "INR", "value": -5000.00}
      }
    },
    {
      "transactionId": "TXN9876543214",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325005",
      "invoiceNumber": "INV202503250127",
      "timestamp": "2025-03-25T16:30:00+05:30",
      "status": "Voided",
      "transactionType": "Void",
      "entryMode": "Chip",
      "amount": {"currency": "INR", "value": 12000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {"brand": "Visa", "last4": "6789", "issuerBank": "Axis Bank"}
      },
      "authorization": {
        "authCode": null,
        "transactionReference": "REF987654324",
        "gateway": "Paytm",
        "rrn": "876543210999",
        "stan": "987654",
        "mode": "Online"
      },
      "settlement": {
        "batchId": null,
        "settlementDate": null,
        "settlementAmount": {"currency": "INR", "value": 0.00}
      }
    },
    {
      "transactionId": "TXN9876543215",
      "originalTransactionId": "TXN9876543210",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325006",
      "invoiceNumber": "INV202503250128",
      "timestamp": "2025-03-25T17:00:00+05:30",
      "status": "Chargeback",
      "transactionType": "Chargeback",
      "reason": "Customer claims fraud",
      "amount": {"currency": "INR", "value": 25000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {"brand": "Visa", "last4": "5678", "issuerBank": "HDFC Bank"}
      },
      "authorization": {
        "authCode": "AUTH876543",
        "transactionReference": "REF987654325",
        "gateway": "Razorpay",
        "rrn": "123456789567",
        "stan": "654321",
        "mode": "Online"
      },
      "fees": {
        "chargebackFee": {"currency": "INR", "value": 500.00}
      },
      "total": {
        "subtotal": {"currency": "INR", "value": -25000.00},
        "fees": {"currency": "INR", "value": -500.00},
        "grandTotal": {"currency": "INR", "value": -25500.00}
      },
      "settlement": {
        "batchId": "SETTLE20250325003",
        "settlementDate": "2025-03-27",
        "processedBy": "HDFC Bank",
        "settlementAmount": {"currency": "INR", "value": -25000.00}
      }
    },
    {
      "transactionId": "TXN9876543210",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325001",
      "invoiceNumber": "INV202503250123",
      "timestamp": "2025-03-25T14:30:00+05:30",
      "status": "Completed",
      "transactionType": "Sale",
      "entryMode": "Chip",
      "settlementStatus": "Settled",
      "amount": {"currency": "INR", "value": 25000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {
          "brand": "RuPay",
          "last4": "5678",
          "expiryDate": "2027-09",
          "issuerBank": "State Bank of India",
          "cardType": "Debit",
          "cardholderName": "Amit Sharma"
        }
      },
      "authorization": {
        "authCode": "AUTH456789",
        "transactionReference": "REF123456789",
        "gateway": "Razorpay",
        "rrn": "123456789012",
        "stan": "654321",
        "mode": "Online"
      },
      "fees": {
        "serviceFee": {"currency": "INR", "value": 50.00},
        "processingFee": {"currency": "INR", "value": 25.00},
        "networkFee": {"currency": "INR", "value": 15.00}
      },
      "total": {
        "subtotal": {"currency": "INR", "value": 25000.00},
        "fees": {"currency": "INR", "value": 90.00},
        "grandTotal": {"currency": "INR", "value": 25090.00}
      },
      "settlement": {
        "batchId": "SETTLE20250325001",
        "settlementDate": "2025-03-26",
        "processedBy": "HDFC Bank",
        "settlementAmount": {"currency": "INR", "value": 24900.00}
      }
    },
    {
      "transactionId": "TXN9876543211",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325002",
      "invoiceNumber": "INV202503250124",
      "timestamp": "2025-03-25T15:00:00+05:30",
      "status": "Failed",
      "failureReason": "Insufficient Funds",
      "transactionType": "Sale",
      "entryMode": "Chip",
      "settlementStatus": "Not Settled",
      "amount": {"currency": "INR", "value": 5000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {
          "brand": "Visa",
          "last4": "1234",
          "expiryDate": "2025-06",
          "issuerBank": "HDFC Bank",
          "cardType": "Credit",
          "cardholderName": "Rahul Verma"
        }
      },
      "authorization": {
        "authCode": null,
        "transactionReference": "REF987654321",
        "gateway": "Paytm",
        "rrn": "987654321012",
        "stan": "765432",
        "mode": "Online"
      }
    },
    {
      "transactionId": "TXN9876543213",
      "originalTransactionId": "TXN9876543210",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325004",
      "invoiceNumber": "INV202503250126",
      "timestamp": "2025-03-25T16:00:00+05:30",
      "status": "Refunded",
      "transactionType": "Refund",
      "entryMode": "Online",
      "amount": {"currency": "INR", "value": 5000.00},
      "paymentMethod": {"type": "UPI", "upiId": "customer@upi"},
      "authorization": {
        "authCode": "AUTH987654",
        "transactionReference": "REF987654323",
        "gateway": "PhonePe",
        "rrn": "987654321345",
        "stan": "123456",
        "mode": "Online"
      },
      "fees": {
        "serviceFee": {"currency": "INR", "value": -50.00},
        "processingFee": {"currency": "INR", "value": -25.00}
      },
      "total": {
        "subtotal": {"currency": "INR", "value": -5000.00},
        "fees": {"currency": "INR", "value": -75.00},
        "grandTotal": {"currency": "INR", "value": -5075.00}
      },
      "settlement": {
        "batchId": "SETTLE20250325002",
        "settlementDate": "2025-03-26",
        "processedBy": "ICICI Bank",
        "settlementAmount": {"currency": "INR", "value": -5000.00}
      }
    },
    {
      "transactionId": "TXN9876543214",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325005",
      "invoiceNumber": "INV202503250127",
      "timestamp": "2025-03-25T16:30:00+05:30",
      "status": "Voided",
      "transactionType": "Void",
      "entryMode": "Chip",
      "amount": {"currency": "INR", "value": 12000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {"brand": "Visa", "last4": "6789", "issuerBank": "Axis Bank"}
      },
      "authorization": {
        "authCode": null,
        "transactionReference": "REF987654324",
        "gateway": "Paytm",
        "rrn": "876543210999",
        "stan": "987654",
        "mode": "Online"
      },
      "settlement": {
        "batchId": null,
        "settlementDate": null,
        "settlementAmount": {"currency": "INR", "value": 0.00}
      }
    },
    {
      "transactionId": "TXN9876543215",
      "originalTransactionId": "TXN9876543210",
      "merchantId": "MID123456789",
      "terminalId": "TID987654321",
      "batchNumber": "BATCH20250325006",
      "invoiceNumber": "INV202503250128",
      "timestamp": "2025-03-25T17:00:00+05:30",
      "status": "Chargeback",
      "transactionType": "Chargeback",
      "reason": "Customer claims fraud",
      "amount": {"currency": "INR", "value": 25000.00},
      "paymentMethod": {
        "type": "Credit Card",
        "card": {"brand": "Visa", "last4": "5678", "issuerBank": "HDFC Bank"}
      },
      "authorization": {
        "authCode": "AUTH876543",
        "transactionReference": "REF987654325",
        "gateway": "Razorpay",
        "rrn": "123456789567",
        "stan": "654321",
        "mode": "Online"
      },
      "fees": {
        "chargebackFee": {"currency": "INR", "value": 500.00}
      },
      "total": {
        "subtotal": {"currency": "INR", "value": -25000.00},
        "fees": {"currency": "INR", "value": -500.00},
        "grandTotal": {"currency": "INR", "value": -25500.00}
      },
      "settlement": {
        "batchId": "SETTLE20250325003",
        "settlementDate": "2025-03-27",
        "processedBy": "HDFC Bank",
        "settlementAmount": {"currency": "INR", "value": -25000.00}
      }
    }
  ]
});
