from django.urls import path
from vfb_data.views import *

urlpatterns = [
    path('display', display_data),
]