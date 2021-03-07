extends MarginContainer
class_name ComboDisplay

signal combo_done

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
			if thisCombo.get("scoreTotal") > comboToDisplay.get("scoreTotal"):
				comboToDisplay = thisCombo
		if comboToDisplay != null:
			if (comboToDisplay.get("brainChain")):
				$Scorecard/ComboCounter/GalaxyBrainChain.text = "Brain Chain! x" + String(comboToDisplay.get("brainChainCount"))
				$Scorecard/ComboCounter/GalaxyBrainChain.visible = true
				if comboToDisplay.get("brainChain") > 5:
					$Scorecard/ComboCounter/GalaxyBrainChain.text = "GALAXY " + $Scorecard/ComboCounter/GalaxyBrainChain.text
				$Scorecard/ComboScore/BrainChainScore.text = String(comboToDisplay.brainChainScore)
				$Scorecard/ComboScore/BrainChainScore.visible = true
			else:
				$Scorecard/ComboCounter/GalaxyBrainChain.visible = false
				$Scorecard/ComboScore/.visible = false
			if (comboToDisplay.get("quickChain") != null):
				$Scorecard/ComboCounter/QuickChain.text = "Quick Chain! x" + String(comboToDisplay.get("quickChainCount"))
				$Scorecard/ComboCounter/QuickChain.visible = true
				$Scorecard/ComboScore/QuickChainScore.text = String(comboToDisplay.quickChainScore)
				$Scorecard/ComboScore/QuickChainScore.visible = true
			else:
				$Scorecard/ComboCounter/QuickChain.visible = false
				$Scorecard/ComboScore/QuickChainScore.visible = false
			if (comboToDisplay.get("activeChain") != null):
				$Scorecard/ComboCounter/ActiveChain.text = "Active Chain x" + String(comboToDisplay.get("activeChainCount"))
				$Scorecard/ComboCounter/ActiveChain.visible = true
				$Scorecard/ComboScore/ActiveChainScore.text = String(comboToDisplay.activeChainScore)
				$Scorecard/ComboScore/ActiveChainScore.visible = true
			else:
				$Scorecard/ComboCounter/ActiveChain.visible = false
				$Scorecard/ComboScore/ActiveChainScore.visible = false
			if (comboToDisplay.get("twoTrick") != null):
				$Scorecard/ComboCounter/TwoTrick.text = "Two Trick x" + String(comboToDisplay.get("twoTrickCount"))
				$Scorecard/ComboCounter/TwoTrick.visible = true
				$Scorecard/ComboScore/TwoTrickScore.text = String(comboToDisplay.twoTrickScore)
				$Scorecard/ComboScore/TwoTrickScore.visible = true
			else:
				$Scorecard/ComboCounter/TwoTrick.visible = false
				$Scorecard/ComboScore/TwoTrickScore.visible = false
			if (comboToDisplay.get("hatTrick") != null):
				$Scorecard/ComboCounter/HatTrick.text = "Hat Trick! x" + String(comboToDisplay.get("hatTrickCount"))
				$Scorecard/ComboCounter/HatTrick.visible = true
				$Scorecard/ComboScore/HatTrickScore.text = String(comboToDisplay.hatTrickScore)
				$Scorecard/ComboScore/HatTrickScore.visible = true
			else:
				$Scorecard/ComboCounter/HatTrick.visible = false
				$Scorecard/ComboScore/HatTrickScore.visible = false
			if (comboToDisplay.get("simulchaineous") != null):
				$Scorecard/ComboCounter/SimulChaineous.text = "Simulchaineous x" + String(comboToDisplay.get("simulchaineousCount"))
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
	combo["brainChainScore"] = score_brain_chain(combo.get("brainChainCount"))
	combo["quickChainScore"] = score_quick_chain(combo.get("quickChainCount"))
	combo["activeChainScore"] = score_active_chain(combo.get("activeChainCount"))
	combo["twoTrickScore"] = score_two_trick(combo.get("twoTrickCount"))
	combo["hatTrickScore"] = score_hat_trick(combo.get("hatTrickCount"))
	combo["simulchaineousScore"] = score_simulchaineous(combo.get("simulchaineousCount"))
	combo["scoreTotal"] = (combo.get("brainChainScore") + combo.get("quickChainScore") + combo.get("activeChainScore")
	+ combo.get("twoTrickScore") + combo.get("hatTrickScore") + combo.get("simulchaineousScore"))
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

func upsert_combo(comboKey, comboValue):
	#XXX Can calculate score delta instead of recalculating whole score, depending on how formula shakes out
	for combo in combos:
		if !combo.has("simulchaineousCount"):
			combo["simulchaineousCount"] = 1
		else:
			combo["simulchaineousCount"] = combo.get("simulchaineousCount") + 1
	combos[comboKey] = comboValue
	update_scorecard()

func end_combo(comboKey) -> int:
	if combos.has(comboKey):
		combos[comboKey]["finished"] = true
	if $CompleteScorecardTimer.is_stopped():
		#TODO we only want to freeze the scorecard if this combo is the biggest (aka it's being shown currently).
		$CompleteScorecardTimer.start()
		$Scorecard.set_modulate(Color(0.483521, 0.690471, 0.910156))
	elif $CompleteScorecardTimer.time_left < $CompleteScorecardTimer.wait_time / 2:
		#TODO we only want to overwrite the scorecard if this combo is bigger than all unfinished combos.
		#TODO Show our new scorecard, and scale time_left cutoff based on the two scores.
		# Restart timer.
		$CompleteScorecardTimer.start()
	# TODO return combo score
	emit_signal("combo_done", combos.get(comboKey).get("scoreTotal"))
	return 0

func _on_CompleteScorecardTimer_timeout():
	$Scorecard.set_modulate(Color(1, 1, 1))
	var comboKeys = combos.keys()
	for comboKey in comboKeys:
		if combos.get(comboKey).has("finished"):
			# XXX this is the only place we erase combos, so technically the list could grow unbounded
			# XXX if new ones keep ending and restarting the timer. deal with this case somehow
			combos.erase(comboKey)
	update_scorecard()
