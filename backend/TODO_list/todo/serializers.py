# -*- coding: utf-8 -*-

from rest_framework import serializers

from todo.models import Task


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('title', 'description', 'open_date',
                  'completed_date', 'isRemoved', 'positionOrder')


class TaskCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('title', 'description')
