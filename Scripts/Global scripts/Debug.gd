# This script is only meant for debugging during development and maintenance
# not apart of the final product

extends PanelContainer

@onready var propertyContainer = %VBoxContainer
#var property
var fps : String

func _ready():
	# Set global variable reference
	Global.debug = self
	
	# Set invisible when start
	visible = false
	
	

func _process(delta):
	AddProperty("FPS", fps, 0)
	if visible:
		fps = "%.2f" % (1.0/delta) # Gets frames per second
	

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible

# Debug Function
# Adds new property and updates current properties.
func AddProperty(title : String, value, order):
	var target
	target = propertyContainer.find_child(title, true, false) # find if node already exist with same name.
	if !target: # if no node already exist add it
		target = Label.new() # Creates new  label node
		propertyContainer.add_child(target) # add new node to Vbox container as a child
		target.name = title # set the label title
		target.text = target.name + ": " + str(value) # set the text
	elif visible:
		target.text = title + ": " + str(value) # update the text value
		propertyContainer.move_child(target,order) # Reorder property based on given order value


#func AddDebugProperty(title : String, value):
	#property = Label.new()
	#property_container.add_child(property)
	#property.name = title
	#property.text = property.name + value
