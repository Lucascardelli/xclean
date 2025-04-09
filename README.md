# XClean - Plataforma de Conexão para Faxina Sensual

## 📱 Sobre o Projeto
XClean é uma plataforma mobile que conecta clientes a prestadoras de serviços de faxina sensual, oferecendo uma experiência segura e profissional.

## 🛠 Tecnologias

### Mobile App
- Flutter (Android & iOS)
- Firebase (Autenticação, Notificações, Analytics)
- Google Maps/Mapbox (Geolocalização)
- Stripe/MercadoPago (Pagamentos)

### Backend
- Go (Golang)
- Gin (Framework HTTP)
- PostgreSQL (Banco de dados)
- JWT (Autenticação)
- Supabase Storage/AWS S3 (Armazenamento)

## 🚀 Funcionalidades

### Cliente
- Cadastro/Login (email, Google, Apple)
- Busca por prestadoras próximas
- Agendamento de serviços
- Pagamento via app
- Avaliações e histórico

### Prestadora
- Cadastro com verificação
- Gestão de perfil e disponibilidade
- Recebimento de agendamentos
- Gestão financeira
- Avaliações

### Admin
- Moderação de contas
- Gestão de transações
- Sistema de denúncias

## 📦 Estrutura do Projeto

```
xclean/
├── mobile/           # App Flutter
├── backend/          # API Go
│   ├── cmd/         # Entry points
│   ├── internal/    # Código interno
│   ├── pkg/         # Pacotes públicos
│   └── api/         # Endpoints da API
└── docs/            # Documentação
```

## 🚀 Como Executar

### Pré-requisitos
- Go 1.21+
- Flutter 3.0+
- PostgreSQL 14+
- Docker (opcional)

### Backend
```bash
cd backend
go mod download
go run cmd/api/main.go
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

## 📝 Licença
Este projeto está sob a licença MIT.

# XClean - Ambiente Docker

Este é o ambiente Docker para executar o aplicativo XClean em modo web.

## Requisitos

- Docker
- Docker Compose

## Como executar

1. Clone o repositório:
```bash
git clone [URL_DO_REPOSITÓRIO]
cd xclean
```

2. Construa e execute o container:
```bash
docker-compose up --build
```

3. Acesse o aplicativo:
Abra seu navegador e acesse `http://localhost:8080`

## Observações importantes

- O aplicativo está configurado para rodar em modo web, que é uma forma de testar o app sem precisar de um dispositivo móvel
- As alterações no código serão refletidas automaticamente graças ao volume montado
- Para parar o container, pressione Ctrl+C ou execute:
```bash
docker-compose down
```

## Estrutura do projeto

```
xclean/
├── mobile/           # Código do aplicativo Flutter
├── Dockerfile        # Configuração do container
├── docker-compose.yml # Configuração do ambiente
└── README.md         # Este arquivo
```