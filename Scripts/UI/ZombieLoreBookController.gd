extends AnimatedTextureRect

#Button References
@onready var baseZombieButton = $"../../AllZombieRows/Row1/BaseZombie"
@onready var coneHeadZombieButton = $"../../AllZombieRows/Row1/ConeHeadZombie"
@onready var bucketHeadZombieButton = $"../../AllZombieRows/Row1/BucketHeadZombie"
@onready var dancerZombieButton = $"../../AllZombieRows/Row2/DancerZombie" 
@onready var backUpDanceerZombieButton = $"../../AllZombieRows/Row2/BackUpDancerZombie"
@onready var tickerZombieButton = $"../../AllZombieRows/Row2/TickerZombie"
@onready var screenDoorZombieButton = $"../../AllZombieRows/Row3/ScreenDoorZombie"
@onready var footBallZombieButton = $"../../AllZombieRows/Row3/FootballZombie"
@onready var poleVaultZombieButton = $"../../AllZombieRows/Row3/PoleVaultZombie"

@onready var currentZombieLabel = $"../../../CurrentZombieLabel"

var baseZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/BaseZombieDescription.txt"
var coneheadZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/ConeHeadZombieDescription.txt"
var bucketHeadZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/bucketHeadZombieDescription.txt"
var dancerZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/dancerZombieDescription.txt"
var backUpDancerZombieDescription := "res://Assets/Text/TextFiles/ZombieDescriptions/backUpDancerDescription.txt"
