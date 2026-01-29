# Noela's Cuisine - Dockerized Restaurant Website

This repository contains a containerized version of Noela's Cuisine restaurant website.

## Quick Start

### Build the Docker image:
```bash
docker build -t noelas-cuisine .
```

### Run the container:
```bash
docker run -d -p 8080:80 --name noelas-cuisine-app noelas-cuisine
```

### Access the website:
Open your browser and visit: `http://localhost:8080`

## Container Details

- **Base Image**: `nginx:alpine` - Lightweight nginx server
- **Port**: Exposes port 80 (maps to 8080 on host)
- **Content**: Serves static HTML, CSS, and JavaScript files
- **Configuration**: Custom nginx config for optimal performance

## Development

To stop the container:
```bash
docker stop noelas-cuisine-app
```

To remove the container:
```bash
docker rm noelas-cuisine-app
```

To rebuild after changes:
```bash
docker build -t noelas-cuisine . && docker run -d -p 8080:80 --name noelas-cuisine-app noelas-cuisine
```

## Features

- ✅ Lightweight Alpine Linux base
- ✅ Optimized nginx configuration
- ✅ Static file caching
- ✅ Security headers
- ✅ Multi-page navigation support
- ✅ Mobile responsive design

## Website Structure

- `index.html` - Home page with hero section
- `menu.html` - Interactive menu with cart functionality
- `about.html` - Restaurant information and story
- `styles.css` - Responsive CSS styling
- `script.js` - Interactive JavaScript features