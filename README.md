# D&D 5e Compêndio

Um aplicativo móvel desenvolvido em **Flutter** para auxiliar jogadores e mestres de Dungeons & Dragons 5ª Edição. O app permite a busca rápida e fácil por informações vitais durante as partidas ou na preparação do jogo.

## Funcionalidades

- 🐉 **Busca de Monstros**: Consulte o bestiário para encontrar atributos, pontos de vida, ações, resistências e o nível de desafio das criaturas.
- ✨ **Busca de Magias**: Pesquise feitiços, veja o tempo de conjuração, alcance, duração, componentes e detalhes completos do efeito.
- 🛡️ **Busca de Classes**: Consulte informações e descrições sobre as classes de D&D.
- 🇧🇷 **Suporte a buscas em Português**: O aplicativo possui um dicionário interno que traduz automaticamente termos populares (ex: "bola de fogo" -> "fireball", "mago" -> "wizard", "dragão vermelho" -> "adult red dragon") para facilitar a pesquisa sem precisar saber o nome original em inglês.

## API Utilizada
Os dados do compêndio são consumidos em tempo real utilizando a [D&D 5e API](https://www.dnd5eapi.co/) (`https://www.dnd5eapi.co/api/2014`).

## Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.13.0 ou superior recomendada)
- Dart SDK

## Como executar o projeto

1. Clone este repositório:
   ```bash
   git clone https://github.com/patr0ka/apk_dungeons_dragons.git
   ```

2. Acesse o diretório do projeto:
   ```bash
   cd apk_dungeons_dragons
   ```

3. Instale as dependências:
   ```bash
   flutter pub get
   ```

4. Execute o aplicativo (em um emulador ou dispositivo conectado):
   ```bash
   flutter run
   ```
