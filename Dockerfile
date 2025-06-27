# Use Node.js image for building the frontend
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app and build it
COPY . .
RUN npm run build

# Use nginx to serve the static files
FROM nginx:alpine

# Copy the build output to Nginx HTML directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy a custom nginx config if needed
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
