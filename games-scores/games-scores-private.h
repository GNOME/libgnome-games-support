/* Games Scores private header file
 *
 * Copyright (c) 2005 by Callum McKenzie
 * Copyright (c) 2014 by Nikhar Agrawal
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

#ifndef GAMES_SCORES_PRIVATE_H
#define GAMES_SCORES_PRIVATE_H

#include <glib.h>
#include <glib-object.h>

#include "games-scores.h"

#define GAMES_TYPE_SCORES_BACKEND (games_scores_backend_get_type ())
#define GAMES_SCORES_BACKEND(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), GAMES_TYPE_SCORES_BACKEND, GamesScoresBackend))
#define GAMES_SCORES_BACKEND_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), GAMES_TYPE_SCORES_BACKEND, GamesScoresBackendClass))
#define GAMES_IS_SCORES_BACKEND(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), GAMES_TYPE_SCORES_BACKEND))
#define GAMES_IS_SCORES_BACKEND_CLASS(kls) (G_TYPE_CHECK_CLASS_TYPE ((kls), GAMES_TYPE_SCORES_BACKEND))
#define GAMES_GET_SCORES_BACKEND_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), GAMES_TYPE_SCORES_BACKEND, GamesScoresBackendClass))

typedef struct GamesScoresBackendPrivate GamesScoresBackendPrivate;

typedef struct {
  GObject object;
  /*< private >*/
  GamesScoresBackendPrivate *priv;
} GamesScoresBackend;

typedef struct {
  GObjectClass parent_class;
} GamesScoresBackendClass;


typedef void (*GamesScoresCategoryForeachFunc) (GamesScoresCategory * cat, 
		                                gpointer data);

void            _games_scores_update_score      (GamesScores * self, gchar * new_name);
void            _games_scores_update_score_name (GamesScores * self, gchar * new_name, gchar * old_name);
GList *         _games_scores_get               (GamesScores * self);
void            _games_scores_category_foreach (GamesScores * self,
                                                GamesScoresCategoryForeachFunc func,
                                                gpointer userdata);
GamesScoreStyle _games_scores_get_style         (GamesScores * self);
const gchar    *_games_scores_get_category      (GamesScores * self);
void            _games_scores_add_category      (GamesScores *self,
                                                const char *key,
                                                const char *name);
GType               _games_scores_backend_get_type       (void);
GamesScoresBackend *_games_scores_backend_new            (GamesScoreStyle style,
                                                         char *base_name,
                                                         char *name);
GList              *_games_scores_backend_get_scores     (GamesScoresBackend * self);
gboolean            _games_scores_backend_set_scores     (GamesScoresBackend * self,
                                                         GList * list);
void                _games_scores_backend_discard_scores (GamesScoresBackend * self);

G_END_DECLS

#endif /* GAMES_SCORES_PRIVATE_H */
