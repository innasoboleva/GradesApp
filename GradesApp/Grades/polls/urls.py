from django.urls import path

from rest_framework.authtoken import views as rest_framework_views

from . import views

urlpatterns = [

    path('get_auth_token/', rest_framework_views.obtain_auth_token, name='get_auth_token'),
    path('check_login/', views.check_login, name='check_login'),
    path('new_user/', views.create_new_user, name='create_new_user'),

    path('add_new_subject/', views.add_new_subject, name='add_new_subject'),
    path('add_new_task/', views.add_new_task, name='add_new_task'),
    path('add_grades/', views.add_grades_to_students, name='add_grades'),

    path('load_subjects/', views.load_subjects, name='load_subjects'),
    path('load_tasks/', views.load_tasks, name='load_tasks'),
    path('load_students_grades/', views.load_students_grades, name='load_students_grades'),

    path('change_task/', views.change_task, name='change_task'),
    path('change_subject/', views.change_subject, name='change_subject'),
    path('change_grade/', views.change_grade, name='change_grade'),

    path('add_student/', views.add_student_in_subject, name='add_student'),
    path('remove_student/', views.remove_student_from_subject, name='remove_student'),

    path('remove_subject/', views.remove_subject, name='remove_subject'),
    path('remove_task/', views.remove_task, name='remove_task'),

    #path('check_login_token/', views.check_login_token, name='check_login_token'),



]