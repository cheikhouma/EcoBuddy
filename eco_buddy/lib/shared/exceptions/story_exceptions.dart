/// Exceptions personnalisées pour le système de stories
class StoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const StoryException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'StoryException: $message';
}

class NetworkStoryException extends StoryException {
  const NetworkStoryException(super.message, {super.originalError})
    : super(code: 'NETWORK_ERROR');
}

class AIServiceException extends StoryException {
  const AIServiceException(super.message, {super.originalError})
    : super(code: 'AI_SERVICE_ERROR');
}

class AuthenticationStoryException extends StoryException {
  const AuthenticationStoryException(super.message, {super.originalError})
    : super(code: 'AUTH_ERROR');
}

class SessionExpiredException extends StoryException {
  const SessionExpiredException(super.message, {super.originalError})
    : super(code: 'SESSION_EXPIRED');
}

class ParsingException extends StoryException {
  const ParsingException(super.message, {super.originalError})
    : super(code: 'PARSING_ERROR');
}
