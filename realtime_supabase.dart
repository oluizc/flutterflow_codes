//conectar
import 'package:realtime_client/realtime_client.dart';

Future conectar(
  String tabela,
  Future<dynamic> Function() acao,
) async {
  // Add your function code here!
  final supabase = SupaFlow.client;
  String table = tabela;
  final channelName = 'public:' + table;
  final channel = supabase.channel(channelName);

  // Configura a nova inscrição
  channel.on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(event: '*', schema: 'public', table: table),
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
