import 'package:phishing_quest/app/data/models/constants/environment_properties.model.dart';

/// Representing local environment configuration.
///
/// A URL pode ser trocada sem editar o codigo:
/// `flutter run --dart-define=PQ_LOCAL=true --dart-define=PQ_API_URL=http://192.168.0.10:8080/api/v1`.
/// O padrao 10.0.2.2 e o localhost da maquina vista do emulador Android.
const EnvironmentProperties LOCAL_ENV = EnvironmentProperties(
  cacheLifespan: 60000, // 1 minute
  endpoint: EndpointProperties(
    projeto: String.fromEnvironment('PQ_API_URL', defaultValue: 'http://10.0.2.2:8080/api/v1'),
    timeout: 120,
  ),
);

/// Representing production environment configuration
const EnvironmentProperties PRODUCTION_ENV = EnvironmentProperties(
  cacheLifespan: 300000, // 5 minutes
  endpoint: EndpointProperties(
    projeto: 'https://phishingquest.labsc.com.br/api/v1',
    timeout: 80,
  ),
);

/// `--dart-define=PQ_LOCAL=true` aponta o app para [LOCAL_ENV].
const bool USE_LOCAL_ENV = bool.fromEnvironment('PQ_LOCAL');
