# POVA

Pova gives mod makers a set of functions that safely apply overrides for player speed, jump height and gravity effects.

## Settings

'pova_loop' setting is true by default and will calculate and set overrides once a second for each player.

## Functions

pova.set_override_defaults = function(name, def)

- Sets default speed, jump and gravity for a player that overrides are added onto.

pova.add_override = function(name, item, def)

- Adds a named override which can add or remove from speed, jump and gravity.

pova.get_override = function(name, item)

- Returns the table containing {speed, jump, gravity} for the added item.

pova.del_override = function(name, item)

- Removes the settings for the named item.

pova.do_override(player)

- Calculates and sets new overrides instantly, this can be used when the 'pova_loop' setting is false.


## Changelog

### 0.1

 - Initial Upload

### 0.2

 - Added pova.do_override(player) to instantly set overrides on list.
 - Added 'pova_loop' setting in minetest.conf to disable override calc loop
