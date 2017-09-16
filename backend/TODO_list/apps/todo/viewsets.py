# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import viewsets
from rest_framework import generics

from apps.todo.models import Task
from apps.todo.serializers import TaskSerializer, TaskCreateSerializer


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
