extends RigidBody2D
# Цей код описує поведінку персонажа під контролем гравця
# А також противників під контролем комп'ютера

export var human = false 	# Чи управляється персонаж людиною
var go = false				#  
var go_up = false			# Чи потрібно зробити рух вгору
var jump_timer				# Посилання на вузол таймера, що визначає затримку між стрибками
var sit_timer				# Посилання на вузол таймера, що визначає час після посадки на землю, після якого відтвориться анімація сідання
const UP_FORCE = -2500		# Сила стрибка
var up_force = [-10, -2500, -4000, -6000] # Значення сили стрибка у відповідності до кількості кульок
const RIGHT_FORCE = 4000 	# Сила руху по горизонталі
var on_floor = false 		# Чи стоїть персонаж на землі 
var r_button = false		# Чи в цім кадрі було отримано сигнал рухатись праворуч
var l_button = false		# Чи в цім кадрі було отримано сигнал рухатись ліворуч
var sit = false
export var balloons = 1			# Кількість накачаних кульок над головою у персонажа
var balloons_left = 2		# Кількість кульок, що залишились, котрі можна накачати при потребі
var score = 0				# Рахунок
var main_node				# Посилання на головний вузол сцени
var velocity = Vector2(0,0)	# Вектор швидкості руху
var shocked = false			# Ци вражено гравця електрошоком
var eaten = false			# Чи гравця з'їдено
var target
var go_up_changed = false
var direction_pressed = false
var random_point = Vector2(0,0)

func _ready():
	randomize()
	random_point = get_rand_point()
	get_node("ray").add_exception(self)
	main_node = get_node("/root/main")
	jump_timer = get_node("jump_timer")
	sit_timer = get_node("sit_timer")
	if !human:
		add_to_group("e")
		get_node("random_points").set_autostart(true)
		get_node("random_points").start()
		
		target = get_target()
		get_node("jump_timer").set_wait_time(0.5)
	set_process_input(true)
	set_fixed_process(true)
#

func get_rand_point():
	var screen = get_tree().get_root().get_rect().size
	return  Vector2(randf() * screen.x, randf() * screen.y)

func get_target():
	for p in main_node.get_node("players").get_children():
		if p.is_in_group("player"):
			return p
	return 0
	

# Визначення, чи гру програно
func game_over():
	print("game over")

# Обробка враження електрошоком
func shock():
	shocked = true
	set_balloons(0)
	get_node("anim").play("shock")
	set_gravity_scale(2.5)
	jump_timer.stop()

# Встановлення кількості кульок накачаних над головою персонажа
func set_balloons(b):
	if balloons > b:
		balloons = b
		get_node("anim").play("fly_x" + str(balloons))
		get_node("sound").play("hurt")
		
	elif balloons < b and on_floor and b - balloons == 1 and balloons_left > 0:
		balloons = b
		balloons_left -= 1
		get_node("anim").play("fly_x" + str(balloons))
		get_node("sound").play("jump-c-01")
		get_node("b_label").set_text(str(balloons_left))
	if balloons == 0:
		set_gravity_scale(2.5)
	else:
		set_gravity_scale(1)

# Отримання рахунку
func get_score():
	return(score)

# Встановлення рахунку
func set_score(s):
	score = s

# Додавання кульки до резерву
func add_balloon(num):
	balloons_left += num
	get_node("b_label").set_text(str(balloons_left))
	get_node("sound").play("chew")

# Поїдання їжі, що трапляється на рівні
func eat(energy):
	set_score(get_score() + energy)
	get_node("sound").play("chew")
	get_node("anim").play("eat")

func go_left(pressed):
	l_button = pressed

func go_right(pressed):
	r_button = pressed

# Обробка сигналу стрибка
func jump(pressed):
	if pressed:
		go_up = true
		jump_timer.start()
	else:
		go_up = false
		jump_timer.stop()
		
# Обробка натискання клавіш
func _input(event):
	if !human:
		return
	if (event.is_action_pressed("ui_up") or event.is_action_pressed("space")) and balloons > 0:
		jump(true)
	if event.is_action_released("ui_up") or event.is_action_released("space"):
		jump(false)

	if event.is_action_pressed("1"):
		set_balloons(1)
	elif event.is_action_pressed("2"):
		set_balloons(2)
	elif event.is_action_pressed("3"):
		set_balloons(3)
	elif event.is_action_pressed("0"):
		set_balloons(0)


func _fixed_process(delta):
	velocity = get_linear_velocity()
	if human:
		if !shocked and (Input.is_action_pressed("ui_right") or r_button):
			if main_node.cam_speed:
				velocity.x = RIGHT_FORCE * (main_node.cam_speed / 29) * delta
			else:
				velocity.x = RIGHT_FORCE * delta
			direction_pressed = true
				
			sit = false
		if !shocked and (Input.is_action_pressed("ui_left") or l_button):
			if main_node.cam_speed:
				velocity.x = -RIGHT_FORCE * (main_node.cam_speed / 29) * delta
			else:
				velocity.x = -RIGHT_FORCE * delta
			sit = false
			direction_pressed = true

	var target_vector = Vector2(0,0)

	if !human:
		if balloons > 0:
			target_vector = target.get_pos() - get_pos()
			if target_vector.length() > 150:
				
				target_vector = random_point - get_pos()
				if target_vector.length() < 15:
					random_point = get_rand_point()
			var barrier = false
			get_node("ray").set_cast_to(target_vector)
			if get_node("ray").is_colliding():
				var cast = get_node("ray").get_collider()
				if cast:
					if cast.is_in_group("island"):
						barrier = true
						print("_____  ", cast.get_name())
			if !barrier:
				velocity.x = (target_vector.normalized() * RIGHT_FORCE).x * delta
			else:
				var cast_dist = (get_pos() - get_node("ray").get_collision_point()).length()
				if cast_dist < 30:
					velocity.x = -(target_vector.normalized() * RIGHT_FORCE).x * delta
			if target_vector.y < 5 and !barrier:
				if !go_up_changed:
					go_up_changed = true
					jump(true)
			else:
				jump(false)
				go_up_changed = false
				
# Якщо отримано сигнал руху вгору
	if go_up:
		get_node("anim").play("fly_x" + str(balloons))
		get_node("sound").play("jump-c-01")
		sit = false
		velocity.y = (up_force[balloons]) * delta 
		go_up = false

# Костильний метод вирішення проблеми обертання персонажа
	set_rot(0)
	var linear_velocity = velocity
	if main_node.cam_speed:
		linear_velocity = Vector2(velocity.x * (1 - (main_node.cam_speed * 0.001)), velocity.y)
	set_linear_velocity(Vector2(linear_velocity))
	if get_linear_velocity().length() < 0.5 and on_floor and !sit:
		sit = true
		sit_timer.start()

	if direction_pressed or !human:
		direction_pressed = false
		if get_linear_velocity().x >= 0:
			get_node("sprite_container").set_scale(Vector2(1,1))
		else:
			get_node("sprite_container").set_scale(Vector2(-1,1))
		
# Якщо час таймера стрибка сплив
func _on_jump_timer_timeout():
	if !shocked:
		go_up_changed = false
		go_up = true # Виконати ще один стрибок

# Якщо приземлився на землю
func _on_Area2D_body_enter( body ):
	on_floor = true
	get_node("sprite_container/sprite").set_frame(1)

# Якщо зістрибнув із землі
func _on_Area2D_body_exit( body ):
	on_floor = false
	get_node("sprite_container/sprite").set_frame(0)


func _on_sit_timer_timeout():
	if get_linear_velocity().length() < 0.5 and on_floor:
		get_node("sprite_container/sprite").set_frame(2)
		get_node("sound").play("sit01")


func _on_eater_body_enter( body ):
	if human:
		if body.is_in_group("food"):
			body.queue_free()
			eat(body.energy)

		elif body.is_in_group("balloon"):
			add_balloon(1)
			body.queue_free()

func _on_balloons_body_enter( body ):
#	print(body.get_name())
	pass

func _on_balloons_area_enter( area ):
	if area.get_node("..").is_in_group("island"):
		var vector = get_linear_velocity()
		vector.y = 0
		set_linear_velocity(vector)
		if area.is_in_group("needles") and human:
			if balloons > 0:
				set_balloons(balloons - 1)
	elif area.is_in_group("eater"):
		if !human and area.get_node("../..").is_in_group("e"):
			return
		if balloons > 0:
			set_balloons(balloons - 1)


func _on_random_points_timeout():
	random_point = get_rand_point()
