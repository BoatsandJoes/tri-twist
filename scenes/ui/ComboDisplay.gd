extends MarginContainer
class_name ComboDisplay

signal combo_done

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var combos: Dictionary = {}
var brainChainLinkScore = 900
var luckyChainLinkScore = 1
var quickChainLinkScore = 150
var activeChainLinkScore = 100
var sequentialChainLinkScore = 100
var chainLengthBonusScore = 500
var twoTrickScore = 300
var hatTrickScore = 900
var simulchaineousScore = 0
var displayedComboKey
var activeChainOn: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func update_scorecard():
	$CompleteScorecardTimer.stop()
	$Scorecard.set_modulate(Color(1,1,1))
	var comboToDisplay = null
	var nonDisplayedScoreTotal: int = 0
	for comboKey in combos.keys():
		var thisCombo: Dictionary = score_chain(combos.get(comboKey))
		# Put scored combo back.
		combos[comboKey] = thisCombo
		if comboKey == displayedComboKey:
			comboToDisplay = thisCombo
		else:
			# Update nondisplayed tally
			nonDisplayedScoreTotal = nonDisplayedScoreTotal + thisCombo.get("scoreTotal")
	if comboToDisplay != null:
		if (comboToDisplay.has("brainChainCount")):
			var text: String
			if comboToDisplay.get("brainChainCount") < 5:
				text = "Brain Chain! x"
			else:
				text = "GALAXY Chain! x"
			$Scorecard/ComboCounter/GalaxyBrainChain.text = text + String(comboToDisplay.get("brainChainCount"))
			$Scorecard/ComboCounter/GalaxyBrainChain.visible = true
			$Scorecard/ComboScore/BrainChainScore.text = String(comboToDisplay.get("brainChainScore"))
			$Scorecard/ComboScore/BrainChainScore.visible = true
		else:
			$Scorecard/ComboCounter/GalaxyBrainChain.visible = false
			$Scorecard/ComboScore/BrainChainScore.visible = false
		if (comboToDisplay.has("quickChainCount")):
			$Scorecard/ComboCounter/QuickChain.text = "Quick Chain! x" + String(comboToDisplay.get("quickChainCount"))
			$Scorecard/ComboCounter/QuickChain.visible = true
			$Scorecard/ComboScore/QuickChainScore.text = String(comboToDisplay.get("quickChainScore"))
			$Scorecard/ComboScore/QuickChainScore.visible = true
		else:
			$Scorecard/ComboCounter/QuickChain.visible = false
			$Scorecard/ComboScore/QuickChainScore.visible = false
		if (comboToDisplay.has("activeChainCount")):
			$Scorecard/ComboCounter/ActiveChain.text = "Active Chain x" + String(comboToDisplay.get("activeChainCount"))
			$Scorecard/ComboCounter/ActiveChain.visible = true
			$Scorecard/ComboScore/ActiveChainScore.text = String(comboToDisplay.get("activeChainScore"))
			$Scorecard/ComboScore/ActiveChainScore.visible = true
		else:
			$Scorecard/ComboCounter/ActiveChain.visible = false
			$Scorecard/ComboScore/ActiveChainScore.visible = false
		if (comboToDisplay.has("sequentialChainCount")):
			$Scorecard/ComboCounter/SequentialChain.text = ("Sequential Chain x"
			+ String(comboToDisplay.get("sequentialChainCount")))
			$Scorecard/ComboCounter/SequentialChain.visible = true
			$Scorecard/ComboScore/SequentialChainScore.text = String(comboToDisplay.get("sequentialChainScore"))
			$Scorecard/ComboScore/SequentialChainScore.visible = true
		else:
			$Scorecard/ComboCounter/SequentialChain.visible = false
			$Scorecard/ComboScore/SequentialChainScore.visible = false
		if (comboToDisplay.has("luckyChainCount")):
			$Scorecard/ComboCounter/LuckyChain.text = "Lucky Chain x" + String(comboToDisplay.get("luckyChainCount"))
			$Scorecard/ComboCounter/LuckyChain.visible = true
			$Scorecard/ComboScore/LuckyChainScore.text = String(comboToDisplay.get("luckyChainScore"))
			$Scorecard/ComboScore/LuckyChainScore.visible = true
		else:
			$Scorecard/ComboCounter/LuckyChain.visible = false
			$Scorecard/ComboScore/LuckyChainScore.visible = false
		if (comboToDisplay.has("chainLengthBonus") && comboToDisplay.get("chainLengthBonus") > 0):
			$Scorecard/ComboCounter/ChainLength.text = "Chain Length x" + String(comboToDisplay.get("chainLengthBonus"))
			$Scorecard/ComboCounter/ChainLength.visible = true
			$Scorecard/ComboScore/ChainLengthScore.text = String(comboToDisplay.get("chainLengthScore"))
			$Scorecard/ComboScore/ChainLengthScore.visible = true
		else:
			$Scorecard/ComboCounter/ChainLength.visible = false
			$Scorecard/ComboScore/ChainLengthScore.visible = false
		if (comboToDisplay.has("twoTrickCount")):
			$Scorecard/ComboCounter/TwoTrick.text = "Double Trouble x" + String(comboToDisplay.get("twoTrickCount"))
			$Scorecard/ComboCounter/TwoTrick.visible = true
			$Scorecard/ComboScore/TwoTrickScore.text = String(comboToDisplay.get("twoTrickScore"))
			$Scorecard/ComboScore/TwoTrickScore.visible = true
		else:
			$Scorecard/ComboCounter/TwoTrick.visible = false
			$Scorecard/ComboScore/TwoTrickScore.visible = false
		if (comboToDisplay.has("hatTrickCount")):
			$Scorecard/ComboCounter/HatTrick.text = "Hat Trick! x" + String(comboToDisplay.get("hatTrickCount"))
			$Scorecard/ComboCounter/HatTrick.visible = true
			$Scorecard/ComboScore/HatTrickScore.text = String(comboToDisplay.get("hatTrickScore"))
			$Scorecard/ComboScore/HatTrickScore.visible = true
		else:
			$Scorecard/ComboCounter/HatTrick.visible = false
			$Scorecard/ComboScore/HatTrickScore.visible = false
		if (comboToDisplay.has("simulchaineousCount")):
			$Scorecard/ComboCounter/SimulChaineous.text = "Simulchaineous x" + String(comboToDisplay.get("simulchaineousCount"))
			#$Scorecard/ComboCounter/SimulChaineous.visible = true
			$Scorecard/ComboScore/SimulChaineousScore.text = String(comboToDisplay.get("simulchaineousScore"))
			#$Scorecard/ComboScore/SimulChaineousScore.visible = true
		else:
			$Scorecard/ComboCounter/SimulChaineous.visible = false
			$Scorecard/ComboScore/SimulChaineousScore.visible = false
		$Scorecard/ComboCounter/Total.text = "Total"
		$Scorecard/ComboScore/TotalScore.text = String(comboToDisplay.get("scoreTotal"))
		$Scorecard/ComboCounter/Total.visible = true
		$Scorecard/ComboScore/TotalScore.visible = true
		if nonDisplayedScoreTotal > 0:
			$Scorecard/ComboCounter/OtherCombos.text = "\nOther Chains"
			$Scorecard/ComboCounter/OtherCombos.visible = true
			$Scorecard/ComboScore/OtherCombosScore.text = "\n" + String(nonDisplayedScoreTotal)
			$Scorecard/ComboScore/OtherCombosScore.visible = true
		else:
			$Scorecard/ComboCounter/OtherCombos.text = ""
			$Scorecard/ComboCounter/OtherCombos.visible = false
			$Scorecard/ComboScore/OtherCombosScore.text = String(0)
			$Scorecard/ComboScore/OtherCombosScore.visible = false
	else:
		for child in $Scorecard/ComboCounter.get_children():
			child.visible = false
		for child in $Scorecard/ComboScore.get_children():
			child.visible = false
		displayedComboKey = null

func score_chain(combo) -> Dictionary:
	var chainCount = 0
	var runningTotal = 0
	if combo.has("brainChainCount"):
		var brainCount = combo.get("brainChainCount")
		var brainScore = score_brain_chain(brainCount)
		runningTotal = runningTotal + brainScore
		combo["brainChainScore"] = brainScore
		chainCount = chainCount + brainCount
	if combo.has("quickChainCount"):
		var quickCount = combo.get("quickChainCount")
		var quickScore = score_quick_chain(quickCount)
		runningTotal = runningTotal + quickScore
		combo["quickChainScore"] = quickScore
		chainCount = chainCount + quickCount
	if combo.has("luckyChainCount"):
		# Not counted in chain length bonus
		var luckyCount = combo.get("luckyChainCount")
		var luckyScore = score_lucky_chain(luckyCount)
		runningTotal = runningTotal + luckyScore
		combo["luckyChainScore"] = luckyScore
	if combo.has("activeChainCount"):
		var activeCount = combo.get("activeChainCount")
		var activeScore = score_active_chain(activeCount)
		runningTotal = runningTotal + activeScore
		combo["activeChainScore"] = activeScore
		chainCount = chainCount + activeCount
	if combo.has("sequentialChainCount"):
		var sequentialCount = combo.get("sequentialChainCount")
		var sequentialScore = score_sequential_chain(sequentialCount)
		runningTotal = runningTotal + sequentialScore
		combo["sequentialChainScore"] = sequentialScore
		chainCount = chainCount + sequentialCount
	combo["chainLengthBonus"] = chainCount
	var chainLengthScore = score_chain_length(chainCount)
	combo["chainLengthScore"] = chainLengthScore
	runningTotal = runningTotal + chainLengthScore
	if combo.has("twoTrickCount"):
		var twoTrickScore = score_two_trick(combo.get("twoTrickCount"))
		runningTotal = runningTotal + twoTrickScore
		combo["twoTrickScore"] = twoTrickScore
	if combo.has("hatTrickCount"):
		var hatTrickScore = score_hat_trick(combo.get("hatTrickCount"))
		runningTotal = runningTotal + hatTrickScore
		combo["hatTrickScore"] = hatTrickScore
	if combo.has("simulchaineousCount"):
		var simulchaineousScore = score_simulchaineous(combo.get("simulchaineousCount"))
		runningTotal = runningTotal + simulchaineousScore
		combo["simulchaineousScore"] = simulchaineousScore
	combo["scoreTotal"] = (runningTotal)
	return combo

func score_brain_chain(count: int) -> int:
	return count * brainChainLinkScore

func score_quick_chain(count: int) -> int:
	return count * quickChainLinkScore

func score_lucky_chain(count: int) -> int:
	return count * luckyChainLinkScore

func score_active_chain(count: int) -> int:
	return count * activeChainLinkScore

func score_sequential_chain(count: int) -> int:
	return count * sequentialChainLinkScore

func score_chain_length(count: int) -> int:
	var result = 0
	for i in range(count):
		result = result + min(i, 9) * chainLengthBonusScore
	return result

func score_two_trick(count: int) -> int:
	return count * twoTrickScore

func score_hat_trick(count: int) -> int:
	return count * hatTrickScore

func score_simulchaineous(count: int) -> int:
	return count * simulchaineousScore

func delete_combo(comboKey):
	combos.erase(comboKey)

func upsert_combo(comboKey, comboValue, isLucky: bool):
	#XXX Can calculate score delta instead of recalculating whole score, depending on how formula shakes out
	if !isLucky:
		# Calculate simulchainenous
		var incrementSimulchaineous: int = combos.size()
		if combos.has(comboKey):
			incrementSimulchaineous = combos.size() - 1
		if comboValue.has("simulchaineousCount"):
			comboValue["simulchaineousCount"] = comboValue.get("simulchaineousCount") + incrementSimulchaineous
		elif incrementSimulchaineous > 0:
			comboValue["simulchaineousCount"] = incrementSimulchaineous
	# Upsert and display combo
	combos[comboKey] = comboValue
	displayedComboKey = comboKey
	update_scorecard()

func move_combos_up():
	var newCombos: Dictionary = {}
	for key in combos.keys():
		newCombos[[key[0] + 2, key[1]]] = combos.get(key)
	combos = newCombos
	if displayedComboKey != null:
		displayedComboKey[0] = displayedComboKey[0] + 2

func end_combo_if_exists(comboKey):
	if combos.has(comboKey):
		if displayedComboKey == comboKey:
			# Turn the displayed combo blue.
			$CompleteScorecardTimer.start()
			$Scorecard.set_modulate(Color(0.483521, 0.690471, 0.910156))
		# emit combo score.
		emit_signal("combo_done", combos.get(comboKey).get("scoreTotal"), comboKey)
		combos.erase(comboKey)
		#TODO sound sfx "pieces clearing"

func _on_CompleteScorecardTimer_timeout():
	displayedComboKey = null
	update_scorecard()
