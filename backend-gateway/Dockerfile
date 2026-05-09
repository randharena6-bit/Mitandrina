# 🌪️ MITANDRINA Gateway - Dockerfile
FROM node:18-alpine

WORKDIR /app

# Dépendances
COPY package*.json ./
RUN npm ci --only=production

# Application
COPY . .

# Logs directory
RUN mkdir -p logs

EXPOSE 3001

USER node

CMD ["node", "src/index.js"]
