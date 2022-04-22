from django.shortcuts import render
from django.db import connection
from plotly.offline import plot
import plotly.graph_objects as go

# Create your views here.
from vfb_data.models import *


def search_game(request):
    db = Game.objects.all()[:100]
    dict = {}
    count = 0
    if request.method == "GET":
        get_id = request.GET.get("game_id")
        if get_id != "" and get_id is not None:
            dict["game_id"] = get_id
            count = count + 1
        get_home = request.GET.get("home")
        if get_home != "" and get_home is not None:
            dict["home"] = get_home
            count = count + 1
        get_away = request.GET.get("away")
        if get_away != "" and get_away is not None:
            dict["away"] = get_away
            count = count + 1
        get_week = request.GET.get("week")
        if get_week != "" and get_week is not None:
            dict["week"] = get_week
            count = count + 1
        get_season = request.GET.get("season")
        if get_season  != "" and get_season  is not None:
            dict["season"] = get_season
            count = count + 1

        if  count == 0:
            db = Game.objects.all()[:100]
        else:
            db = Game.objects.filter(**dict)[:100]

    return render(request, "display.html",locals())

def search_play_type(request):
    db = Playtype.objects.all()
    dict = {}
    count = 0
    if request.method == "GET":
        get_play_type = request.GET.get("search_playtype")
        if get_play_type != "" and get_play_type is not None:
            dict["play_type"] = get_play_type
            count = count + 1
        get_scoring = request.GET.get("search_score")
        if get_scoring != "" and get_scoring is not None:
            dict["scoring"] = get_scoring
            count = count + 1
        if count == 0:
            db = Playtype.objects.all()[:100]
        else:
            db = Playtype.objects.filter(**dict)[:100]
    return render(request, "display_playtype.html", locals())



def delete(request):
    result = "Please insert the game id which you want to delete"
    if request.method == "GET":
        get_delete_id = request.GET.get("delete_id")
        if get_delete_id is not None and get_delete_id != "":
            with connection.cursor() as cursor:
                cursor.callproc("delete_game", [int(get_delete_id)])
                result = cursor.fetchall()[0][0]
    return render(request, "manage_delete.html", locals())

def insert_game(request):
    result = "Please fill in the Game table insert form"
    count = 0
    if request.method == "GET":
        get_game_id = request.GET.get("insert_game_id")
        if get_game_id == "" or get_game_id is None:
            count = count + 1
        get_home = request.GET.get("insert_home")
        if get_home == "" or get_home is None:
            count = count +1
        get_away = request.GET.get("insert_away")
        if get_away == "" or get_away is None:
            count = count +1
        get_week = request.GET.get("insert_week")
        if get_week == "" or get_week is None:
            count = count +1
        get_season = request.GET.get("insert_season")
        if get_season == "" or get_season is None:
            count = count +1
        get_year = request.GET.get("insert_year")
        if get_year == "" or get_year is None:
            count = count +1
        if count == 0:
            with connection.cursor() as cursor:
                cursor.callproc("insert_game", [get_game_id, get_home, get_away,get_week, get_season,get_year])
                result = cursor.fetchall()[0][0]
    return render(request, "manage_insert.html", locals())



def update_game(request):
    result = "Please fill in the Game table update form"
    count = 0
    if request.method == "GET":
        get_game_id = request.GET.get("insert_game_id")
        if get_game_id == "" or get_game_id is None:
            count = count + 1
        get_home = request.GET.get("insert_home")
        if get_home == "" or get_home is None:
            count = count +1
        get_away = request.GET.get("insert_away")
        if get_away == "" or get_away is None:
            count = count +1
        get_week = request.GET.get("insert_week")
        if get_week == "" or get_week is None:
            count = count +1
        get_season = request.GET.get("insert_season")
        if get_season == "" or get_season is None:
            count = count +1
        get_year = request.GET.get("insert_year")
        if get_year == "" or get_year is None:
            count = count +1
        if count == 0:
            with connection.cursor() as cursor:
                cursor.callproc("update_game", [get_game_id, get_home, get_away,get_week, get_season,get_year])
                result = cursor.fetchall()[0][0]
    return render(request, "manage_update_game.html", locals())



def dashboard1(request):
    db = cpt.objects.all()
    list1 = [i for i in range(1,10)]
    list2 = [i for i in range(1,10)]
    list3 = [-i for i in range(1,10)]

    graphs1 = []
    graphs2 = []
    graphs1.append(
        go.Bar(x=list1, y=list2, name='Bar')
    )
    graphs2.append(
        go.Bar(x=list1, y=list3, name='Bar')
    )
    layout = {
        'title': 'Title of the figure',
        'xaxis_title': 'X_value',
        'yaxis_title': 'Y',
        'height': 420,
        'width': 560,
    }
    plot_div1 = plot({'data': graphs1, 'layout': layout},
                    output_type='div')
    plot_div2 = plot({'data': graphs2, 'layout': layout},
                     output_type='div')

    return render(request,"dashboard1.html", locals())