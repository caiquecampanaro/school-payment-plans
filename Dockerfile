FROM ruby:3.2-slim

# Instalar dependências do sistema
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configurar diretório de trabalho
WORKDIR /app

# Copiar Gemfile e Gemfile.lock
COPY Gemfile Gemfile.lock* ./

# Instalar gems
RUN bundle install

# Copiar código da aplicação
COPY . .

# Expor porta
EXPOSE 3000

# Comando padrão
CMD ["rails", "server", "-b", "0.0.0.0"]

