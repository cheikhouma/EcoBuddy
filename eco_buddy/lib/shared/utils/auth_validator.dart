class AuthValidator {
  // Validation du nom d'utilisateur
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom d\'utilisateur requis';
    }
    if (value.length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }
    if (value.length > 50) {
      return 'Le nom d\'utilisateur ne peut pas dépasser 50 caractères';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Le nom d\'utilisateur ne peut contenir que des lettres, chiffres et tirets bas';
    }
    return null;
  }

  // Validation de l'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (value.length > 100) {
      return 'L\'email ne peut pas dépasser 100 caractères';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  // Validation du mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    if (value.length > 128) {
      return 'Le mot de passe ne peut pas dépasser 128 caractères';
    }
    
    // Vérifier la force du mot de passe
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    bool hasDigits = RegExp(r'[0-9]').hasMatch(value);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    
    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChar) strength++;
    
    if (strength < 2) {
      return 'Mot de passe trop faible. Utilisez majuscules, minuscules, chiffres ou caractères spéciaux';
    }
    
    return null;
  }

  // Validation de l'âge
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Âge requis';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'L\'âge doit être un nombre valide';
    }
    
    if (age < 13) {
      return 'Vous devez avoir au moins 13 ans pour créer un compte';
    }
    if (age > 120) {
      return 'Âge invalide';
    }
    
    return null;
  }

  // Validation de la confirmation du mot de passe
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Confirmation du mot de passe requise';
    }
    if (password != confirmation) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // Évaluation de la force du mot de passe (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    return strength;
  }

  // Description de la force du mot de passe
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Très faible';
      case 1:
        return 'Faible';
      case 2:
        return 'Moyen';
      case 3:
        return 'Fort';
      case 4:
        return 'Très fort';
      default:
        return '';
    }
  }

  // Couleur pour l'indicateur de force
  static int getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 0xFFE53E3E; // Rouge
      case 2:
        return 0xFFED8936; // Orange
      case 3:
        return 0xFF38A169; // Vert
      case 4:
        return 0xFF22543D; // Vert foncé
      default:
        return 0xFF718096; // Gris
    }
  }
}