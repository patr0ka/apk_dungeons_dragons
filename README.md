# D&D 5e Compêndio

Aplicativo Flutter com quatro botões em grid de duas colunas: **Monstros, Magias, Classes e Equipamentos**. Cada botão abre uma tela com pesquisa, exemplos, explicação em pop-up e resultado da D&D 5e API. Abaixo dos dados, o aplicativo consulta um GIF ilustrativo relacionado ao nome retornado pela API.

O visual mantém o fundo preto, textos claros e navegação das telas originais. A estrutura segue as aulas de Invertexto e Giphy: `service/`, `view/`, pacote `http`, JSON, `async/await`, `FutureBuilder`, `Navigator.push` e `Image.network`. Os conteúdos de CEP, números por extenso, trending e paginação das aulas são exemplos didáticos, não funcionalidades solicitadas para este compêndio.

## Executar

Use Flutter com **Dart 3.13 ou superior** (o requisito do pubspec é do Dart). A implementação foi validada com Flutter 3.47.2 / Dart 3.13.2.

Crie uma chave no [portal do Giphy](https://developers.giphy.com/dashboard/), conforme a aula, e execute:

```sh
flutter pub get
flutter run --dart-define=GIPHY_API_KEY=SUA_CHAVE
```

Para gerar o APK com os GIFs habilitados:

```sh
flutter build apk --dart-define=GIPHY_API_KEY=SUA_CHAVE
```

Para depurar com a configuração local, salve sua chave em `config/local.json` usando `config/example.json` como modelo e execute:

```sh
flutter run --dart-define-from-file=config/local.json
```

No VS Code, selecione o celular e a configuração **D&D — celular (debug)** e pressione F5. Conecte o celular por USB, ative a depuração USB nas opções do desenvolvedor e aceite a autorização no aparelho.

O arquivo `config/local.json` está ignorado pelo Git. A chave não está incluída no repositório. Sem ela, as pesquisas de D&D continuam funcionando e a área do GIF informa a falta de configuração. `--dart-define` evita gravar a chave no código versionado, mas não a torna secreta dentro do aplicativo compilado.

## Identidade visual

O ícone original em PNG reúne um livro de consulta, um dado de RPG e brilho de magia, pensando no uso rápido durante a sessão. A mesma arte aparece no topo da home e das quatro telas de pesquisa. O arquivo principal é `assets/imgs/compendio.png` (1024 × 1024); há versões Android para diferentes densidades e para ícones adaptativos. O original e o prompt de geração estão em `assets/imgs/`.

## Pesquisas

| Categoria | Exemplos |
| --- | --- |
| Monstros | goblin, esqueleto, dragão vermelho |
| Magias | bola de fogo, escudo, magic missile |
| Classes | mago, guerreiro, bardo |
| Equipamentos | espada longa, adaga, mochila |

Os apelidos conhecidos em português são convertidos para inglês. Outros nomes devem ser pesquisados em inglês. As descrições permanecem no idioma retornado pela API. Quando há várias correspondências, o nome exato tem prioridade; caso contrário, aparece o primeiro resultado acompanhado de outras opções encontradas. O catálogo cobre o SRD disponibilizado pela API, não todos os livros de D&D.

O Giphy recebe o nome encontrado junto de `fantasy`, para contextualizar a imagem. O GIF é ilustrativo e a correspondência depende do catálogo do Giphy; não representa necessariamente a aparência oficial do elemento.

## Validações e tratamento de erros

- Campo obrigatório; de 2 a 80 caracteres; pelo menos uma letra; letras, números, espaços, hífen e apóstrofo permitidos.
- Entradas inválidas não enviam requisições. O botão fica desabilitado enquanto a pesquisa D&D está em andamento.
- Ausência de resultados, conexão, tempo limite de 15 segundos por requisição, JSON inválido, autorização, limite de consultas e indisponibilidade recebem mensagens próprias.
- Erros de busca ou carregamento do GIF preservam o resultado D&D.
- Os Futures ficam armazenados no estado; reconstruções da tela e pop-ups não repetem consultas. Respostas após sair da tela não chamam `setState`.
- A permissão de internet está no manifesto principal do Android, incluindo builds de distribuição.

## Organização

- `lib/service/dnd_service.dart`: consultas às quatro categorias e apelidos em português.
- `lib/service/giphy_service.dart`: pesquisa do GIF e configuração da chave.
- `lib/service/api_client.dart`: HTTP, tempo limite e erros.
- `lib/service/busca_validator.dart`: validação compartilhada.
- `lib/view/home_page.dart`: grid e navegação.
- `lib/view/busca_*_page.dart`: telas específicas e tela compartilhada de pesquisa.
- `lib/view/resultado_formatters.dart`: apresentação dos campos retornados, preservando os detalhes anteriores.

## Avaliação do código anterior

A separação entre serviços e telas, a navegação e as traduções de nomes já estavam implementadas. As principais lacunas eram: três opções em lista em vez de quatro em grid; ausência de Giphy e pop-ups; requisições criadas durante `build`; código de busca e validação duplicado; falta de tempo limite; erros HTTP apresentados como item não encontrado; referência a um logo inexistente; e permissão de internet apenas nas variantes de desenvolvimento. Esses pontos foram corrigidos.

A configuração Android ainda usa o identificador de exemplo e assinatura de desenvolvimento no build release. Isso não impede a atividade acadêmica, mas deve ser configurado antes de uma publicação em loja. O projeto contém somente a plataforma Android.

## Verificação

```sh
flutter analyze
flutter test
```

Os testes usam respostas HTTP simuladas e verificam as quatro categorias, apelidos, prioridade de nome exato, validações, erros HTTP/rede/JSON, Giphy sem chave/sem resultados, navegação, pop-ups, manutenção dos dados quando o GIF falha e saída durante uma consulta. Uma consulta real de `fireball` também foi conferida. A exibição real de GIFs requer uma chave válida e conexão no dispositivo.

Documentação: [D&D 5e API](https://www.dnd5eapi.co/) e [Giphy Search](https://developers.giphy.com/docs/api/endpoint/).
