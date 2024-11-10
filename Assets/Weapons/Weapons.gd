class_name Weapon

extends Resource

@export var weaponName : String
@export var weaponMuzzlePosition : Vector3
@export_category("Animations")
@export var animationFire : String
@export var animationPullout : String
@export var animationPutaway : String
@export var animationMelee : String

@export_category("Weapon Properties")
#@export var currentAmmo : int
@export var fireRate : float # rounds per minute, based of off real life values gotten off of google.
@export var autoFire : bool
@export var semiAuto : bool
@export var push : bool
@export var primaryWeapon : bool
@export var secondaryWeapon : bool
@export var meleeWeapon : bool
@export var shotCount : int
@export var damage : int
@export var range : int

@export_category("Raycast recoil")
@export var recoilAmount : Vector3
@export var snapAmount : float
@export var speed : float

@export_category("Weapon position physics")
@export var recoilAmountPhysics : Vector3
@export var snapAmountPhysics  : float
@export var speedPhysics  : float
