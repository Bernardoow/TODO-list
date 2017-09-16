# -*- coding: utf-8 -*-

from rest_framework import serializers

from apps.todo.models import Task


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('title', 'description', 'open_date', 'status',
                  'completed_date', 'isRemoved', 'positionOrder')


class TaskCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('title', 'description', 'open_date', 'status',
                  'completed_date', 'isRemoved', 'positionOrder')
        read_only_fields = ('open_date', 'completed_date', 'status',
                            'isRemoved', 'positionOrder')


class TaskRetrieveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('title', 'description', 'open_date', 'status',
                  'completed_date', 'isRemoved', 'positionOrder')
        read_only_fields = ('title', 'description', 'open_date',
                            'completed_date', 'status',
                            'isRemoved', 'positionOrder')


class TaskUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('title', 'description', 'open_date', 'status',
                  'completed_date', 'isRemoved', 'positionOrder')
        read_only_fields = ('open_date', 'completed_date',
                            'isRemoved', 'positionOrder')