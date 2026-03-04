FROM ruby:2.7.8

# Dépendances système
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    libffi-dev \
    nodejs \
    imagemagick \
    ffmpeg \
    wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installer bundler compatible avec Ruby 2.7
RUN gem install bundler -v '2.4.22'

# Copier Gemfile en premier pour profiter du cache Docker
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copier le reste de l'application
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
