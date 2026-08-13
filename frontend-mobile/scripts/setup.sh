#!/usr/bin/env bash
# 🌪️ MITANDRINA - Script d'installation et démarrage

set -e

echo "🌪️ MITANDRINA - Configuration Mobile"
echo "======================================"

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi

NODE_VERSION=$(node -v)
echo "✓ Node.js $NODE_VERSION"

# Vérifier npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé"
    exit 1
fi

NPM_VERSION=$(npm -v)
echo "✓ npm $NPM_VERSION"

# Installer les dépendances
echo ""
echo "📦 Installation des dépendances..."
npm install

# Vérifier Expo CLI
if ! command -v expo &> /dev/null; then
    echo "⚠️  Expo CLI n'est pas installé globalement"
    echo "   Installation locale via npx: npx expo"
else
    EXPO_VERSION=$(expo -v)
    echo "✓ Expo CLI $EXPO_VERSION"
fi

# Créer .env s'il n'existe pas
if [ ! -f .env ]; then
    echo ""
    echo "📝 Création du fichier .env..."
    cp .env.example .env
    echo "✓ Fichier .env créé. Configurez-le selon vos besoins."
fi

echo ""
echo "✅ Installation complète!"
echo ""
echo "Commandes disponibles:"
echo "  npm start          - Démarrer le serveur Expo"
echo "  npm run android    - Ouvrir sur Android"
echo "  npm run ios        - Ouvrir sur iOS"
echo "  npm run web        - Ouvrir sur le web"
echo ""
echo "Pour démarrer: npm start"
