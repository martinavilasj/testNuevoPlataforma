extends CharacterBody2D

const move_speed = 30
const max_speed = 100

const speed_up = 30

const gravity = 15
const jump_velocity = -200

@onready var player_sprite = $player_sprite
@onready var animation = $AnimationPlayer
@onready var up_sensor = $up_sensor

var going_up = false

func _physics_process(delta):
	if not going_up: 
		velocity.y += gravity
	
	var friction = false
	
	if Input.is_action_pressed("ui_right"):
		animation.play("run")
		player_sprite.flip_h = false
		velocity.x = min(velocity.x + move_speed, max_speed)		
	elif Input.is_action_pressed("ui_left"):		
		animation.play("run")
		player_sprite.flip_h = true
		velocity.x = max(velocity.x - move_speed, -max_speed)
	else:
		friction = true
		animation.play("idle")
	
	if Input.is_action_just_pressed("ui_accept") && not going_up:
		animation.play("jump")
		velocity.y = jump_velocity
		
	if get_up_collider("ladder"):
		if Input.is_action_pressed("ui_up"):
			going_up = true
			velocity.y = max(velocity.y - speed_up, -max_speed)
		else:
			velocity.y = lerp(velocity.y, 0.0, 0.5)
	else:
		going_up = false
	
	if is_on_floor():			
		if friction:
			velocity.x = lerp(velocity.x, 0.0, 0.5)
	else:
		if friction:
			velocity.x = lerp(velocity.x, 0.0, 0.01)

	move_and_slide()

func get_up_collider(group: String) -> bool:
	if up_sensor.is_colliding():
		var collider = up_sensor.get_collider()
		if collider.is_in_group(group):
			return true
	return false
