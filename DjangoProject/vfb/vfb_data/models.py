# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AllPlays(models.Model):
    i_d = models.CharField(db_column='I_D', max_length=255, blank=True,primary_key=True)  # Field name made lowercase.
    drive_id = models.CharField(max_length=255, blank=True, null=True)
    game_id = models.CharField(max_length=255, blank=True, null=True)
    drive_number = models.IntegerField(blank=True, null=True)
    play_number = models.IntegerField(blank=True, null=True)
    offense = models.CharField(max_length=255, blank=True, null=True)
    offense_conference = models.CharField(max_length=255, blank=True, null=True)
    offense_score = models.IntegerField(blank=True, null=True)
    defense = models.CharField(max_length=255, blank=True, null=True)
    home = models.CharField(max_length=255, blank=True, null=True)
    away = models.CharField(max_length=255, blank=True, null=True)
    defense_conference = models.CharField(max_length=255, blank=True, null=True)
    defense_score = models.IntegerField(blank=True, null=True)
    period = models.IntegerField(blank=True, null=True)
    clock = models.CharField(max_length=255, blank=True, null=True)
    offense_timeouts = models.IntegerField(blank=True, null=True)
    defense_timeouts = models.IntegerField(blank=True, null=True)
    yard_line = models.IntegerField(blank=True, null=True)
    yards_to_goal = models.IntegerField(blank=True, null=True)
    down = models.CharField(max_length=255, blank=True, null=True)
    distance = models.CharField(max_length=255, blank=True, null=True)
    yards_gained = models.CharField(max_length=255, blank=True, null=True)
    scoring = models.CharField(max_length=255, blank=True, null=True)
    play_type = models.CharField(max_length=255, blank=True, null=True)
    play_text = models.CharField(max_length=800, blank=True, null=True)
    ppa = models.CharField(max_length=255, blank=True, null=True)
    wallclock = models.CharField(max_length=255, blank=True, null=True)
    week = models.IntegerField(blank=True, null=True)
    season = models.IntegerField(blank=True, null=True)
    year = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'all_plays'
