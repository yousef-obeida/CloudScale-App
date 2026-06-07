# Use the official lightweight Nginx image
FROM nginx:alpine

# Copy the custom HTML file to the default Nginx public folder
COPY index.html /usr/share/nginx/html/

# Expose port 80 as required by the project
EXPOSE 80