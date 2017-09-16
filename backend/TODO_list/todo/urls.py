# urls.py
from django.conf.urls import url
from .viewsets import TaskCreate


urlpatterns = [
    url(r'new-task/$', TaskCreate.as_view(), name='new-task'),


]
