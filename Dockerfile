FROM php:7.4-apache-bullseye

RUN find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) \
        -exec sed -i 's|deb.debian.org/debian-security|archive.debian.org/debian-security|g' {} + \
    && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libonig-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" bcmath gd mbstring pdo_mysql xml zip \
    && a2enmod rewrite headers \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY app_freehosting_light.zip /tmp/app.zip
RUN unzip -q /tmp/app.zip -d /var/www/html \
    && rm /tmp/app.zip \
    && mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

COPY apache-site.conf /etc/apache2/sites-available/000-default.conf
COPY start.sh /usr/local/bin/start-app
RUN chmod +x /usr/local/bin/start-app \
    && printf '\nListen 10000\n' >> /etc/apache2/ports.conf

WORKDIR /var/www/html
EXPOSE 10000
CMD ["/usr/local/bin/start-app"]
