from django.urls import path

from rest_framework_jwt.views import obtain_jwt_token, refresh_jwt_token

from . import views

urlpatterns = [

    path('api-token-auth/', obtain_jwt_token, name='obtain_jwt_token'),
    path('api-token-refresh/', refresh_jwt_token, name='refresh_jwt_token'),

    path('check_login/', views.check_login, name='check_login'),
    path('new_user/', views.create_new_user, name='create_new_user'),

    path('add_new_subject/', views.add_new_subject, name='add_new_subject'),
    path('add_new_task/', views.add_new_task, name='add_new_task'),
    path('add_grades/', views.add_grades_to_students, name='add_grades'),

    path('change_task/', views.change_task, name='change_task'),
    path('change_subject/', views.change_subject, name='change_subject'),
    path('change_grade/', views.change_grade, name='change_grade'),

    path('add_student/', views.add_student_in_subject, name='add_student'),
    path('remove_student/', views.remove_student_from_subject, name='remove_student'),

    path('remove_subject/', views.remove_subject, name='remove_subject'),
    path('remove_task/', views.remove_task, name='remove_task'),
    path('remove_subject_student/', views.remove_student_from_subject_by_student, name='remove_subject_student'),

    path('get_students/', views.get_students_for_subject, name='get_students'),
]