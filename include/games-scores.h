/* Games Scores Dialog - Display high scores
 *
 * Copyright (c) 2005 by Callum McKenzie
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

#ifndef GAMES_SCORES_H
#define GAMES_SCORES_H

#include <glib.h>
#include <glib-object.h>

G_BEGIN_DECLS

/* How many scores get counted as significant. */
#define GAMES_SCORES_SIGNIFICANT 10

typedef struct {
  gchar *key;			/* A unique identifier (warning: this is used to generate the
                         * scores file name, so it should match the old domains) */
  gchar *name;			/* A human-readable description. */
} GamesScoresCategory;

typedef enum {
  GAMES_SCORES_STYLE_PLAIN_DESCENDING,
  GAMES_SCORES_STYLE_PLAIN_ASCENDING,
  GAMES_SCORES_STYLE_TIME_DESCENDING,
  GAMES_SCORES_STYLE_TIME_ASCENDING,
} GamesScoreStyle;

#define GAMES_TYPE_SCORES (games_scores_get_type())
#define GAMES_SCORES(obj) G_TYPE_CHECK_INSTANCE_CAST((obj), games_scores_get_type(), GamesScores)
#define GAMES_SCORES_CONST(obj)	G_TYPE_CHECK_INSTANCE_CAST((obj), games_scores_get_type(), GamesScores const)
#define GAMES_SCORES_CLASS(klass) G_TYPE_CHECK_CLASS_CAST((klass), games_scores_get_type(), GamesScoresClass)
#define GAMES_IS_SCORES(obj) G_TYPE_CHECK_INSTANCE_TYPE((obj), games_scores_get_type ())
#define GAMES_SCORES_GET_CLASS(obj) G_TYPE_INSTANCE_GET_CLASS((obj), games_scores_get_type(), GamesScoresClass)

typedef struct GamesScoresPrivate GamesScoresPrivate;

typedef struct {
  GObject parent;
  /*< private >*/
  GamesScoresPrivate *priv;
} GamesScores;

typedef struct {
  GObjectClass parent;
} GamesScoresClass;

GType           games_scores_get_type          (void);
GamesScores    *games_scores_new               (const char *app_name,
                                                const GamesScoresCategory *categories,
                                                int n_categories,
                                                const char *categories_context,
                                                const char *categories_domain,
                                                int default_category_index,
                                                GamesScoreStyle style);
void            games_scores_set_category      (GamesScores * self, const gchar * category);
gint            games_scores_add_plain_score   (GamesScores * self, guint32 value);
gint            games_scores_add_time_score    (GamesScores * self, gdouble value);

G_END_DECLS
#endif /* GAMES_SCORES_H */
