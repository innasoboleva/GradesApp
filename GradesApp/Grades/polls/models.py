from django.db import models


class Subjects(models.Model):
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)

    @classmethod
    def new(cls, subject_name, teacher_id, teacher_name):
        subject = cls.objects.create(subject_name=subject_name,
                                     teacher_id=teacher_id, teacher_name=teacher_name)
        return subject


class StudentSubject(models.Model):
    student_id = models.IntegerField()
    student_name = models.CharField(max_length=30)
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)

    @classmethod
    def new(cls, student_id, student_name, subject_id, subject_name, teacher_id, teacher_name):
        subject = cls.objects.create(student_id=student_id, student_name=student_name,
                                     subject_id=subject_id, subject_name=subject_name,
                                     teacher_id=teacher_id, teacher_name=teacher_name)
        return subject


class Tasks(models.Model):
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)
    task_name = models.CharField(max_length=50)

    @classmethod
    def new(cls, subject_id, subject_name, teacher_id, teacher_name, task_name):
        task = cls.objects.create(subject_id=subject_id, subject_name=subject_name,
                                  teacher_id=teacher_id, teacher_name=teacher_name,
                                  task_name=task_name)
        return task


class StudentGrade(models.Model):
    student_id = models.IntegerField()
    student_name = models.CharField(max_length=30)
    subject_id = models.IntegerField()
    subject_name = models.CharField(max_length=30)
    teacher_id = models.IntegerField()
    teacher_name = models.CharField(max_length=30)
    task_name = models.CharField(max_length=50)
    task_grade = models.IntegerField()  # 0 for nil, 1 for 'A', 2 for 'B', 3 for 'C', 4 for 'D', 5 for 'E'

    @classmethod
    def new(cls, student_id, student_name, subject_id, subject_name,
            teacher_id, teacher_name, task_name, task_grade):
        grade = cls.objects.create(student_id=student_id, student_name=student_name, subject_id=subject_id,
                                   subject_name=subject_name, teacher_id=teacher_id, teacher_name=teacher_name,
                                   task_name=task_name, task_grade=task_grade)
        return grade
