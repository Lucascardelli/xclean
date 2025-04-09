class AppConstants {
  static const String appName = 'XClean';
  static const String apiBaseUrl = 'http://localhost:8080/api';
  
  // Mensagens
  static const String welcomeMessage = 'Bem-vindo ao XClean!';
  static const String errorMessage = 'Ocorreu um erro. Tente novamente.';
  static const String loadingMessage = 'Carregando...';
  
  // Rotas
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String servicesRoute = '/services';
  static const String appointmentsRoute = '/appointments';
  static const String chatsRoute = '/chats';
  static const String searchUsersRoute = '/search-users';
  
  // Tamanhos
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const int defaultAnimationDuration = 300;

  // Mensagens
  static const String errorGeneric = 'Ocorreu um erro. Tente novamente.';
  static const String errorConnection = 'Erro de conexão. Verifique sua internet.';
  static const String successGeneric = 'Operação realizada com sucesso!';

  // Validações
  static const int minPasswordLength = 6;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\(\d{2}\) \d{4,5}-\d{4}$';

  // Configurações
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const int maxAppointmentsPerDay = 8;
  static const int minHoursBetweenAppointments = 2;

  // Cores
  static const String primaryColor = '#FF4B91';
  static const String secondaryColor = '#FF8DC7';
  static const String backgroundColor = '#FFF5E4';
  static const String textColor = '#2D2D2D';
  
  // Textos
  static const String appDescription = 'Encontre profissionais de limpeza de confiança';

  // Dimensões máximas da imagem
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  
  // Qualidade da compressão (0-100)
  static const int imageQuality = 85;
} 