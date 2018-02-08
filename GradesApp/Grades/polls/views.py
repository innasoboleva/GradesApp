from django.shortcuts import render

# Create your views here.
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType

from django.http import HttpResponse, JsonResponse
import json

from django.db.models import Q

from django.contrib.auth.models import User
from .models import Subjects, Student_Subject, Student_Grade, Tasks


def create_permissions():
    content_type = ContentType.objects.get_for_model(Subjects)
    permission = Permission.objects.create(
        codename='can_publish_subjects',
        name='Can Publish Subjects',
        content_type=content_type,
    )
    permission = Permission.objects.create(
        codename='can_read_subjects',
        name='Can Read Subjects',
        content_type=content_type,
    )
    content_type = ContentType.objects.get_for_model(Student_Subject)
    permission = Permission.objects.create(
        codename='can_publish_student_subject',
        name='Can Publish Student_Subject',
        content_type=content_type,
    )
    permission = Permission.objects.create(
        codename='can_read_student_subject',
        name='Can Read Student Subject',
        content_type=content_type,
    )
    content_type = ContentType.objects.get_for_model(Student_Grade)
    permission = Permission.objects.create(
        codename='can_publish_student_grade',
        name='Can Publish Student Grade',
        content_type=content_type,
    )
    permission = Permission.objects.create(
        codename='can_read_student_grade',
        name='Can Read Student Grade',
        content_type=content_type,
    )

def create_new_user(request):
    # If didn't set the permissions before, run this:
    # create_permissions()
    if request.method == "POST":
        json_data = json.loads((request.body).decode('utf-8'))
        new_login = json_data["username"]
        new_password = json_data["password"]
        new_email = json_data["email"]
        new_first_name = json_data["first_name"]
        new_last_name = json_data["last_name"]
        entry = User.objects.filter(username=new_login, password=new_password).first()
        if entry:
            return JsonResponse({'status': 'false', 'message': 'user with this name and password already exists'},
                                status=500)
        new_permissions = json_data["is_teacher"]

        new_user = User.objects.create_user(username=new_login, email=new_email, password=new_password)
        new_user.first_name = new_first_name
        new_user.last_name = new_last_name

        if new_permissions == "true":
            permission = Permission.objects.get(codename='can_publish_subjects')
            new_user.user_permissions.add(permission)
            permission = Permission.objects.get(codename='can_publish_student_subject')
            new_user.user_permissions.add(permission)
            permission = Permission.objects.get(codename='can_publish_student_grade')
            new_user.user_permissions.add(permission)
        else:
            permission = Permission.objects.get(codename='can_read_subjects')
            new_user.user_permissions.add(permission)
            permission = Permission.objects.get(codename='can_read_student_subject')
            new_user.user_permissions.add(permission)
            permission = Permission.objects.get(codename='can_read_student_grade')
            new_user.user_permissions.add(permission)

        new_user.save()
        token = Token.objects.create(user=new_user)


        if new_permissions == "true":
            data = {"token": token.key, "is_teacher": "true", "subjects": []}
            return JsonResponse(data)
        else:
            data = {"token": token.key, "is_teacher": "false", "subjects": []}
            return JsonResponse(data)
    return JsonResponse({'status': 'false', 'message': 'execution did not start'}, status=500)

def load_subjects(request):
    if request.method == "GET":
        token = request.META["HTTP_AUTHORIZATION"]
        try:
            tok = Token.objects.get(key=token)
            user = tok.user
            teacher = False
            for x in Permission.objects.filter(user=user):
                if x.codename == "can_publish_subjects":
                    teacher = True
                    break

            if teacher:
                data_subjects = {}
                subjects = Subjects.objects.filter(teacher_id=user.id)
                for subject in subjects:
                    data_subjects[subject.subject_id] = subject.subject_name

                data_task = {}
                tasks = Student_Grade.objects.filter(teacher_id=user.id)
                for task in tasks:
                    data_task[task.subject_id] = (task.task_name)


                data = {}
                for some in subjects:
                    each_task = Student_Grade.objects.filter(subject_id=some.subject_id)
                    data[some.subject_id] = {}
                    for line in each_task:
                        data[some.subject_id][line.task_name] = (line.student_name, line.task_grade)

                # data_students = {}
                # for task in tasks:
                #     data_students[task.task_name] = (task.student_name, task.task_grade)

                perm = Permission.objects.get(codename='can_read_subjects')
                all_students = User.objects.filter(Q(groups__permissions=perm) | Q(user_permissions=perm)).distinct()
                data_all_students = {}
                for person in all_students:
                    data_all_students[person.id] = (person.first_name, person.last_name)

                return JsonResponse({'status': 'ok', 'token': tok.key, 'data_subjects': data_subjects,
                                     'data_task': data_task, 'all_data': data, 'all_students': data_all_students})

            else:
                data_subject_student = {}
                subjects = Student_Subject.objects.filter(student_id=user.id)
                for each in subjects:
                    data_subject_student[each.subject_id] = each.subject_name

                data_task_student = {}
                for each_one in subjects:
                    tasks = Student_Grade.objects.filter(subject_id=each_one.subject_id)
                    data_task_student[each_one.subject_id] = {}
                    for each in tasks:
                        data_task_student[each.subject_id][each.task_name] = each.task_grade

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'data_subject_student': data_subject_student,
                                     'data_task_student': data_task_student})
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def load_tasks(request):
    if request.method == "GET":
        token = request.META["HTTP_AUTHORIZATION"]
        try:
            tok = Token.objects.get(key=token)
            user = tok.user
            teacher = False
            for x in Permission.objects.filter(user=user):
                if x.codename == "can_publish_subjects":
                    teacher = True
                    break

            if teacher:
                json_data = json.loads((request.body).decode('utf-8'))
                subject_id = json_data["subject_id"]
                #subject_name = json_data["subject"]

                data_task = {}
                tasks = Student_Grade.objects.filter(teacher_id=user.id, subject_id=subject_id)
                for task in tasks:
                    data_task[task.subject_id] = (task.task_name)


                data = {}
                each_task = Student_Grade.objects.filter(subject_id=subject_id, teacher_id=user.id)
                for line in each_task:
                    data[line.task_name] = (line.student_name, line.task_grade)

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'data_task': data_task, 'all_data': data})

            else:

                return JsonResponse({'status': 'false', 'message': 'tasks supposed to read by teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def load_students_grades(request):
    if request.method == "GET":
        token = request.META["HTTP_AUTHORIZATION"]
        try:
            tok = Token.objects.get(key=token)
            user = tok.user
            teacher = False
            for x in Permission.objects.filter(user=user):
                if x.codename == "can_publish_subjects":
                    teacher = True
                    break

            if teacher:
                json_data = json.loads((request.body).decode('utf-8'))
                subject_id = json_data["subject_id"]
                task_name = json_data["task_name"]

                data = {}
                each_task = Student_Grade.objects.filter(subject_id=subject_id,
                                                         teacher_id=user.id, task_name=task_name)
                for line in each_task:
                    data[line.student_name] = line.task_grade

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'all_data': data})

            else:
                json_data = json.loads((request.body).decode('utf-8'))
                subject_id = json_data["subject_id"]

                data = {}
                each_task = Student_Grade.objects.filter(subject_id=subject_id,
                                                         student_id=user.id)
                for line in each_task:
                    data[line.task_name] = line.task_grade

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'all_data': data})
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)

def add_grades_to_students(request):
    if request.method == "POST":
        token = request.META["HTTP_AUTHORIZATION"]
        try:
            tok = Token.objects.get(key=token)
            user = tok.user
            teacher = False
            for x in Permission.objects.filter(user=user):
                if x.codename == "can_publish_student_grade":
                    teacher = True
                    break
            if teacher:
                json_data = json.loads((request.body).decode('utf-8'))
                subject_id = json_data["subject_id"]
                subject_name = json_data["subject"]
                task = json_data["task"]
                student_id = json_data["student_id"]
                student_name = json_data["student_name"]
                grade = json_data["grade"]

                entry = Student_Grade.objects(subject_id=subject_id, subject_name=subject_name,
                                                teacher_id=user.id, teacher_name=user.last_name, task_name=task,
                                              student_id=student_id, student_name=student_name,task_grade=grade)
                entry.save()
                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)

def add_new_task(request):
    if request.method == "POST":
        token = request.META["HTTP_AUTHORIZATION"]
        try:
            tok = Token.objects.get(key=token)
            user = tok.user
            teacher = False
            for x in Permission.objects.filter(user=user):
                if x.codename == "can_publish_student_subject":
                    teacher = True
                    break
            if teacher:
                json_data = json.loads((request.body).decode('utf-8'))
                subject_id = json_data["subject_id"]
                subject_name = json_data["subject"]
                new_task = json_data["task"]

                entry = Tasks.objects(subject_id=subject_id, subject_name=subject_name,
                                                teacher_id=user.id, teacher_name=user.last_name, task_name=new_task)
                entry.save()
                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def add_new_subject(request):
    if request.method == "POST":
        token = request.META["HTTP_AUTHORIZATION"]
        try:
            tok = Token.objects.get(key=token)
            user = tok.user
            teacher = False
            for x in Permission.objects.filter(user=user):
                if x.codename == "can_publish_subjects":
                    teacher = True
                    break

            if teacher:
                json_data = json.loads((request.body).decode('utf-8'))
                new_subject = json_data["subject"]

                entry = Subjects.objects(subject_id=id, subject_name=new_subject,
                                                teacher_id=user.id, teacher_name=user.last_name)
                entry.save()
                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)

def login(request):
    if request.method == "POST":
        json_data = json.loads((request.body).decode('utf-8'))
        new_login = json_data["username"]
        new_password = json_data["password"]
        entry = User.objects.filter(username=new_login, password=new_password).first()
        if entry:
            teacher = False
            tok = Token.objects.get(user=entry)
            for x in Permission.objects.filter(user=entry):
                if x.codename == "can_publish_subjects":
                    teacher = True
                    break
            if teacher:
                data_subjects = {}
                subjects = Subjects.objects.filter(teacher_id=entry.id)
                for subject in subjects:
                    data_subjects[subject.subject_id] = subject.subject_name

                data_task = {}
                tasks = Student_Grade.objects.filter(teacher_id=entry.id)
                for task in tasks:
                    data_task[task.subject_id] = (task.task_name)


                data = {}
                for some in subjects:
                    each_task = Student_Grade.objects.filter(subject_id=some.subject_id)
                    data[some.subject_id] = {}
                    for line in each_task:
                        data[some.subject_id][line.task_name] = (line.student_name, line.task_grade)

                # data_students = {}
                # for task in tasks:
                #     data_students[task.task_name] = (task.student_name, task.task_grade)

                perm = Permission.objects.get(codename='can_read_subjects')
                all_students = User.objects.filter(Q(groups__permissions=perm) | Q(user_permissions=perm)).distinct()
                data_all_students = {}
                for person in all_students:
                    data_all_students[person.id] = (person.first_name, person.last_name)

                return JsonResponse({'status': 'ok', 'token': tok.key, 'data_subjects': data_subjects,
                                     'data_task': data_task, 'all_data': data, 'all_students': data_all_students})

            else:
                data_subject_student = {}
                subjects = Student_Subject.objects.filter(student_id=entry.id)
                for each in subjects:
                    data_subject_student[each.subject_id] = each.subject_name

                data_task_student = {}
                for each_one in subjects:
                    tasks = Student_Grade.objects.filter(subject_id=each_one.subject_id)
                    data_task_student[each_one.subject_id] = {}
                    for each in tasks:
                        data_task_student[each.subject_id][each.task_name] = each.task_grade

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'data_subject_student': data_subject_student,
                                     'data_task_student': data_task_student})
    return JsonResponse({'status': 'false', 'message': 'execution did not start'}, status=404)
