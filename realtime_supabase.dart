//conectar: Inicia a escuta de eventos na tabela em questão.
Future conectar(
  String tabela,
  String iduser, //uuid do usuário para realizar filtros
  Future Function() acao,
) async {
  final supabase = SupaFlow.client;
  final channelName = 'public:$tabela';
  final channel = supabase.channel(channelName);
  String table = tabela;

  // Configura a nova inscrição
  channel.on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(
        event: '*',
        schema: 'public',
        table: table,
        filter: 'resp_autor=eq.$iduser'), //alterar filtro
    (payload, [ref]) {
      acao();
      print('Reloaded.');
    },
  ).subscribe();
}


//desconectar: Para de escutar os eventos.
Future desconectar(String tabela) async {
  // Add your function code here!

  final supabase = SupaFlow.client;
  String table = tabela;
  final channel = supabase.channel('public:' + table);

  // Desconectar do canal
  await channel.unsubscribe();
}
