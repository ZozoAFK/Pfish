extends Node

# Dictionnaires pour stocker les dégâts par niveau
var degats_par_niveau : Dictionary = {
	"Niveau_1": 0,
	"Niveau_2": 0
}

# Variable pour savoir quel niveau est actuellement joué
var niveau_actuel : String = "Niveau_1"

func enregistrer_degat() -> void:
	if degats_par_niveau.has(niveau_actuel):
		degats_par_niveau[niveau_actuel] += 1
		print("Dégât enregistré pour ", niveau_actuel, ". Total : ", degats_par_niveau[niveau_actuel])

# Fonction pour calculer quelle étoile attribuer selon les dégâts
func obtenir_etoile_pour_niveau(nom_niveau: String) -> String:
	var nb_degats = degats_par_niveau.get(nom_niveau, 0)
	
	if nb_degats <= 2:
		return "Or"
	elif nb_degats >2 and nb_degats <= 5: # 2 ticks + 3 ticks supplémentaires = 5 max pour l'argent
		return "Argent"
	else:
		return "Bronze"
		
# --- NOUVELLE FONCTION : RÉINITIALISATION SUR DÉFAITE ---
func reinitialiser_niveau_actuel() -> void:
	if degats_par_niveau.has(niveau_actuel):
		degats_par_niveau[niveau_actuel] = 0
		print("Défaite ! Le score du ", niveau_actuel, " a été réinitialisé à 0.")
