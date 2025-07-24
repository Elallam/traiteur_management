import 'package:email_validator/email_validator.dart';

class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Required field validation
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Full name validation
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  // Phone number validation
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and special characters for validation
    String cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Address validation
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  // Price validation
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    double? price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  // Quantity validation
  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    int? quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Please enter a valid quantity';
    }
    return null;
  }

  // Name validation (for articles, equipment, etc.)
  static String? name(String? value, [String? itemType]) {
    if (value == null || value.trim().isEmpty) {
      return '${itemType ?? 'Name'} is required';
    }
    if (value.trim().length < 2) {
      return '${itemType ?? 'Name'} must be at least 2 characters';
    }
    return null;
  }

  // Date validation
  static String? date(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    return null;
  }

  // Multiple field validation
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}