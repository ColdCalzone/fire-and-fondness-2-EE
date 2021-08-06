extends Node

var players_moved : int = 0

signal player_moved

func move(event : InputEvent) -> void:
	for player in get_tree().get_nodes_in_group("player"):
		if event.is_action_pressed("move_up"):
			if player.can_move:
				if player.can_move_to(player.board_position + (Vector2.UP if not player.is_fake_partner() else Vector2.DOWN)):
					player.try_to_move(Vector2.UP)
					players_moved += 1
				
		elif event.is_action_pressed("move_down") and player.can_move:
			if player.can_move:
				if player.can_move_to(player.board_position + (Vector2.DOWN if not player.is_fake_partner() else Vector2.UP)):
					player.try_to_move(Vector2.DOWN)
					players_moved += 1
					
			
		elif event.is_action_pressed("move_left") and player.can_move:
			if player.can_move:
				if player.can_move_to(player.board_position + (Vector2.LEFT if not player.is_fake_partner() else Vector2.RIGHT)):
					player.flip(true)
					player.try_to_move(Vector2.LEFT)
					players_moved += 1
						
				
		elif event.is_action_pressed("move_right") and player.can_move:
			if player.can_move:
				if player.can_move_to(player.board_position + (Vector2.RIGHT if not player.is_fake_partner() else Vector2.LEFT)):
					player.flip(false)
					player.try_to_move(Vector2.RIGHT)
					players_moved += 1
				
		elif event.is_action_pressed("interact") and player.can_move:
			if player.can_interact()[0]:
				player.try_to_interact()
				players_moved += 1
	if players_moved > 0:
		for player in get_tree().get_nodes_in_group("player"):
			player.can_move = false
		players_moved = 0
		emit_signal("player_moved")
