# -*- coding: utf-8 -*-
# Generated by Django 1.11.5 on 2017-09-16 01:12
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Task',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=255, verbose_name='Title')),
                ('description', models.TextField(verbose_name='Description')),
                ('open_date', models.DateTimeField(auto_now_add=True)),
                ('completed_date', models.DateTimeField(null=True)),
                ('status', models.PositiveSmallIntegerField(choices=[(1, 'Open'), (2, 'Working'), (3, 'Closed')], default=1)),
                ('isRemoved', models.BooleanField(default=False)),
                ('positionOrder', models.PositiveSmallIntegerField(default=1)),
            ],
            options={
                'verbose_name': 'Task',
                'verbose_name_plural': 'Tasks',
            },
        ),
    ]
