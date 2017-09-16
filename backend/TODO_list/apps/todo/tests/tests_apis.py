from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from apps.todo.models import Task


class TaskTests(APITestCase):
    def test_create_task(self):
        url = reverse('todo:new-task')
        data = {'title': 'teste', 'description': 'desc'}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Task.objects.count(), 1)
        self.assertEqual(Task.objects.get().title, 'teste')
        self.assertEqual(Task.objects.get().description, 'desc')

    def test_create_task_without_atributes(self):
        url = reverse('todo:new-task')
        data = {}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        data = {'title': 'teste'}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        data = {'description': 'desc'}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_status(self):
        url = reverse('todo:new-task')
        data = {'title': 'teste', 'description': 'desc'}
        response = self.client.post(url, data, format='json')
        url = reverse('todo:task-update', kwargs={'pk': 1})
        data = {'status': 3}

        response = self.client.patch(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Task.objects.count(), 1)
        self.assertEqual(Task.objects.get().title, 'teste')
        self.assertEqual(Task.objects.get().description, 'desc')
        self.assertEqual(Task.objects.get().status, 3)

    def test_update_status_wrong(self):
        url = reverse('todo:new-task')
        data = {'title': 'teste', 'description': 'desc'}
        response = self.client.post(url, data, format='json')
        url = reverse('todo:task-update', kwargs={'pk': 1})
        data = {'status': 4}

        response = self.client.patch(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Task.objects.count(), 1)
        self.assertEqual(Task.objects.get().title, 'teste')
        self.assertEqual(Task.objects.get().description, 'desc')

    def test_update_position(self):
        url = reverse('todo:new-task')
        data = {'title': 'teste', 'description': 'desc'}
        response = self.client.post(url, data, format='json')
        url = reverse('todo:task-update', kwargs={'pk': 1})
        data = {'positionOrder': 10}

        response = self.client.patch(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Task.objects.count(), 1)
        self.assertEqual(Task.objects.get().title, 'teste')
        self.assertEqual(Task.objects.get().description, 'desc')
        self.assertEqual(Task.objects.get().positionOrder, 10)

    def test_update_position_negative(self):
        url = reverse('todo:new-task')
        data = {'title': 'teste', 'description': 'desc'}
        response = self.client.post(url, data, format='json')
        url = reverse('todo:task-update', kwargs={'pk': 1})
        data = {'positionOrder': -10}

        response = self.client.patch(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_destroy(self):
        url = reverse('todo:new-task')
        data = {'title': 'teste', 'description': 'desc'}
        response = self.client.post(url, data, format='json')
        url = reverse('todo:task-destroy', kwargs={'pk': 1})

        response = self.client.delete(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
