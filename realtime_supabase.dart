//conectar
Future conectar(
  String tabela,
  String iduser,
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
        filter: 'resp_autor=eq.$iduser'),
    (payload, [ref]) {
      acao();
      print('Reloaded.');
    },
  ).subscribe();
}


//desconectar
Future desconectar(String tabela) async {
  // Add your function code here!

  final supabase = SupaFlow.client;
  String table = tabela;
  final channel = supabase.channel('public:' + table);

  // Desconectar do canal
  await channel.unsubscribe();
}
