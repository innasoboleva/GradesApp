# Create your views here.
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType

from django.http import JsonResponse
import json

from django.db.models import Q

from django.contrib.auth.models import User
from .models import Subjects, StudentSubject, StudentGrade, Tasks


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
    content_type = ContentType.objects.get_for_model(StudentSubject)
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
    content_type = ContentType.objects.get_for_model(StudentGrade)
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
    # If didn't set permissions before, run create_permissions()
    if request.method == "POST":
        json_data = json.loads(request.body.decode('utf-8'))
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
            perm = Permission.objects.get(codename='can_read_subjects')
            all_students = User.objects.filter(Q(groups__permissions=perm) | Q(user_permissions=perm)).distinct()
            data_all_students = {}
            for person in all_students:
                data_all_students[person.id] = (person.first_name, person.last_name)
            data = {"token": token.key, "is_teacher": "true", "all_students": data_all_students}
            return JsonResponse(data)
        else:
            data = {"token": token.key, "is_teacher": "false"}
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
                tasks = StudentGrade.objects.filter(teacher_id=user.id)
                for task in tasks:
                    data_task[task.subject_id] = task.task_name

                data = {}
                for some in subjects:
                    each_task = StudentGrade.objects.filter(subject_id=some.subject_id)
                    data[some.subject_id] = {}
                    for line in each_task:
                        data[some.subject_id][line.task_name] = (line.student_name, line.task_grade)

                perm = Permission.objects.get(codename='can_read_subjects')
                all_students = User.objects.filter(Q(groups__permissions=perm) | Q(user_permissions=perm)).distinct()
                data_all_students = {}
                for person in all_students:
                    data_all_students[person.id] = (person.first_name, person.last_name)

                return JsonResponse({'status': 'ok', 'token': tok.key, 'data_subjects': data_subjects,
                                     'data_task': data_task, 'all_data': data, 'all_students': data_all_students})

            else:
                data_subject_student = {}
                subjects = StudentSubject.objects.filter(student_id=user.id)
                for each in subjects:
                    data_subject_student[each.subject_id] = each.subject_name

                data_task_student = {}
                for each_one in subjects:
                    tasks = StudentGrade.objects.filter(subject_id=each_one.subject_id)
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]

                data_task = {}
                tasks = StudentGrade.objects.filter(teacher_id=user.id, subject_id=subject_id)
                for task in tasks:
                    data_task[task.subject_id] = task.task_name

                data = {}
                each_task = StudentGrade.objects.filter(subject_id=subject_id, teacher_id=user.id)
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                task_name = json_data["task_name"]

                data = {}
                each_task = StudentGrade.objects.filter(subject_id=subject_id,
                                                         teacher_id=user.id, task_name=task_name)
                for line in each_task:
                    data[line.student_name] = line.task_grade

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'all_data': data})

            else:
                json_data = json.loads((request.body).decode('utf-8'))
                subject_id = json_data["subject_id"]

                data = {}
                each_task = StudentGrade.objects.filter(subject_id=subject_id,
                                                         student_id=user.id)
                for line in each_task:
                    data[line.task_name] = line.task_grade

                return JsonResponse({'status': 'ok', 'token': tok.key,
                                     'all_data': data})
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def add_grades_to_students(request):
    # adding NEW grades to database
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                subject_name = json_data["subject"]
                task = json_data["task"]
                task_with_students = json_data["task_with_data"]

                # check existing tasks and students in a subjects table
                students_in_a_task = StudentGrade.objects.filter(subject_id=int(subject_id),
                                                                 task_name=task_with_students)
                for each_student in students_in_a_task:
                    new_entry = StudentGrade.new(each_student.student_id, each_student.student_name,
                                                 int(subject_id), subject_name, user.id, user.last_name,
                                                 task, 0)

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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                subject_name = json_data["subject"]
                new_task = json_data["task"]

                entry = Tasks.new(int(subject_id), subject_name, user.id,
                                  user.last_name, new_task)
                return JsonResponse({'status': 'ok', 'task_id': str(entry.id)})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=400)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=404)


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
                json_data = json.loads(request.body.decode('utf-8'))
                new_subject = json_data["subject"]
                entry = Subjects.new(new_subject, user.id, user.last_name)
                return JsonResponse({'status': 'ok', 'subject_id': str(entry.id)})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def check_login(request):
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
                data_subjects = {}
                data_task = {}

                subjects = Subjects.objects.filter(teacher_id=user.id)
                for subject in subjects:
                    data_subjects[str(subject.id)] = subject.subject_name
                    tasks = Tasks.objects.filter(subject_id=subject.id)
                    data_task[str(subject.id)] = {}

                    for task in tasks:
                        data_task[str(subject.id)][str(task.id)] = task.task_name

                data = {}
                for some in subjects:
                    each_task = StudentGrade.objects.filter(subject_id=some.id)
                    data[str(some.id)] = {}
                    for line in each_task:
                        each_student = StudentGrade.objects.filter(subject_id=some.id, task_name=line.task_name)
                        data[str(some.id)][line.task_name] = []
                        for student in each_student:
                            list_of_info = [str(student.student_id), student.student_name, str(student.task_grade)]
                            data[str(some.id)][line.task_name].append(list_of_info)

                perm = Permission.objects.get(codename='can_read_subjects')
                all_students = User.objects.filter(Q(groups__permissions=perm) | Q(user_permissions=perm)).distinct()
                data_all_students = {}
                for person in all_students:
                    data_all_students[str(person.id)] = [person.first_name, person.last_name]

                return JsonResponse({'status': 'ok', 'is_teacher': 'true', 'token': tok.key,
                                     'data_subjects': data_subjects,
                                     'data_task': data_task,
                                     'all_data': data,
                                     'all_students': data_all_students})

            else:
                data_subject_student = {}
                data_task_student = {}
                subjects = StudentSubject.objects.filter(student_id=user.id)
                for each in subjects:
                    data_subject_student[str(each.subject_id)] = each.subject_name
                    data_task_student[str(each.subject_id)] = {}

                    tasks = StudentGrade.objects.filter(subject_id=each.subject_id)
                    for each_task in tasks:
                        data_task_student[str(each.subject_id)][each_task.task_name] = str(each_task.task_grade)

                return JsonResponse({'status': 'ok', 'token': tok.key, 'is_teacher': 'false',
                                     'data_subject_student': data_subject_student,
                                     'data_task_student': data_task_student})
        except:
            return JsonResponse({'status': 'false', 'message': 'user does not exist'}, status=404)
    return JsonResponse({'status': 'false', 'message': 'execution did not start'}, status=404)


def change_task(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                old_task_name = json_data["old_task_name"]
                new_task_name = json_data["new_task_name"]

                entries_for_task = Tasks.objects.filter(subject_id=subject_id,
                                                        teacher_id=user.id, task_name=old_task_name)
                for entry in entries_for_task:
                    entry.task_name = new_task_name
                    entry.save()

                entries_for_grades = StudentGrade.objects.filter(subject_id=subject_id,
                                                                  teacher_id=user.id, task_name=old_task_name)

                for entry in entries_for_grades:
                    entry.task_name = new_task_name
                    entry.save()

                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def change_subject(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                subject_name = json_data["subject_name"]

                entries_for_subject = Subjects.objects.filter(subject_id=subject_id, teacher_id=user.id)
                for entry in entries_for_subject:
                    entry.subject_name = subject_name
                    entry.save()

                entries_for_sstudent_ubject = StudentSubject.objects.filter(subject_id=subject_id, teacher_id=user.id)
                for entry in entries_for_sstudent_ubject:
                    entry.subject_name = subject_name
                    entry.save()

                entries_for_task = Tasks.objects.filter(subject_id=subject_id, teacher_id=user.id)
                for entry in entries_for_task:
                    entry.subject_name = subject_name
                    entry.save()

                entries_for_grades = StudentGrade(subject_id=subject_id, teacher_id=user.id)
                for entry in entries_for_grades:
                    entry.subject_name = subject_name
                    entry.save()

                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def change_grade(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                task_name = json_data["task_name"]
                user_grade = json_data["user_grade"]
                student_id = json_data["student_id"]
                entries_for_grade = StudentGrade.objects.filter(subject_id=int(subject_id), teacher_id=user.id,
                                                                student_id=int(student_id), task_name=task_name)
                for entry in entries_for_grade:
                    entry.task_grade = int(user_grade)
                    entry.save()

                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=500)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def add_student_in_subject(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                students_id = json_data["students_id"]
                subject_name = json_data["subject_name"]

                for student in students_id:

                    fetch_users_name = User.objects.get(id=int(student))
                    new_student_subject = StudentSubject.new(int(student),
                                                             fetch_users_name.last_name,
                                                             int(subject_id),
                                                             subject_name,
                                                             user.id,
                                                             user.last_name)
                    fetch_tasks = Tasks.objects.filter(subject_id=int(subject_id))
                    for task in fetch_tasks:
                        new_student_grade = StudentGrade.new(int(student), fetch_users_name.last_name,
                                                             int(subject_id), subject_name, user.id,
                                                             user.last_name, task.task_name, 0)
                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=404)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=400)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def remove_student_from_subject(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                students_id = json_data["students_id"]
                for student in students_id:
                    student_subject = StudentSubject.objects.filter(student_id=int(student),
                                                                    subject_id=int(subject_id))
                    for each_student in student_subject:
                        each_student.delete()

                    students_grades = StudentGrade.objects.filter(student_id=int(student),
                                                                  subject_id=int(subject_id))
                    for each_grade in students_grades:
                        each_grade.delete()

                return JsonResponse({'status': 'ok'})
            else:
                JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=404)
        except:
            return JsonResponse({'status': 'false', 'message': 'token out of date'}, status=400)
    return JsonResponse({'status': 'false', 'message': 'wrong method'}, status=500)


def remove_subject(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]

                subjects = Subjects.objects.filter(teacher_id=user.id, id=int(subject_id))
                if subjects.exists():
                    for i in subjects:
                        i.delete()

                students_subject = StudentSubject.objects.filter(teacher_id=user.id, subject_id=int(subject_id))
                if students_subject.exists():
                    for subj in students_subject:
                        subj.delete()

                tasks = Tasks.objects.filter(teacher_id=user.id, subject_id=int(subject_id))
                if tasks.exists():
                    for task in tasks:
                        task.delete()

                grades = StudentGrade.objects.filter(teacher_id=user.id, subject_id=int(subject_id))
                if grades.exists():
                    for grade in grades:
                        grade.delete()

                return JsonResponse({'status': 'ok'})

            else:
                return JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'user does not exist'}, status=400)
    return JsonResponse({'status': 'false', 'message': 'execution did not start'}, status=404)


def remove_task(request):
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
                json_data = json.loads(request.body.decode('utf-8'))
                subject_id = json_data["subject_id"]
                task_name = json_data["task_name"]

                tasks = Tasks.objects.filter(teacher_id=user.id, subject_id=int(subject_id), task_name=task_name)
                if tasks.exists():
                    for task in tasks:
                        task.delete()
                grades = StudentGrade.objects.filter(teacher_id=user.id, subject_id=int(subject_id),
                                                     task_name=task_name)
                if grades.exists():
                    for grade in grades:
                        grade.delete()
                return JsonResponse({'status': 'ok'})

            else:
                return JsonResponse({'status': 'false', 'message': 'not a teacher'}, status=500)
        except:
            return JsonResponse({'status': 'false', 'message': 'user does not exist'}, status=400)
    return JsonResponse({'status': 'false', 'message': 'execution did not start'}, status=404)
