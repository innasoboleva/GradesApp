# Generated by Django 2.0.2 on 2018-02-05 21:38

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('polls', '0003_remove_users_user_id'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='users',
            options={'ordering': ['-id']},
        ),
    ]
