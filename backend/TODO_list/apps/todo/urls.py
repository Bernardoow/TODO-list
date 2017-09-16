# urls.py
from django.conf.urls import url
from apps.todo.viewsets import TaskCreate
from apps.todo.viewsets import TaskList


urlpatterns = [
    url(r'new-task/$', TaskCreate.as_view(), name='new-task'),
    url(r'$', TaskList.as_view(), name='tasks'),


]
