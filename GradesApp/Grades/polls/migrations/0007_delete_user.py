# Generated by Django 2.0.2 on 2018-02-06 05:44

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('polls', '0006_auto_20180205_1558'),
    ]

    operations = [
        migrations.DeleteModel(
            name='User',
        ),
    ]