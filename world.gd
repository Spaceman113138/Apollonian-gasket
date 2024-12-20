extends Node2D


var colorArray = [Color(0,1,0,1), Color(0,0,1,1), Color(1,0,0,1), Color(1,1,0,1), Color(0,1,1,1), Color(1,0,1,1), Color(0.5,0,0,1), Color(0,0.5,0,1), Color(0,0,0.5,1), Color(0.5,0.5,0), Color(0,0.5,0.5), Color(0.5,0,0.5,1), Color(0.75, 0.75, 0, 1), Color(0, 0.75, 0.75, 1), Color(0.75, 0, 0.75, 1), Color(0.75, 0.25, 0, 1), Color(0.75, 0, 0.25,1), Color(0.25, 0.75, 0, 1), Color(0, 0.75, 0.25, 1), Color(0.25, 0 , 0.75, 1), Color(0, 0.25, 0.75, 1), Color(0,0,0,1)]

@export var useColor: bool = false:
	set(val):
		useColor = val
		queue_redraw()

@export var maxCurve: float = 100

var numItterations: int = 0

var defaultCircle = [[Vector2(1.0/2.0, 0), 2.0, 1], [Vector2(-1.0/2.0, 0), 2.0, 1]]
var defaultCalculate = [[[Vector2(0,0), -1.0], defaultCircle[0], defaultCircle[1]]]

var circlesToDraw: Array = defaultCircle
var circlesToCalculate: Array = defaultCalculate

var globalMin: float = 0.0
var itterIndex: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	doTheItterating(0)


func reset():
	itterIndex = 0
	circlesToDraw = defaultCircle
	circlesToCalculate = defaultCalculate
	globalMin = 0.0
	doTheItterating(numItterations)
	queue_redraw()
	print("calc Done")


func doTheItterating(num):
	itterIndex = 0
	var x: int = 1
	while x <= num:
		#print(x)
		itterate()
		x += 1


func itterate():
	itterIndex += 1
	#print(globalMin)
	var newCirclesToCalc: Array = []
	var max = str(circlesToCalculate.size())
	var x = 0
	var localMin: float = 1000.0
	while circlesToCalculate.size() > 0:
		#print(str(x) + "/" + max)
		var array = calcCircle(circlesToCalculate.pop_front(), itterIndex)
		#print(array[0])
		localMin = min(localMin, array[0])
		var nextCircles = array[1]
		newCirclesToCalc.append_array(nextCircles)
		x += 1
	circlesToCalculate = newCirclesToCalc.duplicate(true)
	globalMin = localMin


func _draw() -> void:
	var innerCircle = [Vector2(0,0), -1.0]
	var x: int = 1
	var max: int = circlesToDraw.size()
	draw_circle(innerCircle[0], abs(1.0/innerCircle[1]), Color.WHITE, false, -1, false)
	for circle in circlesToDraw:
		var color = Color.WHITE
		if circle[2] < colorArray.size() and useColor:
			color = colorArray[circle[2]]
		draw_circle(Vector2(circle[0].x, -circle[0].y), abs(1.0/circle[1]), color, useColor, -1, false)
		x += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#(a+bi)(c+di)
# a*c - b*d
# a*d + c*b
func multiply(val1: Vector2, val2: Vector2):
	var real = val1.x * val2.x - val1.y * val2.y
	var imag = val1.x * val2.y + val2.x * val1.y
	return Vector2(real, imag)


func complexPower(value: Vector2, _power: float) -> Vector2:
	var r: float = value.length()
	var angle: float = atan2(value.y, value.x)
	var real: float = pow(r, _power) * cos(angle * _power)
	var imag: float = pow(r, _power) * sin(angle * _power)
	return Vector2(real, imag)


func descartes(c1: float, c2: float, c3: float) -> Array[float]:
	var a: float = c1 + c2 + c3
	var descriminant: float = 2 * sqrt(c1*c2 + c1*c3 + c2*c3)
	return [a + descriminant, a - descriminant]


func calcCircle(circles: Array, index: int) -> Array:
	var min: float = 1000.0
	var nextCircles: Array = []
	var newCircles: Array = descartesCenter(circles[0], circles[1], circles[2])
	for circle in newCircles:
		if circle[1] > globalMin and circle[1] < maxCurve and isValid(circles, circle):
			#print(circle[1])
			min = min(min, circle[1])
			circle.append(index)
			
			nextCircles.append([circles[0], circles[1], circle])
			nextCircles.append([circles[0], circles[2], circle])
			nextCircles.append([circles[1], circles[2], circle])
			circlesToDraw.append(circle)
	return [min, nextCircles]


func descartesCenter(c1: Array, c2: Array, c3: Array) -> Array:
	var curve4: Array = descartes(c1[1], c2[1], c3[1])
	var a: Vector2 = c1[0]*c1[1] + c2[0]*c2[1] + c3[0]*c3[1]
	var desciminant: Vector2 = multiply(c1[0]*c1[1], c2[0]*c2[1]) + multiply(c1[0]*c1[1],c3[0]*c3[1]) + multiply(c3[0]*c3[1], c2[0]*c2[1])
	desciminant = 2 * complexPower(desciminant, 0.5)
	var option1: Array = [(a + desciminant) / curve4[0], curve4[0]]
	var option2: Array = [(a + desciminant) / curve4[1], curve4[1]]
	var option3: Array = [(a - desciminant) / curve4[0], curve4[0]]
	var option4: Array = [(a - desciminant) / curve4[1], curve4[1]]
	return arrayUnique([option1, option2, option3, option4])


func isValid(circles: Array, tangent: Array):
	for circle in circles:
		var dist: float = circle[0].distance_to(tangent[0])
		var sumDistance: float = abs(1.0/circle[1]) + abs(1.0/tangent[1])
		var difDistance: float = abs(abs(1.0/circle[1]) - abs(1.0/tangent[1]))
		if !(is_equal_approx(dist, sumDistance) or is_equal_approx(dist, difDistance)):
			return false
	return true


func arrayUnique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique
