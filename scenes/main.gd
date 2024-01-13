extends Node

@export var snake_scene: PackedScene

#global stuff
var score: int
var game_started: bool = false
var food_pos: Vector2
var regen_food: bool = true

#grid stuff
var cells: int = 20
var cell_size: int = 50

#snake stuff
var snake_data: Array
var old_snake: Array
var snake: Array

#movement info
var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var current_direction: Vector2
var can_move: bool

func _ready():
	new_game()

func _process(delta):
	move_snake()
	
func new_game():
	get_tree().call_group("segments", "queue_free")
	get_tree().paused = false
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	current_direction = up
	can_move = true
	generate_snake()
	move_food()
	
func generate_snake():
	old_snake.clear()
	snake_data.clear()
	snake.clear()
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))
	
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size) # space for the panel (1 cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

func move_snake():
	if not can_move:
		return
	if Input.is_action_just_pressed("move_down") and current_direction != up:
		current_direction = down
		can_move = false
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move_up") and current_direction != down:
		current_direction = up
		can_move = false
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move_left") and current_direction != right:
		current_direction = left
		can_move = false
		if not game_started:
			start_game()
	if Input.is_action_just_pressed("move_right") and current_direction != left:
		current_direction = right
		can_move = false
		if not game_started:
			start_game()
			

func start_game():
	game_started = true
	$MoveTimer.start()


func _on_move_timer_timeout():
	can_move = true
	old_snake = [] + snake_data
	snake_data[0] += current_direction
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_snake[i-1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
		
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()

func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()

func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_snake[-1])
		move_food()
	
func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells-1), randi_range(0, cells-1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	regen_food = true


func _on_game_over_menu_restart():
	new_game()
