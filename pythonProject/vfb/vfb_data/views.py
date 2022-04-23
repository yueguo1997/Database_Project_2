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

def search_game_score(request):
    db = GameScore.objects.all()
    dict = {}
    count = 0
    if request.method == "GET":
        get_gamescore_home = request.GET.get("game_score_home")
        if get_gamescore_home!= "" and get_gamescore_home is not None:
            dict["home"] = get_gamescore_home
            count = count + 1
        get_away = request.GET.get("game_score_away")
        if get_away != "" and get_away is not None:
            dict["away"] = get_away
            count = count + 1
        get_game_score_season = request.GET.get("game_score_season")
        if get_game_score_season != "" and get_game_score_season is not None:
            dict["season"] = get_game_score_season
            count = count + 1
        if count == 0:
            db = GameScore.objects.all()[:100]
        else:
            db = GameScore.objects.filter(**dict)[:100]
    return render(request, "display_gamescore.html", locals())


def search_team_score(request):
    db = TeamScore.objects.all()
    dict = {}
    count = 0
    if request.method == "GET":
        get_season = request.GET.get("search_teamscore_season")
        if get_season != "" and get_season is not None:
            dict["season"] = get_season
            count = count + 1
        get_team = request.GET.get("search_teamscore_team")
        if get_team != "" and get_team is not None:
            dict["winner"] = get_team
            count = count + 1
        if count == 0:
            db = TeamScore.objects.all()[:100]
        else:
            db = TeamScore.objects.filter(**dict)[:100]
    return render(request, "display_team_score.html", locals())

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


def insert_drive(request):
    result = "Please fill in the drive table update form"
    count = 0
    if request.method == "GET":
        get_game_id = request.GET.get("insert_drive_gameid")
        if get_game_id == "" or get_game_id is None:
            count = count + 1
        get_drive_number = request.GET.get("insert_drive_drivenumber")
        if get_drive_number  == "" or get_drive_number  is None:
            count = count + 1
        get_drive_off = request.GET.get("insert_drive_off")
        if get_drive_off == "" or get_drive_off is None:
            count = count + 1
        get_offscore = request.GET.get("insert_drive_offscore")
        if get_offscore == "" or get_offscore is None:
            count = count + 1
        get_drive_de = request.GET.get("insert_drive_de")
        if get_drive_de == "" or get_drive_de is None:
            count = count + 1
        get_drive_descore = request.GET.get("insert_drive_descore")
        if get_drive_descore == "" or get_drive_descore is None:
            count = count + 1
        get_drive_playnumber = request.GET.get("insert_drive_playnumber")
        if get_drive_playnumber == "" or get_drive_playnumber is None:
            count = count + 1
        get_drive_clock = request.GET.get("insert_drive_clock")
        if get_drive_clock == "" or get_drive_clock is None:
            count = count + 1
        get_drive_yardline = request.GET.get("insert_drive_yardline")
        if get_drive_yardline == "" or get_drive_yardline is None:
            count = count + 1
        get_drive_yardgoal = request.GET.get("insert_drive_yardgoal")
        if get_drive_yardgoal == "" or get_drive_yardgoal is None:
            count = count + 1
        get_drive_yardgain = request.GET.get("insert_drive_yardgain")
        if get_drive_yardgain == "" or get_drive_yardgain is None:
            count = count + 1
        get_drive_yarddown = request.GET.get("insert_drive_yarddown")
        if get_drive_yarddown == "" or get_drive_yarddown is None:
            count = count + 1
        get_drive_distance= request.GET.get("insert_drive_distance")
        if get_drive_distance == "" or get_drive_distance is None:
            count = count + 1
        get_drive_period = request.GET.get("insert_drive_period")
        if get_drive_period == "" or get_drive_period is None:
            count = count + 1
        get_drive_playtype = request.GET.get("insert_drive_playtype")
        if get_drive_playtype == "" or get_drive_playtype is None:
            count = count + 1
        get_drive_playtext = request.GET.get("insert_drive_playtext")
        if get_drive_playtext == "" or get_drive_playtext is None:
            count = count + 1


        if count == 0:
            with connection.cursor() as cursor:
                cursor.callproc("insert_drive", [get_game_id, get_drive_number,get_drive_off,get_offscore,get_drive_de,get_drive_descore,get_drive_playnumber,get_drive_clock,get_drive_yardline ,get_drive_yardgoal,get_drive_yardgain,get_drive_yarddown,get_drive_distance,get_drive_period,get_drive_playtype, get_drive_playtext])
                result = cursor.fetchall()[0][0]
    return render(request, "manage_insert_drive.html", locals())



def dashboard1(request):
    with connection.cursor() as cursor:
        cursor.callproc("exposive_play",[])
        result = cursor.fetchall()
        list1 = []
        list2 = []
        for i in result:
            list1.append(list(i)[0])
            list2.append(list(i)[1])
    graphs1 = []
    graphs1.append(
        go.Scatter(x=list1, y=list2, mode='markers', opacity=0.8,
                   marker_size=list1, name='Scatter y2'))

    layout = {
        'title': 'Title of the figure',
        'xaxis_title': 'X_value',
        'yaxis_title': 'Y',
        'height': 600,
        'width': 800,
    }
    plot_div1 = plot({'data': graphs1, 'layout': layout},
                    output_type='div')

    return render(request,"dashboard1.html", locals())


def drive_dairy(request):
    db = DriveDairy.objects.all()
    return render(request, "Drive_Dairy.html", locals())

def game_dairy(request):
    db = GameDairy.objects.all()
    return render(request, "Game_Dairy.html", locals())