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
GList          *_games_scores_get_scores     (GamesScores * self);
gboolean        _games_scores_set_scores     (GamesScores * self,
                                                         GList * list);
void            _games_scores_discard_scores (GamesScores * self);

G_END_DECLS

#endif /* GAMES_SCORES_PRIVATE_H */
