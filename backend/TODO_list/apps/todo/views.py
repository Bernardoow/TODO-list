# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.views.generic import TemplateView
from rest_framework import generics

from apps.todo.models import Task
from apps.todo.serializers import TaskSerializer
from apps.todo.serializers import TaskCreateSerializer
from apps.todo.serializers import TaskRetrieveSerializer
from apps.todo.serializers import TaskUpdateSerializer


class TaskCreate(generics.CreateAPIView):
    serializer_class = TaskCreateSerializer


class TaskList(generics.ListAPIView):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer


class TaskRetrieve(generics.RetrieveAPIView):
    queryset = Task.objects.all()
    serializer_class = TaskRetrieveSerializer


class TaskUpdate(generics.UpdateAPIView):
    queryset = Task.objects.all()
    serializer_class = TaskUpdateSerializer


class TaskDestroy(generics.DestroyAPIView):
    queryset = Task.objects.all()


class TaskIndex(TemplateView):
    template_name = "index.html"
