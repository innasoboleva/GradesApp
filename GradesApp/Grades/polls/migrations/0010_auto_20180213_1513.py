# Generated by Django 2.0.2 on 2018-02-13 23:13

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('polls', '0009_auto_20180212_1533'),
    ]

    operations = [
        migrations.RenameModel(
            old_name='Student_Grade',
            new_name='StudentGrade',
        ),
        migrations.RenameModel(
            old_name='Student_Subject',
            new_name='StudentSubject',
        ),
    ]
