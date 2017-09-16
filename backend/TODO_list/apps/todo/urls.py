# urls.py
from django.conf.urls import url
from apps.todo.viewsets import TaskCreate
from apps.todo.viewsets import TaskList
from apps.todo.viewsets import TaskRetrieve
from apps.todo.viewsets import TaskUpdate


urlpatterns = [
    url(r'new-task/$', TaskCreate.as_view(), name='new-task'),
    url(r'(?P<pk>[0-9]+)/', TaskRetrieve.as_view(), name='task'),
    url(r'(?P<pk>[0-9]+)/', TaskUpdate.as_view(), name='task'),
    url(r'$', TaskList.as_view(), name='tasks'),
]
