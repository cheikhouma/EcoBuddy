/// Exceptions personnalisées pour le système de stories
class StoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const StoryException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'StoryException: $message';
}

class NetworkStoryException extends StoryException {
  const NetworkStoryException(String message, {dynamic originalError})
      : super(
          message,
          code: 'NETWORK_ERROR',
          originalError: originalError,
        );
}

class AIServiceException extends StoryException {
  const AIServiceException(String message, {dynamic originalError})
      : super(
          message,
          code: 'AI_SERVICE_ERROR',
          originalError: originalError,
        );
}

class AuthenticationStoryException extends StoryException {
  const AuthenticationStoryException(String message, {dynamic originalError})
      : super(
          message,
          code: 'AUTH_ERROR',
          originalError: originalError,
        );
}

class SessionExpiredException extends StoryException {
  const SessionExpiredException(String message, {dynamic originalError})
      : super(
          message,
          code: 'SESSION_EXPIRED',
          originalError: originalError,
        );
}

class ParsingException extends StoryException {
  const ParsingException(String message, {dynamic originalError})
      : super(
          message,
          code: 'PARSING_ERROR',
          originalError: originalError,
        );
}