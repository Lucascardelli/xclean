# XClean - App Mobile

Aplicativo mobile para agendamento de serviços de limpeza, desenvolvido com Flutter.

## Funcionalidades

- Autenticação de usuários (clientes e profissionais)
- Listagem de serviços disponíveis
- Agendamento de serviços
- Histórico de agendamentos
- Perfil do usuário
- Upload de fotos
- Localização por GPS
- Integração com mapas
- Notificações push
- Chat interno
- Sistema de avaliações
- Pagamentos integrados

## Requisitos

- Flutter 3.0.0 ou superior
- Dart 3.0.0 ou superior
- Android Studio / VS Code
- Emulador Android ou dispositivo físico
- iOS Simulator ou dispositivo físico (para desenvolvimento iOS)

## Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/xclean.git
cd xclean/mobile
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o app:
```bash
flutter run
```

## Estrutura do Projeto

```
lib/
  ├── models/         # Modelos de dados
  ├── screens/        # Telas do app
  ├── services/       # Serviços de API
  ├── utils/          # Utilitários e constantes
  ├── widgets/        # Widgets reutilizáveis
  └── main.dart       # Arquivo principal
```

## Configuração

1. Configure as variáveis de ambiente no arquivo `lib/utils/constants.dart`
2. Configure as chaves de API no arquivo `android/app/src/main/AndroidManifest.xml`
3. Configure as permissões necessárias no arquivo `android/app/src/main/AndroidManifest.xml`

## Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## Contato

Seu Nome - [@seutwitter](https://twitter.com/seutwitter) - email@exemplo.com

Link do Projeto: [https://github.com/seu-usuario/xclean](https://github.com/seu-usuario/xclean) 