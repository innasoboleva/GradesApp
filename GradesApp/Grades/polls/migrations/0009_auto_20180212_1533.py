# Generated by Django 2.0.2 on 2018-02-12 23:33

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('polls', '0008_tasks'),
    ]

    operations = [
        migrations.AlterField(
            model_name='student_grade',
            name='task_grade',
            field=models.IntegerField(),
        ),
    ]
