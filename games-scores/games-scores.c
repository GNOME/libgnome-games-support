/*
 * Copyright 2005 Callum McKenzie
 *
 * This library is free software; you can redistribute it and'or modify
 * it under the terms of the GNU Library General Public License as published
 * by the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; if not, see <http://www.gnu.org/licenses/>.
 */

/* Authors:   Callum McKenzie <callum@physics.otago.ac.nz> */

/* FIXME: Document */

#include <config.h>

#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <glib/gi18n.h>
#include <glib.h>
#include <glib-object.h>

#include "games-score.h"
#include "games-scores.h"
#include "games-scores-private.h"

struct GamesScoresPrivate {
  GHashTable *categories;
  GSList *catsordered;
  gchar *currentcat;
  gchar *defcat;
  gchar *basename;
  gboolean last_score_significant;
  gint last_score_position;
  GamesScore *last_score;
  GamesScoreStyle style;
  GamesScoresCategory dummycat;
  GList *scores_list;
  time_t timestamp;
  gchar *filename;
  gint fd;
};

static void
games_scores_category_free (GamesScoresCategory *cat)
{
  g_free (cat->key);
  g_free (cat->name);
  g_free (cat);
}

/**
 * games_scores_get_current:
 * @self: A scores object.
 *
 * Retrieves the current category and make sure it is in a state to be used.
 *
 **/
static GamesScoresCategory *
games_scores_get_current (GamesScores * self)
{
  GamesScoresPrivate *priv = self->priv;
  GamesScoresCategory *cat;

  if (priv->currentcat == NULL) {
    /* We have a single, anonymous, category. */
    cat = &(priv->dummycat);
  } else {
    cat = g_hash_table_lookup (priv->categories, priv->currentcat);
    if (!cat)
      return NULL;
  }

  if (self->priv->filename == NULL)
  {
	char * pkguserdatadir;  
	  
	pkguserdatadir = g_build_filename (g_get_user_data_dir (), priv->basename, NULL);
	self->priv->filename = g_build_filename (pkguserdatadir, cat->key, NULL);
	
	if (access (pkguserdatadir, O_RDWR) == -1) {
    /* Don't return NULL because games-scores.c does not
     * expect it, and can't do anything about it anyway. */
	  mkdir (pkguserdatadir, 0775);
	}
  }

  return cat;
}

G_DEFINE_TYPE (GamesScores, games_scores, G_TYPE_OBJECT);

/**
 * games_scores_new:
 * @app_name: the (old) app name (for backward compatibility),
 *   used as the basename of the category filenames
 * @categories: (allow-none): the score categories, or %NULL to use an anonymous category
 * @n_categories: (allow-none): the number of category entries in @categories
 * @categories_context: (allow-none): the translation context to use for the category names,
 *   or %NULL to use no translation context
 * @categories_domain: (allow-none): the translation domain to use for the category names,
 *   or %NULL to use the default domain
 * @default_category_index: (allow-none): the key of the default category, or %NULL
 * @style: the category style
 *
 *
 * Returns: a new #GamesScores object
 */
GamesScores *
games_scores_new (const char *app_name,
                  const GamesScoresCategory *categories,
                  int n_categories,
                  const char *categories_context,
                  const char *categories_domain,
                  int default_category_index,
                  GamesScoreStyle style)
{
  GamesScores *self;

  self = GAMES_SCORES (g_object_new (GAMES_TYPE_SCORES, NULL));

  /* FIXME: Input sanity checks. */

  /* catsordered is a record of the ordering of the categories.
   * Its data is shared with the hash table. */
  self->priv->catsordered = NULL;

  if (n_categories > 0) {
    int i;

    g_return_val_if_fail (default_category_index >= 0 && default_category_index < n_categories, NULL);

    for (i = 0; i < n_categories; ++i) {
      const GamesScoresCategory *category = &categories[i];
      const char *display_name;

      if (categories_context) {
        display_name = g_dpgettext2 (categories_domain, categories_context, category->name);
      } else {
        display_name = dgettext (categories_domain, category->name);
      }

      _games_scores_add_category (self, category->key, display_name);
    }

    self->priv->defcat = g_strdup (categories[default_category_index].key);
    self->priv->currentcat = g_strdup (self->priv->defcat);
  }

  self->priv->basename = g_strdup (app_name);
  /* FIXME: Do some sanity checks on the default and the like. */

  self->priv->style = style;

  /* Set up the anonymous category for use when no categories are specified. */
  self->priv->dummycat.key = (char *) "";
  self->priv->dummycat.name = (char *) "";
  
  self->priv->timestamp = 0;
  
  self->priv->scores_list = NULL;
  
  self->priv->filename = NULL;
  
  self->priv->fd = -1;
  
  return self;
}

/**
 * _games_scores_add_category:
 * @self:
 * @key: the key for the new category
 * @name: the user visible label for the new category
 *
 * Add a new category after initialisation. key and name are copied into
 * internal structures. The scores dialog is not currently updated.
 *
 **/
void
_games_scores_add_category (GamesScores *self,
                           const char *key,
                           const char *name)
{
  GamesScoresPrivate *priv = self->priv;
  GamesScoresCategory *cat;

  cat = g_new (GamesScoresCategory, 1);
  cat->key = g_strdup (key);
  cat->name = g_strdup (name);

  g_hash_table_insert (priv->categories, g_strdup (key), cat);
  priv->catsordered = g_slist_append (priv->catsordered, cat);
}

/**
 * games_scores_set_category:
 * @self: A scores object.
 * @category: A string identifying the category to use (the key in
 *            the GamesScoresCategory structure).
 *
 * This function sets the scores category to use. e.g. whether we are playing
 * on hard, medium or easy. It should be used at the time that the game
 * itself switches between difficulty levels. The category determines where
 * scores are to be stored and read from.
 *
 **/
void
games_scores_set_category (GamesScores * self, const gchar * category)
{
  GamesScoresPrivate *priv = self->priv;

  g_return_if_fail (self != NULL);

  if (category == NULL)
    category = priv->defcat;

  g_free (priv->currentcat);
  priv->currentcat = g_strdup (category);

  /* FIXME: Check validity of category (Null, the same as current,
   * is actually a category) then just set it in the structure. */
}

/**
 * games_scores_add_score:
 * @self: A scores object.
 * @score: A #GamesScore - it is up to the caller to convert their
 *         raw value to one of the supported types.
 *
 * Add a score to the set of scores. Retention of anything but the
 * top-ten scores is undefined. It returns either the place in the top ten
 * or zero if no place was achieved. It can therefore be treated as a
 * boolean if desired.
 *
 **/
gint
games_scores_add_score (GamesScores * self, GamesScore *score)
{
  GamesScoresPrivate *priv = self->priv;
  GamesScoresCategory *cat;
  gint place, n;
  GList *s, *scores_list;

  g_return_val_if_fail (self != NULL, 0);

  cat = games_scores_get_current (self);

  scores_list = _games_scores_get_scores (self);

  s = scores_list;
  place = 0;
  n = 0;

  while (s != NULL) {
    GamesScore *oldscore = s->data;

    n++;

    /* If beat someone in the list, add us there. */
    if (games_score_compare (priv->style, oldscore, score) < 0) {
      scores_list = g_list_insert_before (scores_list, s,
					  g_object_ref (score));
      place = n;
      break;
    }

    s = g_list_next (s);
  }

  /* If we haven't placed anywhere and the list still has
   * room to grow, put us on the end.
   * This also handles the empty-file case. */
  if ((place == 0) && (n < GAMES_SCORES_SIGNIFICANT)) {
    place = n + 1;
    scores_list = g_list_append (scores_list, g_object_ref (score));
  }

  if (g_list_length (scores_list) > GAMES_SCORES_SIGNIFICANT) {
    s = g_list_nth (scores_list, GAMES_SCORES_SIGNIFICANT - 1);
    g_return_val_if_fail (s != NULL, 0);
    /* Note that we are guaranteed to only need to remove one link
     * and it is also guaranteed not to be the first one. */
    g_object_unref (g_list_next (s)->data);
    g_list_free (g_list_next (s));
    s->next = NULL;
  }

  if (_games_scores_set_scores (self, scores_list) == FALSE)
    place = 0;

  priv->last_score_significant = place > 0;
  priv->last_score_position = place;
  g_object_unref (priv->last_score);
  priv->last_score = g_object_ref (score);

  return place;
}

gint
games_scores_add_plain_score (GamesScores * self, guint32 value)
{
  return games_scores_add_score (self, games_score_new_plain (value));
}

gint
games_scores_add_time_score (GamesScores * self, gdouble value)
{
  return games_scores_add_score (self, games_score_new_time (value));
}

/**
 * _games_scores_update_score_name:
 * @self: A scores object.
 * @new_name: The new name to use.
 * @old_name: (allow-none):
 *
 * By default add_score uses the current user name. This routine updates
 * that name. There are a few wrinkles: the score may have moved since we
 * got the original score. Use in normal code is discouraged, it is here
 * to be used by GamesScoresDialog.
 *
 **/
void
_games_scores_update_score_name (GamesScores * self, gchar * new_name, gchar * old_name)
{
  GamesScoresPrivate *priv = self->priv;
  GamesScoresCategory *cat;
  GList *s, *scores_list;
  gint n, place;
  GamesScore *sc;

  g_return_if_fail (self != NULL);

  place = priv->last_score_position;

  if (place == 0)
    return;

  if (old_name)
      old_name = g_strdup (old_name); /* Make copy so we can free it later */
  else
      old_name = g_strdup (g_get_real_name ());

  cat = games_scores_get_current (self);

  scores_list = _games_scores_get_scores (self);

  s = g_list_last (scores_list);
  n = g_list_length (scores_list);

  /* We hunt backwards down the list until we find the last entry with
   * a matching user and score. */
  /* The check that we haven't gone back before place isn't just a
   * pointless optimisation. It also catches the case where our score
   * has been dropped from the high-score list in the meantime. */

  while ((n >= place) && (s != NULL)) {
    sc = (GamesScore *) (s->data);
    if ((games_score_compare (priv->style, sc, priv->last_score) ==
	 0) && (g_utf8_collate (old_name, games_score_get_name (sc)) == 0)) {
      games_score_set_name (sc, new_name);
    }

    s = g_list_previous (s);
    n--;
  }

  _games_scores_set_scores (self, scores_list);

  g_free (old_name);
}

/**
 * _games_scores_update_score:
 * @self: A scores object.
 * @new_name: The new name to use.
 *
 * By default add_score uses the current user name. This routine updates
 * that name. There are a few wrinkles: the score may have moved since we
 * got the original score. Use in normal code is discouraged, it is here
 * to be used by GamesScoresDialog.
 *
 **/
void
_games_scores_update_score (GamesScores * self, gchar * new_name)
{
    _games_scores_update_score_name (self, new_name, NULL);
}

/**
 * _games_scores_get:
 * @self: A scores object.
 *
 * Get a list of GamesScore objects for the current category. The list
 * is still owned by the GamesScores object and is not guaranteed to
 * be the either the same or accurate after any games_scores call
 * except _games_scores_get. Do not alter the data either.
 *
 * Returns: (element-type GnomeGamesSupport.Score) (transfer none): A list of GamesScore objects.
 **/
GList *
_games_scores_get (GamesScores * self)
{
  GamesScoresCategory *cat;
  GList *scores;

  g_return_val_if_fail (self != NULL, NULL);

  cat = games_scores_get_current (self);

  scores = _games_scores_get_scores (self);
  /* Tell GamesScores object that we won't be altering the scores so it
   * can release the lock. */
  _games_scores_discard_scores (self);

  return scores;
}

/**
 * _games_scores_category_foreach:
 * @self: A scores object.
 * @func: A function to call.
 * @userdata: Arbitrary data.
 *
 * This function will iterate over the list of categories calling the
 * supplied function with the category and userdata as arguments.
 * The ordering of the categories is the order they were added.
 *
 **/
void
_games_scores_category_foreach (GamesScores * self,
                                GamesScoresCategoryForeachFunc func,
                                gpointer userdata)
{
  GamesScoresPrivate *priv = self->priv;
  GSList *l;

  g_return_if_fail (self != NULL);

  for (l = priv->catsordered; l != NULL; l = l->next) {
    func ((GamesScoresCategory*) l->data, userdata);
  }
}

/**
 * _games_scores_get_style:
 * @self: A scores object.
 *
 * Returns the style of the scores.
 *
 **/
GamesScoreStyle
_games_scores_get_style (GamesScores * self)
{
  GamesScoresPrivate *priv = self->priv;

  g_return_val_if_fail (self != NULL, 0);

  return priv->style;
}

/**
 * _games_scores_get_category:
 * @self: A scores object.
 *
 * Returns the current category key. It is owned by the GamesScores object and
 * should not be altered. This will be NULL if no category is current (this
 * will typically happen if no categories have been added to the GamesScore).
 *
 **/
const gchar *
_games_scores_get_category (GamesScores * self)
{
  GamesScoresPrivate *priv = self->priv;

  g_return_val_if_fail (self != NULL, NULL);

  return priv->currentcat;
}

static void
games_scores_init (GamesScores * self)
{
  GamesScoresPrivate *priv;

  /* Most of the work is done in the _new method. */

  priv = self->priv = G_TYPE_INSTANCE_GET_PRIVATE (self, GAMES_TYPE_SCORES, GamesScoresPrivate);

  priv->last_score_significant = FALSE;
  priv->last_score_position = 0;
  priv->last_score = games_score_new ();
  priv->categories = g_hash_table_new_full (g_str_hash, g_str_equal,
                                            g_free,
                                            (GDestroyNotify) games_scores_category_free);
}

static void
games_scores_finalize (GObject * object)
{
  GamesScores *scores = GAMES_SCORES (object);

  g_hash_table_unref (scores->priv->categories);
  g_slist_free (scores->priv->catsordered);
  g_free (scores->priv->currentcat);
  g_free (scores->priv->defcat);
  g_free (scores->priv->basename);
  g_object_unref (scores->priv->last_score);

  G_OBJECT_CLASS (games_scores_parent_class)->finalize (object);
}

static void
games_scores_class_init (GamesScoresClass * klass)
{
  GObjectClass *object_class = (GObjectClass *) klass;
  object_class->finalize = games_scores_finalize;
  g_type_class_add_private (klass, sizeof (GamesScoresPrivate));
}

/* Get a lock on the scores file. Block until it is available.
 * This also supplies the file descriptor we need. The return value
 * is whether we were succesful or not. */
static gboolean
games_scores_get_lock (GamesScores * self)
{
  gint error;
  struct flock lock;

  if (self->priv->fd != -1) {
    /* Assume we already have the lock and rewind the file to
     * the beginning. */
    lseek (self->priv->fd, 0, SEEK_SET);
    return TRUE;                /* Assume we already have the lock. */
  }

  self->priv->fd = open (self->priv->filename, O_RDWR | O_CREAT, 0755);
  if (self->priv->fd == -1) {
    return FALSE;
  }

  lock.l_type = F_WRLCK;
  lock.l_whence = SEEK_SET;
  lock.l_start = 0;
  lock.l_len = 0;

  error = fcntl (self->priv->fd, F_SETLKW, &lock);

  if (error == -1) {
    close (self->priv->fd);
    self->priv->fd = -1;
    return FALSE;
  }

  return TRUE;
}

/* Release the lock on the scores file and dispose of the fd. */
/* We ignore errors, there is nothing we can do about them. */
static void
games_scores_release_lock (GamesScores * self)
{
  struct flock lock;

  /* We don't have a lock, ignore this call. */
  if (self->priv->fd == -1)
    return;

  lock.l_type = F_UNLCK;
  lock.l_whence = SEEK_SET;
  lock.l_start = 0;
  lock.l_len = 0;

  fcntl (self->priv->fd, F_SETLKW, &lock);

  close (self->priv->fd);

  self->priv->fd = -1;
}

/**
 * _games_scores_get_scores:
 * @self: the function to get the scores from
 *
 * You can alter the list returned by this function, but you must
 * make sure you set it again with the _set_scores method or discard it
 * with with the _discard_scores method. Otherwise deadlocks will ensue.
 *
 * Return value: (transfer none) (allow-none) (element-type GnomeGamesSupport.Score): The list of scores
 */
GList *
_games_scores_get_scores (GamesScores * self)
{
  gchar *buffer;
  gchar *eol;
  gchar *scorestr;
  gchar *timestr;
  gchar *namestr;
  GamesScore *newscore;
  struct stat info;
  int error;
  ssize_t length, target;
  GList *t;

  /* Check for a change in the scores file and update if necessary. */
  error = stat (self->priv->filename, &info);

  /* If an error occurs then we give up on the file and return NULL. */
  if (error != 0) {
    return NULL;
  }

  if ((info.st_mtime > self->priv->timestamp) || (self->priv->scores_list == NULL)) {
    self->priv->timestamp = info.st_mtime;

    /* Dump the old list of scores. */
    t = self->priv->scores_list;
    while (t != NULL) {
      g_object_unref (t->data);
      t = g_list_next (t);
    }
    g_list_free (self->priv->scores_list);
    self->priv->scores_list = NULL;

    /* Lock the file and get the list. */
    if (!games_scores_get_lock (self))
      return NULL;

    buffer = g_malloc (info.st_size + 1);
    if (buffer == NULL) {
      games_scores_release_lock (self);
      return NULL;
    }

    target = info.st_size;
    length = 0;
    do {
      target -= length;
      length = read (self->priv->fd, buffer, info.st_size);
      if (length == -1) {
        games_scores_release_lock (self);
        g_free (buffer);
        return NULL;
      }
    } while (length < target);

    buffer[info.st_size] = '\0';

    /* FIXME: These details should be in a sub-class. */

    /* Parse the list. We start by breaking it into lines. */
    /* Since the buffer is null-terminated
     * we can do the string stuff reasonably safely. */
    eol = strchr (buffer, '\n');
    scorestr = buffer;
    while (eol != NULL) {
      *eol++ = '\0';
      timestr = strchr (scorestr, ' ');
      if (timestr == NULL)
        break;
      *timestr++ = '\0';
      namestr = strchr (timestr, ' ');
      /* The player's name might not be stored in the scores file, if the file
       * was saved by certain 3.12 games. This is fine, indicated by NULL. */
      if (namestr != NULL)
        *namestr++ = '\0';
      /* At this point we have three strings, both null terminated. All
       * part of the original buffer. */
      switch (self->priv->style) {
      case GAMES_SCORES_STYLE_PLAIN_DESCENDING:
      case GAMES_SCORES_STYLE_PLAIN_ASCENDING:
        newscore = games_score_new_plain (g_ascii_strtod (scorestr, NULL));
        break;
      case GAMES_SCORES_STYLE_TIME_DESCENDING:
      case GAMES_SCORES_STYLE_TIME_ASCENDING:
        newscore = games_score_new_time (g_ascii_strtod (scorestr, NULL));
        break;
      default:
        g_assert_not_reached ();
      }
      games_score_set_name (newscore, namestr);
      games_score_set_time (newscore, g_ascii_strtoull (timestr, NULL, 10));
      self->priv->scores_list = g_list_append (self->priv->scores_list, newscore);
      /* Setup again for the next time around. */
      scorestr = eol;
      eol = strchr (eol, '\n');
    }

    g_free (buffer);
  }

  /* FIXME: Sort the scores! We shouldn't rely on the file being sorted. */

  return self->priv->scores_list;
}

gboolean
_games_scores_set_scores (GamesScores * self, GList * list)
{
  GList *s;
  GamesScore *d;
  gchar *buffer;
  gint output_length = 0;
  gchar dtostrbuf[G_ASCII_DTOSTR_BUF_SIZE];

  if (!games_scores_get_lock (self))
    return FALSE;

  self->priv->scores_list = list;

  s = list;
  while (s != NULL) {
    gdouble rscore;
    guint64 rtime;
    const gchar *rname;

    d = (GamesScore *) s->data;
    switch (self->priv->style) {
    case GAMES_SCORES_STYLE_PLAIN_DESCENDING:
    case GAMES_SCORES_STYLE_PLAIN_ASCENDING:
      rscore = games_score_get_value_as_plain (d);
      break;
    case GAMES_SCORES_STYLE_TIME_DESCENDING:
    case GAMES_SCORES_STYLE_TIME_ASCENDING:
      rscore = games_score_get_value_as_time(d);
      break;
    default:
      g_assert_not_reached ();
    }
    rtime = games_score_get_time (d);
    rname = games_score_get_name (d);

    buffer = g_strdup_printf ("%s %"G_GUINT64_FORMAT" %s\n",
                              g_ascii_dtostr (dtostrbuf, sizeof (dtostrbuf),
                                              rscore), rtime, rname);
    write (self->priv->fd, buffer, strlen (buffer));
    output_length += strlen (buffer);
    /* Ignore any errors and blunder on. */
    g_free (buffer);

    s = g_list_next (s);
  }

  /* Remove any content in the file that hasn't yet been overwritten. */
  ftruncate (self->priv->fd, output_length--);

  /* Update the timestamp so we don't reread the scores unnecessarily. */
  self->priv->timestamp = time (NULL);

  games_scores_release_lock (self);

  return TRUE;
}

void
_games_scores_discard_scores (GamesScores * self)
{
  games_scores_release_lock (self);
}
