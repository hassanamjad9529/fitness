class Validator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value);
    if (height == null || height < 50 || height > 250) {
      return 'Enter a valid height (50-250 cm)';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight < 20 || weight > 300) {
      return 'Enter a valid weight (20-300 kg)';
    }
    return null;
  }

  static String? validateBodyFatPercentage(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final percentage = double.tryParse(value);
    if (percentage == null || percentage < 0 || percentage > 100) {
      return 'Enter a valid body fat percentage (0-100)';
    }
    return null;
  }

  static String? validateQualifications(String? value) {
    if (value == null || value.isEmpty) {
      return 'Qualifications are required';
    }
    if (value.length < 10) {
      return 'Qualifications must be at least 10 characters';
    }
    return null;
  }

  static String? validateExperienceYears(String? value) {
    if (value == null || value.isEmpty) {
      return 'Years of experience are required';
    }
    final years = int.tryParse(value);
    if (years == null || years < 0 || years > 50) {
      return 'Enter a valid number of years (0-50)';
    }
    return null;
  }

  static String? validateAvailability(String? value) {
    if (value == null || value.isEmpty) {
      return 'Availability is required';
    }
    if (value.length < 5) {
      return 'Availability must be at least 5 characters';
    }
    return null;
  }
}