# Phishing Quest

Aplicativo móvel gamificado para o treinamento na detecção de phishing. Consome a API REST [phishing-quest-api](https://github.com/LABit-UFPA/phishing-quest-api).

## Rodar

Requer Flutter 3.35 ou mais novo (Dart 3.9).

```bash
flutter pub get
flutter run                                   # API de produção
flutter run --dart-define=PQ_LOCAL=true       # API local em http://10.0.2.2:8080/api/v1 (emulador Android)
flutter run --dart-define=PQ_LOCAL=true --dart-define=PQ_API_URL=http://192.168.0.10:8080/api/v1
```

O build de debug aceita HTTP para a API local; o de release só fala HTTPS e valida o certificado do servidor.

## Testes

```bash
flutter analyze
flutter test
```

## O que o app usa da API

- login com JWT (`/users/login`) e cadastro (`/users/register`);
- termo de consentimento da pesquisa (`/auth/consent`, `/me/participant`, retirada em `/auth/consent/:id/withdraw`);
- quiz: `/categories`, `/categories/:id/questions`, `/questions/:id/answers` e `/game/answer`;
- caixa de entrada: `/items/next-batch` (seleção adaptativa, só e-mail), `/items/:id/link-click` e `/attempts`;
- ranking global ou da turma (`/rankings`, `/me/ranking`) e desempenho por detecção de sinal (`/me/stats`);
- telemetria em lotes (`/telemetry-events`);
- curadoria, para pesquisadores e administradores (`/admin/items`).

O termo de consentimento em `lib/app/data/constants/consent_term.dart` é provisório: troque pelo texto aprovado pelo Comitê de Ética antes da coleta e mude a versão junto.
