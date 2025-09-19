import requests
import json

# Test direct de l'API Gemini pour comprendre le problème
api_key = ""
url = ""

# Test du prompt pour histoire de départ
prompt_start = """Tu es un conteur d'histoires interactives sur le thème écologique. 
Crée une histoire engageante avec EXACTEMENT ce format (respecte scrupuleusement les | et les séparateurs) : 
Titre: [un titre accrocheur] | Situation: [une description de 100-150 mots de la situation écologique] | 
Choix: [premier choix d'action]|[deuxième choix d'action]|[troisième choix d'action]

IMPORTANT: Tu dois absolument fournir exactement 3 choix séparés par des | sans espaces autour."""

request_data = {
    "contents": [
        {
            "parts": [
                {
                    "text": prompt_start
                }
            ]
        }
    ],
    "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 1024
    }
}

print("Test de l'API Gemini...")
print("Prompt:", prompt_start[:100] + "...")

try:
    response = requests.post(url, json=request_data, headers={"Content-Type": "application/json"})
    
    if response.status_code == 200:
        result = response.json()
        text = result['candidates'][0]['content']['parts'][0]['text']
        print("\nReponse Gemini:")
        print(text)
        print("\nAnalyse:")
        if "|" in text:
            parts = text.split("|")
            print(f"Nombre de parties: {len(parts)}")
            for i, part in enumerate(parts):
                print(f"Partie {i+1}: {part.strip()}")
                if part.strip().startswith("Choix:"):
                    choices_str = part.strip()[6:].strip()
                    choices = choices_str.split("|")
                    print(f"  -> Nombre de choix: {len(choices)}")
                    for j, choice in enumerate(choices):
                        print(f"     Choix {j+1}: {choice.strip()}")
        else:
            print("Format non respecte - pas de separateurs |")
    else:
        print(f"Erreur API: {response.status_code}")
        print(response.text)
        
except Exception as e:
    print(f"Erreur: {e}")
