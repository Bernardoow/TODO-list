from .base import *


INSTALLED_APPS += ['corsheaders']


MIDDLEWARE += [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
]

CORS_ORIGIN_ALLOW_ALL = True