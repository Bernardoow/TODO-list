# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase

from apps.todo.models import Task
from django.utils import timezone


class TaskTest(TestCase):

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

    def test_task_creation(self):
        task = self.create_task()
        self.assertTrue(isinstance(task, Task))
        str_model = task.title + " - " + task.description + " - " + str(task.status)
        self.assertEqual(task.__str__(), str_model)
