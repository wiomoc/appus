import '../../protocols/api_exception.dart';

class CampusApiException implements ApiException {
  final String _errorDescription;
  final String? _recoverySuggestion;

  CampusApiException(this._errorDescription, [this._recoverySuggestion]);

  @override
  String get errorDescription => _errorDescription;

  @override
  String? get recoverySuggestion => _recoverySuggestion;
}


class InvalidCampusCredentialsException extends CampusApiException {
  InvalidCampusCredentialsException(super.errorDescription);
}