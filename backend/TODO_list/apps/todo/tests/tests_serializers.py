# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase

from apps.todo.models import Task
from apps.todo.serializers import TaskSerializer
from apps.todo.serializers import TaskCreateSerializer
from apps.todo.serializers import TaskRetrieveSerializer
from apps.todo.serializers import TaskUpdateSerializer
from django.utils import timezone


class TaskSerializersTest(TestCase):

    def create_task(self):
        return Task.objects.create(title="Fazer TodoLIST",
                                   description="Fazer um app de TODO LIST",
                                   open_date=timezone.now(),
                                   completed_date=timezone.now(),
                                   status=1,
                                   isRemoved=False,
                                   positionOrder=1,
                                   positionOrderDateUpdated=timezone.now()
                                   )

    def setUp(self):
        self.task = self.create_task()

    def test_contains_expected_fields(self):
        t = TaskSerializer(instance=self.task).data
        dc = TaskCreateSerializer(instance=self.task).data
        dr = TaskRetrieveSerializer(instance=self.task).data
        du = TaskUpdateSerializer(instance=self.task).data

        for ser_data in [t, dc, dr, du]:
            self.assertEqual(set(ser_data.keys()), set(
                ['id', 'title', 'description', 'open_date', 'completed_date',
                 'status', 'isRemoved', 'positionOrder',
                 'positionOrderTimestampUpdated']))

    def test_task_update_serializer(self):
        du = TaskUpdateSerializer(instance=self.task)
        dict_ = {
            'title': 'bernardo',
            'status': 1,
            'positionOrder': 3,
            'description': 'bern'
        }

        instanceUpdate = du.update(instance=self.task, validated_data=dict_)

        self.assertEqual(instanceUpdate.title, dict_['title'])
        self.assertEqual(instanceUpdate.status, dict_['status'])
        self.assertEqual(instanceUpdate.positionOrder, dict_['positionOrder'])
        self.assertEqual(instanceUpdate.description, dict_['description'])
