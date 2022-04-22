from django.urls import path
from vfb_data.views import *
from vfb import view
urlpatterns = [
    path('game',search_game),
    path('delete', delete),
    path('insert_game', insert_game),
    path('play_type', search_play_type),
    path('update_game', update_game),
    path('dashboard1', dashboard1),
]