from django.urls import path
from vfb_data.views import *

urlpatterns = [
    path('display',search),
    path('login', login),
    path('manage/delete', delete),

]