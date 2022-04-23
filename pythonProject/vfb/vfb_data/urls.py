from django.urls import path
from vfb_data.views import *
from vfb import view
urlpatterns = [
    path('game',search_game),
    path('game_score',search_game_score),
    path('delete', delete),
    path('insert_game', insert_game),
    path('play_type', search_play_type),
    path('update_game', update_game),
    path('insert_drive', insert_drive),
    path('dashboard1', dashboard1),
    path('team_score', search_team_score),
    path('drive_dairy', drive_dairy),
    path('game_dairy', game_dairy),

]