abstract class PhoneValidation {
  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }

    // Remove any whitespace
    value = value.trim();

    // Initialize variables
    String cleanedValue;
    int expectedLength;

    if (value.startsWith('+201')) {
      // Format: +201030390358 (13 digits)
      expectedLength = 13;
      if (value.length != expectedLength) {
        return 'Mobile number must be 13 digits (including +201)';
      }
      cleanedValue = value.substring(4); // Remove "+201"
    } else if (value.startsWith('201')) {
      // Format: 201030390358 (12 digits)
      expectedLength = 12;
      if (value.length != expectedLength) {
        return 'Mobile number must be 12 digits (including 201)';
      }
      cleanedValue = value.substring(3); // Remove "201"
    } else if (value.startsWith('01')) {
      // Format: 01030390358 (11 digits)
      expectedLength = 11;
      if (value.length != expectedLength) {
        return 'Mobile number must be 11 digits';
      }
      cleanedValue = value.substring(2); // Remove "01"
    } else {
      return 'Number must start with +201, 201, or 01';
    }

    // Check if the cleaned value is numeric
    if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
      return 'Mobile number must contain only digits';
    }

    // Check for valid Mobile prefixes (0, 1, 2, or 5 after 01)
    if (!cleanedValue.startsWith('0') &&
        !cleanedValue.startsWith('1') &&
        !cleanedValue.startsWith('2') &&
        !cleanedValue.startsWith('5')) {
      return 'Number not valid';
    }

    return null;
  }
}