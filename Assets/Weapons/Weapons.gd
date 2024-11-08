class_name Weapon

extends Resource

@export var weaponName : String

@export_category("Animations")
@export var animationFire : String
@export var animationPullout : String
@export var animationPutaway : String

@export_category("Weapon Properties")
#@export var currentAmmo : int
@export var fireRate : float # rounds per minute, based of off real life values gotten off of google.
@export var autoFire : bool
@export var semiAuto : bool
@export var primaryWeapon : bool
@export var secondaryWeapon : bool
@export var meleeWeapon : bool
