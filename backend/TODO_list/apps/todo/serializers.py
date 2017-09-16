# -*- coding: utf-8 -*-

from rest_framework import serializers

from apps.todo.models import Task
from django.utils import timezone


class TaskSerializer(serializers.ModelSerializer):
    id = serializers.ReadOnlyField()
    positionOrderTimestampUpdated = serializers.SerializerMethodField()

    class Meta:
        model = Task
        fields = ('id', 'title', 'description', 'open_date', 'status',
                  'completed_date', 'isRemoved', 'positionOrder',
                  'positionOrderTimestampUpdated')
        read_only_fields = ('id', 'title', 'description', 'open_date', 'status',
                            'completed_date', 'isRemoved', 'positionOrder',
                            'positionOrderTimestampUpdated')

    def get_positionOrderTimestampUpdated(self, obj):
        return obj.positionOrderDateUpdated.timestamp()


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
    id = serializers.ReadOnlyField()
    positionOrderTimestampUpdated = serializers.SerializerMethodField()

    class Meta:
        model = Task
        fields = ('id', 'title', 'description', 'open_date', 'status',
                  'completed_date', 'isRemoved', 'positionOrder',
                  'positionOrderTimestampUpdated')
        read_only_fields = ('open_date', 'completed_date',
                            'isRemoved',
                            'positionOrderTimestampUpdated')

    def get_positionOrderTimestampUpdated(self, obj):
        return obj.positionOrderDateUpdated.timestamp()

    def update(self, instance, validated_data):
        instance.title = validated_data.get('title', instance.title)
        instance.description = validated_data.get('description',
                                                  instance.description)
        instance.status = validated_data.get('status', instance.status)

        positionOrder = instance.positionOrder
        instance.positionOrder = validated_data.get('positionOrder',
                                                    instance.positionOrder)
        if positionOrder != instance.positionOrder:
            instance.positionOrderDateUpdated = timezone.now()

        instance.save()

        return instance
