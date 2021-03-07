extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var combos: Dictionary = {}
var brainChainLinkScore = 2000
var quickChainLinkScore = 1500
var activeChainLinkScore = 1000
var twoTrickScore = 200
var hatTrickScore = 600
var simulchaineousScore = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func update_scorecard():
	if $CompleteScorecardTimer.is_stopped():
		# Only update if we are not showing a recently completed combo.
		var comboToDisplay = null
		for comboKey in combos.keys():
			var thisCombo = score_chain(combos.get(comboKey))
			# Put scored combo back.
			combos[comboKey] = thisCombo
			if thisCombo.scoreTotal > comboToDisplay.scoreTotal:
				comboToDisplay = thisCombo
		if comboToDisplay != null:
			if (comboToDisplay.get("brainChain")):
				$Scorecard/ComboCounter/GalaxyBrainChain.text = "Brain Chain! x" + String(comboToDisplay.get("brainChain"))
				$Scorecard/ComboCounter/GalaxyBrainChain.visible = true
				if comboToDisplay.get("brainChain") > 5:
					$Scorecard/ComboCounter/GalaxyBrainChain.text = "GALAXY " + $Scorecard/ComboCounter/GalaxyBrainChain.text
				$Scorecard/ComboScore/BrainChainScore.text = String(comboToDisplay.brainChainScore)
				$Scorecard/ComboScore/BrainChainScore.visible = true
			else:
				$Scorecard/ComboCounter/GalaxyBrainChain.visible = false
				$Scorecard/ComboScore/.visible = false
			if (comboToDisplay.get("quickChain") != null):
				$Scorecard/ComboCounter/QuickChain.text = "Quick Chain! x" + String(comboToDisplay.get("quickChain"))
				$Scorecard/ComboCounter/QuickChain.visible = true
				$Scorecard/ComboScore/QuickChainScore.text = String(comboToDisplay.quickChainScore)
				$Scorecard/ComboScore/QuickChainScore.visible = true
			else:
				$Scorecard/ComboCounter/QuickChain.visible = false
				$Scorecard/ComboScore/QuickChainScore.visible = false
			if (comboToDisplay.get("activeChain") != null):
				$Scorecard/ComboCounter/ActiveChain.text = "Active Chain x" + String(comboToDisplay.get("activeChain"))
				$Scorecard/ComboCounter/ActiveChain.visible = true
				$Scorecard/ComboScore/ActiveChainScore.text = String(comboToDisplay.activeChainScore)
				$Scorecard/ComboScore/ActiveChainScore.visible = true
			else:
				$Scorecard/ComboCounter/ActiveChain.visible = false
				$Scorecard/ComboScore/ActiveChainScore.visible = false
			if (comboToDisplay.get("twoTrick") != null):
				$Scorecard/ComboCounter/TwoTrick.text = "Two Trick x" + String(comboToDisplay.get("twoTrick"))
				$Scorecard/ComboCounter/TwoTrick.visible = true
				$Scorecard/ComboScore/TwoTrickScore.text = String(comboToDisplay.twoTrickScore)
				$Scorecard/ComboScore/TwoTrickScore.visible = true
			else:
				$Scorecard/ComboCounter/TwoTrick.visible = false
				$Scorecard/ComboScore/TwoTrickScore.visible = false
			if (comboToDisplay.get("hatTrick") != null):
				$Scorecard/ComboCounter/HatTrick.text = "Hat Trick! x" + String(comboToDisplay.get("hatTrick"))
				$Scorecard/ComboCounter/HatTrick.visible = true
				$Scorecard/ComboScore/HatTrickScore.text = String(comboToDisplay.hatTrickScore)
				$Scorecard/ComboScore/HatTrickScore.visible = true
			else:
				$Scorecard/ComboCounter/HatTrick.visible = false
				$Scorecard/ComboScore/HatTrickScore.visible = false
			if (comboToDisplay.get("simulchaineous") != null):
				$Scorecard/ComboCounter/SimulChaineous.text = "Simulchaineous x" + String(comboToDisplay.get("simulchaineous"))
				$Scorecard/ComboCounter/Simulchaineous.visible = true
				$Scorecard/ComboScore/SimulChaineousScore.text = String(comboToDisplay.simulchaineousScore)
				$Scorecard/ComboScore/SimulChaineousScore.visible = true
			else:
				$Scorecard/ComboCounter/SimulChaineous.visible = false
				$Scorecard/ComboScore/SimulChaineousScore.visible = false
		else:
			for child in $Scorecard/ComboCounter.get_children():
				child.visible = false
			for child in $Scorecard/ComboScore.get_children():
				child.visible = false

func score_chain(combo) -> int:
	combo.brainChainScore = score_brain_chain(combo.brainChainCount)
	combo.quickChainScore = score_quick_chain(combo.quickChainCount)
	combo.activeChainScore = score_active_chain(combo.activeChainCount)
	combo.twoTrickScore = score_two_trick(combo.twoTrickCount)
	combo.hatTrickScore = score_hat_trick(combo.hatTrickCount)
	combo.simulchaineousScore = score_simulchaineous(combo.simulchaineousCount)
	combo.scoreTotal = (combo.brainChainScore + combo.quickChainScore + combo.activeChainScore
	+ combo.twoTrickScore + combo.hatTrickScore + combo.simulchaineousScore)
	return combo

func score_brain_chain(count: int) -> int:
	return count * brainChainLinkScore

func score_quick_chain(count: int) -> int:
	return count * quickChainLinkScore

func score_active_chain(count: int) -> int:
	return count * activeChainLinkScore

func score_two_trick(count: int) -> int:
	return count * twoTrickScore

func score_hat_trick(count: int) -> int:
	return count * hatTrickScore

func score_simulchaineous(count: int) -> int:
	return count * simulchaineousScore

func end_combo():
	if $CompleteScorecardTimer.is_stopped():
		$CompleteScorecardTimer.start()
		$Scorecard.set_modulate(Color(0.483521, 0.690471, 0.910156))
	elif $CompleteScorecardTimer.time_left < $CompleteScorecardTimer.wait_time / 2:
		#TODO Show our new scorecard, and scale time_left cutoff based on the two scores.
		# Restart timer.
		$CompleteScorecardTimer.start()

func _on_CompleteScorecardTimer_timeout():
	$Scorecard.set_modulate(Color(1, 1, 1))
