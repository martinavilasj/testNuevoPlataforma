# Bot que sigue al player 
extends CharacterBody2D

const move_speed = 30
const max_speed = 90

const speed_up = 50

const gravity = 15
const jump_velocity = -200

@onready var player_sprite = $player_sprite
@onready var animation = $AnimationPlayer

# Definicion de sensores de piso
@onready var right_sensor = $right_sensor
@onready var left_sensor = $left_sensor

# Definicion de sensores horizontales, vista hacia adelante y atras
@onready var right_h_sensor = $right_h_sensor
@onready var left_h_sensor = $left_h_sensor

# Definicion de sensor de arriba del personaje
@onready var up_sensor = $up_sensor

# Variable para saber si el pj esta subiendo una escalera
var going_up: bool = false

func _process(delta: float) -> void:
	if not going_up:
		velocity.y += gravity
	
	var friction = false
	
	if get_player_side() == "left":
		player_sprite.flip_h = true
	elif get_player_side() == "right":
		player_sprite.flip_h = false
		
	if colision_ia_floor() && not colision_ia_horizontal() && not get_center_collider("player"):
		animation.play("run")
		move_ia()
	
	elif not colision_ia_horizontal() && not colision_ia_floor() && is_on_floor():		
		velocity.y = jump_velocity
		move_ia()
		
	else:
		friction = true
		animation.play("idle")
	
	if is_on_floor():			
		if friction:
			velocity.x = lerp(velocity.x, 0.0, 0.5)
	else:
		animation.play("jump")
		if friction:
			velocity.x = lerp(velocity.x, 0.0, 0.01)
	
	if get_center_collider("ladder"):
		going_up = true
		if get_up_collider("player") or get_up_collider("stop"):
			velocity.y = lerp(velocity.y, 0.0, 0.5)
		else:
			velocity.y = max(velocity.y - speed_up, -max_speed)
			
	else:
		going_up = false
	
	move_and_slide()

func colision_ia_horizontal() -> bool:
	if player_sprite.flip_h:
		if left_h_sensor.is_colliding():
			return true
		else:
			return false
	else:
		if right_h_sensor.is_colliding():
			return true
		else:
			return false

func colision_ia_floor() -> bool:
	if player_sprite.flip_h:
		if left_sensor.is_colliding():
			return true
		else:
			return false
	else:
		if right_sensor.is_colliding():
			return true
		else:
			return false
	
func get_center_collider(group) -> bool:
	if right_h_sensor.is_colliding():
		var collider = right_h_sensor.get_collider()
		if collider.is_in_group(group):
			return true
	if left_h_sensor.is_colliding():
		var collider = left_h_sensor.get_collider()
		if collider.is_in_group(group):
			return true
	return false

func get_up_collider(group: String) -> bool:
	if up_sensor.is_colliding():
		var collider = up_sensor.get_collider()
		if collider.is_in_group(group):
			return true
	return false

func move_ia() -> void:
	if !player_sprite.flip_h:
		velocity.x = min(velocity.x + move_speed, max_speed)
	else:
		velocity.x = max(velocity.x - move_speed, -max_speed)

func get_player_side() -> String:
	var player = get_tree().get_first_node_in_group("player")
	if position.x < player.position.x:
		return "right"
	else:
		return "left"
