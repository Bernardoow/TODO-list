# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import viewsets
from rest_framework import generics

from apps.todo.models import Task
from apps.todo.serializers import TaskSerializer
from apps.todo.serializers import TaskCreateSerializer
from apps.todo.serializers import TaskRetrieveSerializer
from apps.todo.serializers import TaskUpdateSerializer


class TaskViewSet(viewsets.ModelViewSet):
    """
    A simple ViewSet for viewing and editing tasks.
    """
    queryset = Task.objects.all()
    serializer_class = TaskSerializer


class TaskCreate(generics.CreateAPIView):
    serializer_class = TaskCreateSerializer


class TaskList(generics.ListAPIView):
    queryset = Task.objects.all()
    serializer_class = TaskCreateSerializer


class TaskRetrieve(generics.RetrieveAPIView):
    queryset = Task.objects.all()
    serializer_class = TaskRetrieveSerializer


class TaskUpdate(generics.UpdateAPIView):
    queryset = Task.objects.all()
    serializer_class = TaskUpdateSerializer


class TaskDestroy(generics.DestroyAPIView):
    queryset = Task.objects.all()
