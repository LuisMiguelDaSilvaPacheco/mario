extends CharacterBody2D

var SPEED = 250.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_check: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var score = 0
var health = 2
var eye_frame = false

func _physics_process(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("b") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var running = 2
	if Input.is_action_pressed("a"):
		running = 1
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED / running, 16)
		animated_sprite_2d.flip_h = velocity.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 7)
		
	if enemy_check.is_colliding():
		var enemy = enemy_check.get_collider()
		if enemy:
			if enemy.get_class() == "CharacterBody2D":
				velocity.y = -100
				score += 100
				enemy.die()
		
		
	move_and_slide()
	if not is_on_floor():
		velocity += get_gravity() * delta
		if health != 0:
			animated_sprite_2d.animation = "jump"
	else:
		if (velocity.x > 1 || velocity.x < -1):
			if health != 0:
				animated_sprite_2d.animation = "run"
			var true_velocity = abs(velocity.x)
			animated_sprite_2d.speed_scale = 1 + (true_velocity / 300)
		else:
			if health != 0:
				animated_sprite_2d.animation = "idle"

func damage():
	print(health)
	if(eye_frame == false):
		eye_frame = true
		health -= 1
		if(health <= 0):
			die()
			await get_tree().create_timer(3).timeout
			get_tree().change_scene_to_file("res://cenas/fases/world.tscn")
		else:
			await flicker()
			eye_frame = false
	
func die():
	SPEED = 0
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	animated_sprite_2d.animation = "dead"
	await get_tree().create_timer(0.5).timeout
	set_physics_process(true)
	SPEED = 0
	animated_sprite_2d.animation = "dead"
	velocity.y = JUMP_VELOCITY

func flicker():
	for i in 10:
		animated_sprite_2d.visible = false
		await get_tree().create_timer(0.05).timeout
		animated_sprite_2d.visible = true
		await get_tree().create_timer(0.05).timeout

func win():
	set_physics_process(false)
	await get_tree().create_timer(1).timeout
	set_physics_process(true)
	SPEED = 0
	velocity.x = 0
	await get_tree().create_timer(0.5).timeout
	velocity.x = 300
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://cenas/fases/menu.tscn")
