# Usa a imagem oficial do Flutter
FROM ubuntu:20.04

# Evita interações durante a instalação de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências necessárias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev

# Define o diretório de trabalho
WORKDIR /app

# Instala o Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Configura o Flutter para modo web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter doctor

# Copia os arquivos do projeto
COPY . .

# Instala as dependências do projeto
RUN flutter pub get

# Expõe a porta que o Flutter web usará
EXPOSE 8080

# Comando para executar o aplicativo
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"] 