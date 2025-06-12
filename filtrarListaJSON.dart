/// Filtra, busca e ordena uma lista de objetos JSON.
///
/// Parâmetros:
///
/// listaCompleta: Lista de objetos a serem processados (retorna [] se null)
/// busca: String de busca no formato "campo,valor" ou busca global (ignora se
/// null)
/// filtros: Filtros complexos no formato "(campo,operador,valor)" com suporte
/// a AND/OR (ignora se null)
/// ordenacao: Ordenação no formato "campo,direção" onde direção é ASC ou DESC
/// (mantém ordem original se null)
///
/// Exemplos de uso:
///
/// Busca: "nome,João" ou "João" (busca global)
/// Filtros: "(idade,>,18)" ou "(status,==,ativo)AND(tipo,!=,admin)"
/// Ordenação: "nome,ASC" ou "data,DESC"
List<dynamic> filtrarListaJSON(
  List<dynamic>? listaCompleta,
  String? filtros,
  String? busca,
  String? ordenacao,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  // Se a lista for null, retornar array vazio
  if (listaCompleta == null) {
    return [];
  }

  // Cópia da lista para trabalhar
  List<dynamic> listaFiltrada = List.from(listaCompleta);

  // 1. Aplicar busca (ilike) com suporte para formato "chave,valor"
  if (busca != null && busca.isNotEmpty) {
    List<String> partesBusca = busca.split(',');

    if (partesBusca.length >= 2) {
      // Formato "chave,valor"
      String chaveBusca = partesBusca[0];
      String valorBusca = partesBusca.sublist(1).join(',').toLowerCase();

      listaFiltrada = listaFiltrada.where((item) {
        // Obter o valor do campo especificado
        dynamic valorItem = _obterValorCampo(item, chaveBusca);

        // Se o campo existir, verificar se contém a busca
        if (valorItem != null) {
          return valorItem.toString().toLowerCase().contains(valorBusca);
        }
        return false;
      }).toList();
    } else {
      // Comportamento original: busca em todo o objeto
      busca = busca.toLowerCase();
      listaFiltrada = listaFiltrada.where((item) {
        // Converte o item para string e verifica se contém a busca
        final String itemString = jsonEncode(item).toLowerCase();
        return itemString.contains(busca);
      }).toList();
    }
  }

  // 2. Aplicar filtros complexos com novo formato
  if (filtros != null && filtros.isNotEmpty) {
    // Separar os grupos por operadores lógicos
    List<String> grupos = [];
    List<String> operadoresLogicos = [];

    // Identificar operadores AND e OR
    String filtroRestante = filtros;
    while (filtroRestante.isNotEmpty) {
      // Encontrar o próximo parêntese de fechamento
      int indexFechamento = _encontrarParenteseFechamento(filtroRestante);
      if (indexFechamento == -1) break;

      // Extrair o grupo
      String grupo = filtroRestante.substring(0, indexFechamento + 1);
      grupos.add(grupo);

      // Avançar além do grupo
      filtroRestante = filtroRestante.substring(indexFechamento + 1);

      // Verificar se há um operador lógico
      if (filtroRestante.startsWith("AND") || filtroRestante.startsWith("OR")) {
        operadoresLogicos.add(filtroRestante.startsWith("AND") ? "AND" : "OR");
        filtroRestante = filtroRestante.substring(3); // Pular "AND" ou "OR"
      } else {
        // Se não há operador, terminou
        break;
      }
    }

    // Se identificamos pelo menos um grupo
    if (grupos.isNotEmpty) {
      // Aplicar o primeiro grupo
      List<dynamic> resultadoFiltro =
          _aplicarFiltroSimples(listaFiltrada, grupos[0]);

      // Aplicar grupos subsequentes com operadores lógicos
      for (int i = 0; i < operadoresLogicos.length; i++) {
        List<dynamic> resultadoGrupo =
            _aplicarFiltroSimples(listaFiltrada, grupos[i + 1]);

        if (operadoresLogicos[i] == "AND") {
          // Interseção - manter apenas itens em ambos os conjuntos (usando ID para comparação)
          resultadoFiltro = resultadoFiltro.where((item1) {
            return resultadoGrupo.any((item2) => _saoMesmoItem(item1, item2));
          }).toList();
        } else if (operadoresLogicos[i] == "OR") {
          // União - adicionar itens que não estão no resultado
          for (var item in resultadoGrupo) {
            if (!resultadoFiltro
                .any((existente) => _saoMesmoItem(item, existente))) {
              resultadoFiltro.add(item);
            }
          }
        }
      }

      listaFiltrada = resultadoFiltro;
    }
  }

  // 3. Aplicar ordenação
  if (ordenacao != null && ordenacao.isNotEmpty) {
    final partes = ordenacao.split(',');
    if (partes.length == 2) {
      final campo = partes[0];
      final direcao = partes[1].toUpperCase();

      listaFiltrada.sort((a, b) {
        dynamic valorA = _obterValorCampo(a, campo);
        dynamic valorB = _obterValorCampo(b, campo);

        // Ordenação com tratamento de tipo
        return _compararValores(valorA, valorB, direcao);
      });
    }
  }

  return listaFiltrada;
}

/// Compara dois valores para ordenação
int _compararValores(dynamic valorA, dynamic valorB, String direcao) {
  // Tratamento de null
  if (valorA == null && valorB == null) return 0;
  if (valorA == null) return direcao == 'ASC' ? -1 : 1;
  if (valorB == null) return direcao == 'ASC' ? 1 : -1;

  // Comparar strings
  if (valorA is String && valorB is String) {
    // Tentar converter para números
    num? numA = num.tryParse(valorA);
    num? numB = num.tryParse(valorB);

    if (numA != null && numB != null) {
      return direcao == 'ASC' ? numA.compareTo(numB) : numB.compareTo(numA);
    }

    // Tentar converter para datas
    DateTime? dataA = _parseDataBrasileira(valorA);
    DateTime? dataB = _parseDataBrasileira(valorB);

    if (dataA != null && dataB != null) {
      return direcao == 'ASC' ? dataA.compareTo(dataB) : dataB.compareTo(dataA);
    }

    // Comparação de strings
    final comparacao = valorA.compareTo(valorB);
    return direcao == 'ASC' ? comparacao : -comparacao;
  }

  // Comparar números
  if (valorA is num && valorB is num) {
    return direcao == 'ASC'
        ? valorA.compareTo(valorB)
        : valorB.compareTo(valorA);
  }

  // Comparar booleanos
  if (valorA is bool && valorB is bool) {
    final comparacao = valorA == valorB ? 0 : (valorA ? 1 : -1);
    return direcao == 'ASC' ? comparacao : -comparacao;
  }

  // Fallback para comparação de string
  return direcao == 'ASC'
      ? valorA.toString().compareTo(valorB.toString())
      : valorB.toString().compareTo(valorA.toString());
}

/// Encontra o índice do parêntese de fechamento correspondente
int _encontrarParenteseFechamento(String texto) {
  if (!texto.startsWith("(")) return -1;

  int nivel = 0;
  for (int i = 0; i < texto.length; i++) {
    if (texto[i] == '(') nivel++;
    if (texto[i] == ')') nivel--;

    if (nivel == 0) return i; // Encontrou o fechamento correspondente
  }

  return -1; // Não encontrou fechamento correspondente
}

/// Aplica um filtro simples a uma lista
List<dynamic> _aplicarFiltroSimples(List<dynamic> lista, String filtro) {
  // Remover parênteses externos
  String filtroLimpo = filtro;
  if (filtroLimpo.startsWith('(') && filtroLimpo.endsWith(')')) {
    filtroLimpo = filtroLimpo.substring(1, filtroLimpo.length - 1);
  }

  // Extrair partes do filtro (campo,operacao,valor)
  List<String> partes = filtroLimpo.split(',');
  if (partes.length < 3) return lista;

  String campo = partes[0];
  String operacao = partes[1];
  String valor = partes.sublist(2).join(','); // Juntar o resto como valor

  // Aplicar o filtro
  return lista
      .where((item) => _avaliarCondicao(item, campo, operacao, valor))
      .toList();
}

/// Avalia uma condição em um item
bool _avaliarCondicao(
    dynamic item, String campo, String operacao, String valorComparacao) {
  dynamic valorItem = _obterValorCampo(item, campo);

  // Tratar valor null
  if (valorItem == null) {
    if (operacao == '==' && valorComparacao.toLowerCase() == 'null')
      return true;
    if (operacao == '!=' && valorComparacao.toLowerCase() != 'null')
      return true;
    return false;
  }

  // Tratamento específico para booleanos
  if (campo == 'selecionado' || valorItem is bool) {
    bool? valorBool;

    // Converter valores para boolean
    if (valorItem is String) {
      valorBool = valorItem.toLowerCase() == 'true';
    } else if (valorItem is bool) {
      valorBool = valorItem;
    }

    bool valorComparacaoBool = valorComparacao.toLowerCase() == 'true';

    if (operacao == '==') return valorBool == valorComparacaoBool;
    if (operacao == '!=') return valorBool != valorComparacaoBool;
  }

  // Tratamento para datas
  DateTime? valorData = null;
  DateTime? comparacaoData = null;

  // Tentar converter para datas
  if (valorItem is String) {
    valorData = _parseDataBrasileira(valorItem);
  }

  comparacaoData = _parseDataBrasileira(valorComparacao);

  if (valorData != null && comparacaoData != null) {
    switch (operacao) {
      case '==':
        return valorData.isAtSameMomentAs(comparacaoData);
      case '!=':
        return !valorData.isAtSameMomentAs(comparacaoData);
      case '>':
        return valorData.isAfter(comparacaoData);
      case '>=':
        return valorData.isAfter(comparacaoData) ||
            valorData.isAtSameMomentAs(comparacaoData);
      case '<':
        return valorData.isBefore(comparacaoData);
      case '<=':
        return valorData.isBefore(comparacaoData) ||
            valorData.isAtSameMomentAs(comparacaoData);
    }
  }

  // Tratamento para números
  num? valorNumerico;
  num? comparacaoNumerica;

  if (valorItem is String) {
    valorNumerico = num.tryParse(valorItem);
  } else if (valorItem is num) {
    valorNumerico = valorItem;
  }

  comparacaoNumerica = num.tryParse(valorComparacao);

  if (valorNumerico != null && comparacaoNumerica != null) {
    switch (operacao) {
      case '==':
        return valorNumerico == comparacaoNumerica;
      case '!=':
        return valorNumerico != comparacaoNumerica;
      case '>':
        return valorNumerico > comparacaoNumerica;
      case '>=':
        return valorNumerico >= comparacaoNumerica;
      case '<':
        return valorNumerico < comparacaoNumerica;
      case '<=':
        return valorNumerico <= comparacaoNumerica;
    }
  }

  // Operações para strings
  switch (operacao) {
    case '==':
      return valorItem.toString() == valorComparacao;
    case '!=':
      return valorItem.toString() != valorComparacao;
    case 'contains':
    case 'ilike':
      return valorItem
          .toString()
          .toLowerCase()
          .contains(valorComparacao.toLowerCase());
    case 'startsWith':
      return valorItem
          .toString()
          .toLowerCase()
          .startsWith(valorComparacao.toLowerCase());
    case 'endsWith':
      return valorItem
          .toString()
          .toLowerCase()
          .endsWith(valorComparacao.toLowerCase());
    case 'in':
      List<String> valores = valorComparacao.split('|');
      return valores.contains(valorItem.toString());
    default:
      return false;
  }
}

/// Obtém o valor de um campo, suportando acessar propriedades aninhadas com notação de ponto
dynamic _obterValorCampo(dynamic item, String campo) {
  if (item == null) return null;

  // Para campos com notação de ponto (ex: "endereco.cidade")
  List<String> partes = campo.split('.');
  dynamic valor = item;

  for (String parte in partes) {
    if (valor is Map) {
      valor = valor[parte];
    } else {
      return null; // Caminho inválido
    }

    if (valor == null) break;
  }

  return valor;
}

/// Verifica se dois objetos representam o mesmo item (por ID ou comparação direta)
bool _saoMesmoItem(dynamic item1, dynamic item2) {
  if (item1 is Map && item2 is Map) {
    // Comparar por ID se disponível
    if (item1.containsKey('id') && item2.containsKey('id')) {
      return item1['id'] == item2['id'];
    }
  }

  // Comparação fallback por JSON
  return jsonEncode(item1) == jsonEncode(item2);
}

/// Tenta converter uma string para DateTime no formato brasileiro (dd/MM/yyyy)
DateTime? _parseDataBrasileira(String valor) {
  final RegExp regexData = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  if (regexData.hasMatch(valor)) {
    List<String> partes = valor.split('/');
    try {
      int dia = int.parse(partes[0]);
      int mes = int.parse(partes[1]);
      int ano = int.parse(partes[2]);
      return DateTime(ano, mes, dia);
    } catch (e) {
      return null;
    }
  }
  return null;

  /// MODIFY CODE ONLY ABOVE THIS LINE
}
