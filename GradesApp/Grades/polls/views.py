from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse
from .models import Users, Subjects, Student_Subject, Student_Grade


def index(request):
    new_login = "first"
    new_password = "My password"

    entry = Users.objects.filter(user_login=new_login, user_password=new_password).first()
    if entry:
        if entry.user_teacher:
            subjects_for_teacher(request, entry.id)
        else:
            some = Student_Subject.objects.filter(student_id=entry.id)
            if some:
                context = {
                    "object_list": some,
                    }
                return render(request, "subjects.html", context)

    else:
        return HttpResponse("Wrong credentials")


    # name = "One"
    # teacher_is = True
    # new_subject = "COMSC"
    # new_subject_id = 900
    # grade1 = "A"
    # grade2 = "B"
    # task1 = "task1"
    # task2 = "task2"
    #
    # v = Users.objects.filter(user_login=new_login)
    # if v:
    #     return HttpResponse("wrong data")
    #
    # else:
    #     b = Users(user_login=new_login, user_password=new_password,user_name=name,user_teacher=teacher_is,)
    #     b.save()
    #     entry = Users.objects.get(user_login=new_login)
    #     v = Subjects(subject_id=new_subject_id,subject_name=new_subject,teacher_id=entry.id,teacher_name=entry.user_name)
    #     v.save()
    #     st1 = Users.objects.get(user_login="first")
    #     st2 = Users.objects.get(user_login="second")
    #     next_entry = Student_Subject(student_id=st1.id,student_name=st1.user_name,subject_id=new_subject_id,subject_name=new_subject,teacher_id=entry.id,teacher_name=entry.user_name)
    #     next_entry.save()
    #     next_entry2 = Student_Subject(student_id=st2.id,student_name=st2.user_name,subject_id=new_subject_id,subject_name=new_subject,teacher_id=entry.id,teacher_name=entry.user_name)
    #     next_entry2.save()
    #
    #     all_subjects = Users.objects.all()
    #     context = {
    #         "object_users": all_subjects,
    #         }
    #     return render(request, "index.html", context)

def subjects_for_student(request, unique_id):
    entry = Student_Subject.objects.filter(student_id=unique_id)
    if entry:
        context = {
            "object_list": entry,
            }
        return render(request, "subjects.html", context)
    else:
        HttpResponse("No subjects for student")

def grades_for_student(request, unique_id, subject_num):
    entry = Student_Grade.objects.filter(student_id=unique_id, subject_id=subject_num)
    if entry:
        context = {
            "object_list": entry,
            }
        return render(request, "grades.html", context)
    else:
        HttpResponse("No grades for student")

def subjects_for_teacher(request, unique_id):
    entry = Subjects.objects.filter(teacher_id=unique_id)
    if entry:
        context = {
            "object_list": entry,
            }
        return render(request, "teacher_s.html", context)
    else:
        HttpResponse("No subjects for teacher")

def students_and_subjects_for_teacher(request, unique_id, subject_num):
    entry = Student_Grade.objects.filter(teacher_id=unique_id, subject_id=subject_num)
    if entry:
        context = {
            "object_list": entry,
            }
        return render(request, "index.html", context)
    else:
        HttpResponse("No students under subject")

def add_new_subject(request, unique_id, subject_num, subject_name):
    entry = Subjects.objects.filter(teacher_id=unique_id, subject_id=subject_num)
    if entry:
        HttpResponse("Subject already exists")
    else:
        b = Users.objects.get(id=unique_id)
        new_entry = Subjects(subject_id=subject_num,subject_name=subject_name,teacher_id=unique_id,teacher_name=b.user_name)
        new_entry.save()
        list = Subjects.objects.filter(teacher_id=unique_id, subject_id=subject_num)

        all = Users.objects.all()
        context = {
            "object_list": all,
            }
        return render(request, "index.html", context)

def login(request, login, password):
    entry = Users.objects.filter(user_login=login, user_password=password).first()
    if entry:
        if entry.user_teacher:
            subjects_for_teacher(request, entry.id)
        else:
            subjects_for_student(request, entry.id)
    else:
        return HttpResponse("Wrong credentials")

def new_user(request, login_new, password, name, teacher):
    entry = Subjects.objects.filter(user_login=login_new, user_password=password)
    if entry:
        return HttpResponse("Wrong credentials")
    else:
        new_user = Users(user_login=login_new,user_password=password,user_name=name,user_teacher=teacher,)
        new_user.save()
        b = Users.objects.get(user_login=login_new)
        if b.user_teacher:
            subjects_for_teacher(request, b.id)
        else:
            subjects_for_student(request, b.id)
