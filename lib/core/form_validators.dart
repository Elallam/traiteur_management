class FormValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validatePrice(String? value, {String fieldName = 'Price'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid $fieldName';
    }

    if (price < 0) {
      return '$fieldName must be positive';
    }

    return null;
  }

  static String? validateQuantity(String? value, {String fieldName = 'Quantity'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid $fieldName';
    }

    if (quantity < 0) {
      return '$fieldName must be positive';
    }

    return null;
  }

  static String? validateDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }

    final now = DateTime.now();
    if (value.isBefore(now.subtract(const Duration(days: 1)))) {
      return '$fieldName cannot be in the past';
    }

    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 10) {
      return 'Please enter a complete address';
    }

    return null;
  }

  // Multi-field validation
  static Map<String, String> validateEquipmentCheckout({
    required String? equipmentId,
    required String? quantity,
    required DateTime? checkoutDate,
    required DateTime? returnDate,
  }) {
    Map<String, String> errors = {};

    if (equipmentId == null || equipmentId.isEmpty) {
      errors['equipment'] = 'Please select equipment';
    }

    final quantityError = validateQuantity(quantity);
    if (quantityError != null) {
      errors['quantity'] = quantityError;
    }

    if (checkoutDate == null) {
      errors['checkoutDate'] = 'Checkout date is required';
    }

    if (returnDate == null) {
      errors['returnDate'] = 'Return date is required';
    }

    if (checkoutDate != null && returnDate != null) {
      if (returnDate.isBefore(checkoutDate)) {
        errors['returnDate'] = 'Return date must be after checkout date';
      }
    }

    return errors;
  }

  static Map<String, String> validateOccasionData({
    required String? title,
    required String? clientName,
    required String? clientPhone,
    required String? address,
    required String? expectedGuests,
    required DateTime? date,
    required String? totalPrice,
  }) {
    Map<String, String> errors = {};

    final titleError = validateRequired(title, fieldName: 'Title');
    if (titleError != null) errors['title'] = titleError;

    final clientNameError = validateName(clientName, fieldName: 'Client name');
    if (clientNameError != null) errors['clientName'] = clientNameError;

    final phoneError = validatePhone(clientPhone);
    if (phoneError != null) errors['clientPhone'] = phoneError;

    final addressError = validateAddress(address);
    if (addressError != null) errors['address'] = addressError;

    final guestsError = validateQuantity(expectedGuests, fieldName: 'Expected guests');
    if (guestsError != null) errors['expectedGuests'] = guestsError;

    final dateError = validateDate(date, fieldName: 'Event date');
    if (dateError != null) errors['date'] = dateError;

    final priceError = validatePrice(totalPrice, fieldName: 'Total price');
    if (priceError != null) errors['totalPrice'] = priceError;

    return errors;
  }
}
