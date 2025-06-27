# Stage 1: Build the React/Vite application
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:alpine
# Copy the custom Nginx configuration for SPA routing
COPY nginx.conf /etc/nginx/nginx.conf
# Copy the built application from the builder stage to Nginx's HTML directory
COPY --from=builder /app/dist /usr/share/nginx/html
# Expose port 80 for web traffic
EXPOSE 80
# Command to start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
