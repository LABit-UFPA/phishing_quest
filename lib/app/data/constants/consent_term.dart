/// Termo de consentimento exibido antes da coleta. A versao vai para a
/// API junto com o aceite (study_participants.consent_version).
///
/// O texto e PROVISORIO: antes da coleta ele deve ser trocado pela
/// versao aprovada pelo Comite de Etica em Pesquisa, e [consentTermVersion]
/// deve mudar junto, para que cada aceite fique ligado ao texto que o
/// participante leu.
const String consentTermVersion = 'tcle-provisorio-2026-10';

const String consentTermTitle = 'Termo de Consentimento Livre e Esclarecido';

const List<({String heading, String body})> consentTermSections = [
  (
    heading: 'Sobre a pesquisa',
    body: 'Você está sendo convidado(a) a participar de uma pesquisa sobre o treinamento na detecção de '
        'phishing com o jogo Phishing Quest, conduzida na Universidade Federal do Pará.',
  ),
  (
    heading: 'O que será registrado',
    body: 'Suas decisões na caixa de entrada simulada (se a mensagem é phishing ou legítima, a ação '
        'escolhida, sua confiança, sua justificativa, o tempo de resposta e os cliques em links), eventos '
        'de uso do aplicativo e, quando aplicados, questionários da pesquisa.',
  ),
  (
    heading: 'Como os dados serão usados',
    body: 'Somente para a pesquisa. Nos dados exportados para análise, seu usuário é substituído por um '
        'código, sem nome nem e-mail.',
  ),
  (
    heading: 'Formas de feedback',
    body: 'O estudo compara formas diferentes de feedback, e o sistema sorteia a que você receberá. Em uma '
        'delas, suas justificativas são enviadas a um modelo de linguagem da OpenAI, que comenta a sua '
        'análise. Não escreva dados pessoais nas justificativas.',
  ),
  (
    heading: 'Participação voluntária',
    body: 'Sem consentir, você ainda pode jogar o quiz; a caixa de entrada simulada fica disponível só para '
        'quem participa, porque cada decisão nela é registrada. Você pode retirar o consentimento a '
        'qualquer momento, no Perfil. Depois disso, novas decisões deixam de ser registradas e seus dados '
        'saem da exportação usada nas análises.',
  ),
  (
    heading: 'Texto provisório',
    body: 'Este termo é provisório. Antes do início da coleta, ele será substituído pela versão aprovada '
        'pelo Comitê de Ética em Pesquisa, com os contatos dos responsáveis.',
  ),
];
