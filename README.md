# POVA

Pova gives mod makers a set of easy to use functions that safely apply overrides for player speed, jump height and gravity effects.

## Settings

'pova_loop' setting is true by default and will calculate and set overrides once a second for each player.

## Functions

pova.set_override_defaults = function(name, def)

- Sets default speed, jump and gravity for a player that additional overrides are then added onto.

pova.add_override = function(name, item, def)

- Adds a named override which can be used to add or subtract from speed, jump and gravity effects.

pova.get_override = function(name, item)

- Returns the table containing {speed, jump, gravity} for an added item.

pova.del_override = function(name, item)

- Removes the override settings for the item named.

pova.do_override(player)

- Calculates and sets new overrides instantly, this can be used when the 'pova_loop' setting is false.


## Changelog

### 0.1

 - Initial Upload

### 0.2

 - Added pova.do_override(player) to instantly set overrides on list.
 - Added 'pova_loop' setting in minetest.conf to disable override calc loop
