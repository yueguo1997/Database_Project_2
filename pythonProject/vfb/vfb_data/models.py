# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AllPlays(models.Model):
    i_d = models.BigIntegerField(db_column='I_D', blank=True, null=True)  # Field name made lowercase.
    drive_id = models.BigIntegerField(blank=True, null=True)
    game_id = models.BigIntegerField(blank=True, null=True)
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


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.IntegerField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.IntegerField()
    is_active = models.IntegerField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.PositiveSmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Drive(models.Model):
    drive_id = models.BigIntegerField(primary_key=True)
    drive_number = models.IntegerField(blank=True, null=True)
    game = models.ForeignKey('Game', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'drive'


class DriveDairy(models.Model):
    action_id = models.AutoField(primary_key=True)
    drive_id = models.BigIntegerField(blank=True, null=True)
    play_number = models.IntegerField(blank=True, null=True)
    action_time = models.DateTimeField(blank=True, null=True)
    action = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'drive_dairy'


class Game(models.Model):
    game_id = models.BigIntegerField(primary_key=True)
    home = models.CharField(max_length=255, blank=True, null=True)
    away = models.CharField(max_length=255, blank=True, null=True)
    week = models.PositiveIntegerField(blank=True, null=True)
    season = models.PositiveIntegerField(blank=True, null=True)
    year = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'game'


class GameDairy(models.Model):
    action_id = models.AutoField(primary_key=True)
    game_id = models.BigIntegerField(blank=True, null=True)
    home = models.CharField(max_length=255, blank=True, null=True)
    away = models.CharField(max_length=255, blank=True, null=True)
    week = models.IntegerField(blank=True, null=True)
    season = models.IntegerField(blank=True, null=True)
    year = models.CharField(max_length=255, blank=True, null=True)
    action_time = models.DateTimeField(blank=True, null=True)
    action = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'game_dairy'


class Play(models.Model):
    drive_id = models.BigIntegerField(primary_key=True)
    play_number = models.PositiveIntegerField()
    period = models.IntegerField(blank=True, null=True)
    offense_score = models.IntegerField(blank=True, null=True)
    defense_score = models.IntegerField(blank=True, null=True)
    offense_timeouts = models.IntegerField(blank=True, null=True)
    defense_timeouts = models.IntegerField(blank=True, null=True)
    wallclock = models.CharField(max_length=255, blank=True, null=True)
    offense = models.ForeignKey('TeamOffense', models.DO_NOTHING, db_column='offense', blank=True, null=True)
    defense = models.ForeignKey('TeamDefense', models.DO_NOTHING, db_column='defense', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'play'
        unique_together = (('drive_id', 'play_number'),)


class PlayDrive(models.Model):
    i_d = models.BigAutoField(db_column='I_D', primary_key=True)  # Field name made lowercase.
    drive = models.ForeignKey(Play, models.DO_NOTHING, blank=True, null=True, related_name = "drive")
    play_number = models.ForeignKey(Play, models.DO_NOTHING, db_column='play_number', blank=True, null=True)
    clock = models.CharField(max_length=255, blank=True, null=True)
    yard_line = models.IntegerField(blank=True, null=True)
    yards_to_goal = models.IntegerField(blank=True, null=True)
    down = models.IntegerField(blank=True, null=True)
    distance = models.IntegerField(blank=True, null=True)
    yards_gained = models.IntegerField(blank=True, null=True)
    play_type = models.ForeignKey('Playtype', models.DO_NOTHING, db_column='play_type', blank=True, null=True)
    play_text = models.CharField(max_length=800, blank=True, null=True)
    ppa = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'play_drive'


class Playtype(models.Model):
    play_type = models.CharField(primary_key=True, max_length=255)
    scoring = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'playtype'


class TeamDefense(models.Model):
    defense = models.CharField(primary_key=True, max_length=255)
    year = models.CharField(max_length=255)
    defense_conference = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'team_defense'
        unique_together = (('defense', 'year'),)


class TeamOffense(models.Model):
    offense = models.CharField(primary_key=True, max_length=255)
    year = models.CharField(max_length=255)
    offense_conference = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'team_offense'
        unique_together = (('offense', 'year'),)

class GameScore(models.Model):
    game_id = models.BigIntegerField(primary_key=True)
    season = models.IntegerField()
    home = models.CharField(max_length=255)
    away = models.CharField(max_length=255)
    home_score  = models.BigIntegerField()
    away_score = models.BigIntegerField()
    class Meta:
        managed = False
        db_table = 'game_score'


class TeamScore(models.Model):
    season = models.IntegerField(primary_key= True)
    winner = models.CharField(max_length=255)
    wins = models.IntegerField()
    class Meta:
        managed = False
        db_table = 'team_score'
