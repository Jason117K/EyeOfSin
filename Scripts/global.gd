extends Node

#Tracks Which Levels Have Been Unlocked

var canPlayLevel2 : bool
var canPlayLevel3 : bool
var canPlayLevel4 : bool 
var canPlayLevel5 : bool 
var canPlayLevel6 : bool 
var canPlayLevel7 : bool

var game_controller : GameController


func setCanPlayLevel2():
	canPlayLevel2 = true  
	
func getCanPlayLevel2():
	return canPlayLevel2    
	
	
func setCanPlayLevel3():
	canPlayLevel3 = true  

func getCanPlayLevel3():
	return canPlayLevel3 
	
	
func setCanPlayLevel4():
	canPlayLevel4 = true 
	
func getCanPlayLevel4():
	return canPlayLevel4
	 

func setCanPlayLevel5():
	canPlayLevel5 = true  
	
func getCanPlayLevel5():
	return canPlayLevel5 
	
	
func setCanPlayLevel6():
	canPlayLevel6 = true  
	
func getCanPlayLevel6():
	return canPlayLevel6 
	
		
func setCanPlayLevel7():
	canPlayLevel7 = true  
	
func getCanPlayLevel7():
	return canPlayLevel7 

func unlockLevel(levelUnlocked):
	match levelUnlocked:
		1:
			pass
		2:
			setCanPlayLevel2()
		3:
			setCanPlayLevel3()
		4:
			setCanPlayLevel4()
		5:
			setCanPlayLevel5()
		6:
			setCanPlayLevel6()
		7:
			setCanPlayLevel7()
	
	
	
	
	
	
	
	
