from django.db import models

# Create your models here.
# class User(models.Model):
#     username = models.CharField(max_length=20)
#     password = models.CharField(max_length=20)
#
#     user_name = models.CharField(max_length=30)
#     user_teacher = models.BooleanField(default=False)
#
#     class Meta:
#         ordering = ["-id"]

class Subjects(models.Model):
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)

class Student_Subject(models.Model):
    student_id = models.IntegerField()
    student_name = models.CharField(max_length=30)
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)

class Tasks(models.Model):
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)
    task_name = models.CharField(max_length=50)

class Student_Grade(models.Model):
    student_id = models.IntegerField()
    student_name = models.CharField(max_length=30)
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)
    task_name = models.CharField(max_length=50)
    task_grade = models.CharField(max_length=2)