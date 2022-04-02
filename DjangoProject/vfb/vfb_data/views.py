from django.shortcuts import render

# Create your views here.
from vfb_data.models import *

def display_data(request):
    data_list = AllPlays.objects.all()
    return render(request, 'display.html',locals())