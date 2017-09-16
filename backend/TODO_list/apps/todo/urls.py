# urls.py
from django.conf.urls import url
from apps.todo.views import TaskCreate
from apps.todo.views import TaskList
from apps.todo.views import TaskRetrieve
from apps.todo.views import TaskUpdate
from apps.todo.views import TaskDestroy
from apps.todo.views import TaskIndex


urlpatterns = [
    url(r'new-task/$', TaskCreate.as_view(), name='new-task'),
    url(r'(?P<pk>[0-9]+)/update$', TaskUpdate.as_view(), name='task-update'),
    url(r'(?P<pk>[0-9]+)/destroy$',
        TaskDestroy.as_view(), name='task-destroy'),
    url(r'(?P<pk>[0-9]+)/$', TaskRetrieve.as_view(), name='task'),
    url(r'list/$', TaskList.as_view(), name='tasks'),
    url(r'$', TaskIndex.as_view(), name='tasks'),
]
