/// Link de um e-mail: o texto que aparece e o destino real, que podem
/// ser diferentes (uma das pistas da taxonomia).
class EmailLink {
  final String text;
  final String href;

  const EmailLink({required this.text, required this.href});

  factory EmailLink.fromJson(dynamic json) {
    if (json is String) {
      return EmailLink(text: json, href: json);
    }
    final map = json as Map<String, dynamic>;
    final href = (map['href'] ?? map['url'] ?? '').toString();
    final text = (map['text'] ?? href).toString();
    return EmailLink(text: text.isEmpty ? href : text, href: href);
  }
}

/// Conteudo de um e-mail no formato canonico do banco de itens
/// (items.content_json e questions.context_json):
/// {sender, sender_name, recipient, subject, body, links}.
class EmailContent {
  final String sender;
  final String senderName;
  final String recipient;
  final String subject;
  final String body;
  final List<EmailLink> links;

  const EmailContent({
    required this.sender,
    required this.senderName,
    required this.recipient,
    required this.subject,
    required this.body,
    this.links = const [],
  });

  factory EmailContent.fromJson(Map<String, dynamic> json) {
    final sender = (json['sender'] ?? json['from'] ?? '').toString();
    final rawName = (json['sender_name'] ?? json['senderName'] ?? '').toString();
    final rawLinks = json['links'];
    return EmailContent(
      sender: sender,
      senderName: rawName.isNotEmpty ? rawName : nameFromAddress(sender),
      recipient: (json['recipient'] ?? json['to'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      body: (json['body'] ?? json['text'] ?? '').toString(),
      links: rawLinks is List ? rawLinks.map(EmailLink.fromJson).where((l) => l.href.isNotEmpty).toList() : const [],
    );
  }

  String get avatarInitial {
    final source = senderName.isNotEmpty ? senderName : sender;
    return source.isEmpty ? '?' : source[0].toUpperCase();
  }

  String get preview {
    final clean = body.replaceAll('\n', ' ').trim();
    return clean.length > 80 ? '${clean.substring(0, 80)}...' : clean;
  }

  /// "ti-suporte@empresa.com" vira "Ti Suporte".
  static String nameFromAddress(String address) {
    final local = address.split('@').first;
    return local
        .replaceAll(RegExp(r'[._-]'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
