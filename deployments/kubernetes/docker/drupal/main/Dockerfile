#
# <meta:header>
#   <meta:licence>
#     Copyright (c) 2020, ROE (http://www.roe.ac.uk/)
#
#     This information is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This information is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   </meta:licence>
# </meta:header>
#

FROM drupal:8.9.11-apache-buster
MAINTAINER Dave Morris <docker-admin@metagrid.co.uk>

ARG buildtag
ARG buildtime

LABEL maintainer="Dave Morris <docker-admin@metagrid.co.uk>"
LABEL buildtag="${buildtag}"
LABEL buildtime="${buildtime}"
LABEL gitrepo="https://github.com/wfau/aglais"

RUN apt-get update && apt-get install unzip

WORKDIR /opt/drupal

RUN set -eux; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/bee:^1.1'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/content_export_yaml:^2.9'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/devel:^4.0'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/extlink:^1.3'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/markdown:^2.0'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/pathauto:^1.8'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/redirect:^1.6'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/robotstxt:^1.4'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/token:^1.7'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/webform:^5.20';

RUN set -eux; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/business_responsive_theme:^2.0'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/bootstrap_mint:^5.0'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/bootstrap4:^2.1'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/bootstrap:^3.23'; \
    php -d memory_limit=-1 /usr/local/bin/composer require 'drupal/paxton:^1.3';


