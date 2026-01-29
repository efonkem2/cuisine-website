# Use nginx as base image for serving static web content
FROM nginx:alpine

# Copy website files to nginx html directory
COPY src/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx (nginx:alpine already has a working default configuration)
CMD ["nginx", "-g", "daemon off;"]