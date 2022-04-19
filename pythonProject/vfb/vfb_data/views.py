from django.shortcuts import render
from django.db import connection
from django.core.paginator import Paginator, PageNotAnInteger, EmptyPage, InvalidPage


# Create your views here.
from vfb_data.models import *

def display_data(request):
    data_list = AllPlays.objects.all()[:20]
    return render(request, 'display.html',locals())

def login(request):
    return render(request,'loginin.html',locals() )






def search(request):
    db = AllPlays.objects.all()[:20]
    dict = {}
    count = 0
    if request.method == "GET":
        get_id = request.GET.get("id")
        if get_id != "" and get_id is not None:
            dict["i_d"] = get_id
            count = count + 1
        get_driver = request.GET.get("driver")
        if get_driver != "" and get_driver is not None:
            dict["drive_id"] = get_driver
            count = count + 1
        get_play = request.GET.get("play number")
        if get_play != "" and get_play is not None:
            dict["play_number"] = get_play
            count = count + 1
        get_year = request.GET.get("year")
        if get_year != "" and get_year is not None:
            dict["year"] = get_year
            count = count + 1
        get_home = request.GET.get("home")
        if get_home != "" and get_home is not None:
            dict["home"] = get_home
            count = count + 1


        if  count == 0:
            db = AllPlays.objects.all()[:20]
        else:
            db = AllPlays.objects.filter(**dict)[:20]

    return render(request, "display.html",locals())



def delete(request):
    if request.method == "GET":
        get_delete_id = request.GET.get("delete_id")
        if get_delete_id is not None and get_delete_id != "":
            with connection.cursor() as cursor:
                cursor.callproc("demo", [int(get_delete_id)])
    return render(request, "manage_delete.html", locals())








