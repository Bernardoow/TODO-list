# -*- coding: utf-8 -*-

from __future__ import unicode_literals

from django.db import models
from django.utils.translation import ugettext_lazy as _


class Task(models.Model):
    """Class to represent Task"""

    title = models.CharField(_('Title'), max_length=255)
    description = models.TextField(_('Description'))
    open_date = models.DateTimeField(auto_now_add=True)
    completed_date = models.DateTimeField(null=True)

    OPEN = 1
    WORKING = 2
    CLOSED = 3

    STATUS_CHOICES = (
        (OPEN, _('Open')),
        (WORKING, _('Working')),
        (CLOSED, _('Closed')),
    )
    status = models.PositiveSmallIntegerField(
        choices=STATUS_CHOICES,
        default=OPEN,
    )

    isRemoved = models.BooleanField(default=False)
    positionOrder = models.PositiveSmallIntegerField(default=1)

    class Meta:
        verbose_name = "Task"
        verbose_name_plural = "Tasks"

    def __str__(self):
        return "{} - {} - {}".format(self.title, self.description, self.status)
