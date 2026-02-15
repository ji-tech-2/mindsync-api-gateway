# MindSync API Gateway

Kong API Gateway configuration for routing requests to MindSync microservices (authentication and ML model services).

**🔒 HTTPS-enabled API Gateway running on ports 80/443 with domain `api.mindsync.my`**

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [API Endpoints](#api-endpoints)
- [Configuration](#configuration)
- [Getting Started](#getting-started)
  - [SSL/HTTPS Configuration](#sslhttps-configuration)
  - [Installation Options](#installation-options)
- [Plugins](#plugins)
- [SSL Certificate Setup](SSL_SETUP.md) 📘

## Overview

This API Gateway serves as the single entry point for all MindSync client applications. It routes requests to two main backend services:

- **Authentication Service** (mindsync-backend) - User authentication and profile management
- **ML Model Service** (mindsync-model-flask) - Mental health predictions and analytics

**Domain**: `api.mindsync.my`  
**Protocols**: HTTP (port 80) and HTTPS (port 443)

## Architecture

```
Client Applications
        ↓
   Kong API Gateway (This project)
        ↓
    ┌───┴───┐
    ↓       ↓
Auth API   ML Model API
(Java)     (Flask)
```

### Service Endpoints

- **Authentication Service**: `http://188.166.233.241:80`
- **ML Model Service**: `http://165.22.246.95:80`

## Services

The API Gateway exposes domain-oriented REST API routes organized by semantic resource:

| Domain          | Resource          | Endpoint Pattern                            | Description                                 |
| --------------- | ----------------- | ------------------------------------------- | ------------------------------------------- |
| **Auth**        | user registration | `POST /v1/auth/register`                    | Create new user account                     |
| **Auth**        | user login        | `POST /v1/auth/login`                       | Authenticate and retrieve token             |
| **Users**       | user profile      | `GET/PUT /v1/users/{userId}/profile`        | View/update user profile                    |
| **Users**       | request OTP       | `POST /v1/users/{userId}/request-otp`       | Request one-time password for verification  |
| **Users**       | change password   | `POST /v1/users/{userId}/change-password`   | Update user password                        |
| **Predictions** | create prediction | `POST /v1/predictions/create`               | Submit mental health assessment data        |
| **Predictions** | prediction result | `GET /v1/predictions/{predictionId}/result` | Retrieve prediction results and analysis    |
| **Analytics**   | history           | `GET /v1/users/{userId}/history`            | Get user's prediction history               |
| **Analytics**   | streaks           | `GET /v1/users/{userId}/streaks`            | Get daily/weekly activity streaks           |
| **Analytics**   | weekly chart      | `GET /v1/users/{userId}/weekly-chart`       | Get weekly wellness metrics chart           |
| **Analytics**   | weekly factors    | `GET /v1/users/{userId}/weekly-factors`     | Get critical wellness factors for the week  |
| **Analytics**   | daily suggestions | `GET /v1/users/{userId}/daily-suggestions`  | Get daily personalized wellness suggestions |

## API Endpoints

### Authentication

#### Register User

```
POST /v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}

Response: 200 OK
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### Login

```
POST /v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "user": {
    "userId": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "dob": "1990-01-01",
    "gender": "Male",
    "occupation": "Engineer"
  }
}
```

### User Profile Management

#### Get Profile

```
GET /v1/users/{userId}/profile
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "dob": "1990-01-01",
    "gender": "Male",
    "occupation": "Engineer"
  }
}
```

#### Update Profile

```
PUT /v1/users/{userId}/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Jane Doe",
  "gender": "Female",
  "occupation": "Doctor"
}

Response: 200 OK
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "Jane Doe",
    "dob": "1990-01-01",
    "gender": "Female",
    "occupation": "Doctor"
  }
}
```

#### Request OTP

```
POST /v1/users/{userId}/request-otp
Authorization: Bearer <token>
Content-Type: application/json

{
  "contact_method": "email"
}

Response: 200 OK
{
  "success": true,
  "message": "OTP sent successfully",
  "expires_in": 300
}
```

#### Change Password

```
POST /v1/users/{userId}/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "current_password": "oldpassword123",
  "new_password": "newpassword456"
}

Response: 200 OK
{
  "success": true,
  "message": "Password changed successfully"
}
```

### Predictions

#### Create Mental Health Prediction

```
POST /v1/predictions/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "screen_time_hours": 8.5,
  "work_screen_hours": 6.0,
  "leisure_screen_hours": 2.5,
  "sleep_hours": 6.5,
  "sleep_quality_1_5": 3,
  "stress_level_0_10": 7,
  "productivity_0_100": 65,
  "exercise_minutes_per_week": 120,
  "social_hours_per_week": 5.0
}

Response: 202 Accepted
{
  "prediction_id": "uuid",
  "status": "processing",
  "message": "Prediction is being processed..."
}
```

#### Get Prediction Result

```
GET /v1/predictions/{predictionId}/result
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "ready",
  "result": {
    "prediction_score": 45.3,
    "health_level": "average",
    "wellness_analysis": {
      "areas_for_improvement": [...],
      "strengths": [...]
    },
    "advice": {
      "description": "...",
      "factors": {...}
    }
  },
  "created_at": "2026-01-22T...",
  "completed_at": "2026-01-22T..."
}
```

### Analytics

#### Get Prediction History

```
GET /v1/users/{userId}/history
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "count": 5,
  "data": [
    {
      "prediction_id": "uuid-1...",
      "created_at": "2026-02-04T10:00:00",
      "prediction_score": 35.5,
      "health_level": "healthy",
      "wellness_analysis": {...},
      "advice": {...}
    }
  ]
}
```

#### Get Activity Streaks

```
GET /v1/users/{userId}/streaks
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "daily": {
      "current": 5,
      "last_date": "2026-02-02"
    },
    "weekly": {
      "current": 2,
      "last_date": "2026-02-02"
    }
  }
}
```

#### Get Weekly Chart Data

```
GET /v1/users/{userId}/weekly-chart
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": [
    {
      "date": "2026-02-04",
      "label": "Wed",
      "has_data": true,
      "mental_health_index": 45.0,
      "screen_time": 12.0,
      "sleep_duration": 4.5,
      "sleep_quality": 2.0,
      "stress_level": 8.0,
      "productivity": 40.0,
      "exercise_duration": 0.0,
      "social_activity": 1.0
    },
    {
      "date": "2026-02-05",
      "label": "Thu",
      "has_data": true,
      "mental_health_index": 92.5,
      "screen_time": 4.0,
      "sleep_duration": 8.0,
      "sleep_quality": 5.0,
      "stress_level": 1.5,
      "productivity": 95.0,
      "exercise_duration": 60.0,
      "social_activity": 5.0
    }
  ]
}
```

#### Get Weekly Critical Factors

```
GET /v1/users/{userId}/weekly-factors
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "critical_factors": [...]
  }
}
```

#### Get Daily Suggestions

```
GET /v1/users/{userId}/daily-suggestions
Authorization: Bearer <token>

Response: 200 OK
{
  "status": "success",
  "data": {
    "suggestion": "...",
    "focus_areas": [...]
  }
}
```

## Configuration

### Kong Configuration File

The gateway is configured using [kong.yml](kong.yml) in declarative format (version 3.0).

**Key Configuration Elements:**

- **Format Version**: 3.0
- **Services**: 12 microservice routes organized by semantic domain
- **Routes**: Domain-oriented API with `/v1/` prefix
- **Plugins**: CORS and file-log enabled globally

### Environment Variables

Kong requires the following environment variables (typically set in deployment):

```env
KONG_DATABASE=off
KONG_DECLARATIVE_CONFIG=/path/to/kong.yml
KONG_PROXY_ACCESS_LOG=/dev/stdout
KONG_ADMIN_ACCESS_LOG=/dev/stdout
KONG_PROXY_ERROR_LOG=/dev/stderr
KONG_ADMIN_ERROR_LOG=/dev/stderr
```

## Getting Started

### Prerequisites

- Kong Gateway 3.6+
- Access to backend services:
  - Authentication service at `http://188.166.233.241:80`
  - ML Model service at `http://165.22.246.95:80`
- SSL/TLS certificate for `api.mindsync.my` (for HTTPS support)
- Domain DNS configured to point to your server

### SSL/HTTPS Configuration

The API Gateway is configured to run on standard HTTP/HTTPS ports (80/443) with the domain `api.mindsync.my`.

#### Generating SSL Certificates

**Option 1: Using Let's Encrypt (Recommended for Production)**

```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot

# Generate certificate for api.mindsync.my
sudo certbot certonly --standalone -d api.mindsync.my

# Certificates will be created at:
# /etc/letsencrypt/live/api.mindsync.my/fullchain.pem
# /etc/letsencrypt/live/api.mindsync.my/privkey.pem
```

**Option 2: Self-Signed Certificate (Development Only)**

```bash
# Quick method - use the provided script:
chmod +x generate-ssl.sh
./generate-ssl.sh

# Or manual method:
# Create SSL directory
mkdir -p ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/CN=api.mindsync.my"
```

#### Updating kong.yml with Your SSL Certificate

1. Open kong.yml and locate the certificates section
2. Replace the placeholder certificate and key with your actual SSL certificate:

```yaml
certificates:
  - cert: |
      -----BEGIN CERTIFICATE-----
      [Your certificate content here]
      -----END CERTIFICATE-----
    key: |
      -----BEGIN PRIVATE KEY-----
      [Your private key content here]
      -----END PRIVATE KEY-----
    id: mindsync-cert
```

### Installation Options

#### Option 1: Docker (Recommended)

```bash
# Build the image
docker build -t mindsync-gateway .

# Run with SSL certificates
docker run -d --name kong-gateway \
  -v $(pwd)/ssl/cert.pem:/usr/local/kong/ssl/cert.pem:ro \
  -v $(pwd)/ssl/key.pem:/usr/local/kong/ssl/key.pem:ro \
  -p 80:80 \
  -p 443:443 \
  -p 8001:8001 \
  mindsync-gateway

# For Let's Encrypt certificates:
docker run -d --name kong-gateway \
  -v /etc/letsencrypt/live/api.mindsync.my/fullchain.pem:/usr/local/kong/ssl/cert.pem:ro \
  -v /etc/letsencrypt/live/api.mindsync.my/privkey.pem:/usr/local/kong/ssl/key.pem:ro \
  -p 80:80 \
  -p 443:443 \
  -p 8001:8001 \
  mindsync-gateway
```

#### Option 2: Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: "3.8"

services:
  kong-gateway:
    build: .
    container_name: mindsync-api-gateway
    ports:
      - "80:80"
      - "443:443"
      - "8001:8001"
    volumes:
      - ./ssl/cert.pem:/usr/local/kong/ssl/cert.pem:ro
      - ./ssl/key.pem:/usr/local/kong/ssl/key.pem:ro
    restart: unless-stopped
```

Then run:

```bash
docker-compose up -d
```

### Verify Installation

Test the gateway is running:

```bash
# Health check (admin API)
curl http://localhost:8001/status

# Test HTTPS endpoint
curl https://api.mindsync.my/v1/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Test HTTP endpoint (will redirect to HTTPS in production)
curl http://api.mindsync.my/v1/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### Default Ports

- **Proxy Port (HTTP)**: 80
- **Proxy Port (HTTPS)**: 443
- **Admin API (HTTP)**: 8001

### Access Through Gateway

All requests should be made to the domain `api.mindsync.my`:

```bash
# Authentication endpoints
https://api.mindsync.my/v1/auth/register
https://api.mindsync.my/v1/auth/login
https://api.mindsync.my/v1/users/{userId}/profile

# Prediction endpoints
https://api.mindsync.my/v1/predictions/create
https://api.mindsync.my/v1/predictions/{predictionId}/result

# Analytics endpoints
https://api.mindsync.my/v1/users/{userId}/history
https://api.mindsync.my/v1/users/{userId}/streaks
https://api.mindsync.my/v1/users/{userId}/weekly-chart
```

## Plugins

### CORS Plugin

Enables Cross-Origin Resource Sharing for all services.

**Configuration:**

- **Origins**: `*` (all origins allowed)
- **Methods**: GET, POST, PUT, PATCH, DELETE, OPTIONS
- **Headers**: Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Auth-Token
- **Exposed Headers**: X-Auth-Token
- **Credentials**: Enabled
- **Max Age**: 3600 seconds

### File Log Plugin

Logs all requests and responses to stdout.

**Configuration:**

- **Path**: `/dev/stdout`
- **Reopen**: false

## Testing

### Manual Testing with cURL

**Test Authentication:**

```bash
# Register
curl -X POST http://localhost:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","name":"Test User"}'

# Login
curl -X POST http://localhost:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**Test Predictions:**

```bash
# Submit prediction
curl -X POST http://localhost:8000/v1/predictions/create \
  -H "Content-Type: application/json" \
  -d '{
    "screen_time_hours": 8,
    "work_screen_hours": 6,
    "leisure_screen_hours": 2,
    "sleep_hours": 7,
    "sleep_quality_1_5": 3,
    "stress_level_0_10": 5,
    "productivity_0_100": 70,
    "exercise_minutes_per_week": 150,
    "social_hours_per_week": 10
  }'

# Check result
curl http://localhost:8000/v1/predictions/<prediction_id>/result
```

### Automated Testing

Run the test suite:

```bash
# Install test dependencies
pip install -r requirements-test.txt

# Run tests
pytest tests/
```

## Troubleshooting

### Service Unavailable (503)

If you receive 503 errors, check:

1. Backend services are running and accessible
2. Service URLs in kong.yml are correct
3. Network connectivity between Kong and backend services

```bash
# Test backend connectivity
curl http://188.166.233.241:80/hello
curl http://165.22.246.95:80/
```

### CORS Issues

If experiencing CORS errors:

1. Verify CORS plugin is enabled in kong.yml
2. Check browser console for specific CORS errors
3. Ensure origins list includes your client domain

### Route Not Found (404)

If routes are not found:

1. Verify route paths start with `/v1/`
2. Check Kong has loaded the latest kong.yml
3. Reload configuration:

   ```bash
   # Docker
   docker restart kong-gateway

   # Local installation
   kong reload
   ```

## Deployment

### Production Considerations

1. **HTTPS**: Configure SSL certificates for secure communication
2. **Rate Limiting**: Add rate limiting plugin to prevent abuse
3. **Authentication**: Consider adding API key authentication
4. **Monitoring**: Set up logging and monitoring solutions
5. **Load Balancing**: Configure multiple upstream targets for high availability

### Example Production Plugin Configuration

```yaml
plugins:
  - name: rate-limiting
    config:
      minute: 100
      policy: local

  - name: key-auth
    config:
      key_names:
        - apikey
```

## Architecture Diagram

```
┌──────────────────┐
│  Client Apps     │
│  (Web/Mobile)    │
└────────┬─────────┘
         │
         ↓
┌────────────────────────────────────┐
│    Kong API Gateway                │
│                                    │
│  Domains:                          │
│  • /v1/auth/*                     │
│  • /v1/users/*                    │
│  • /v1/predictions/*              │
│                                    │
│  Plugins:                          │
│  • CORS                            │
│  • File Log                        │
└──┬──────────┬──────────────────┬──┘
   │          │                  │
   ↓          ↓                  ↓
┌──────────────┐   ┌─────────────────┐
│ Auth Service │   │  ML Model API   │
│ (Spring Boot)│   │    (Flask)      │
│              │   │                 │
│ Port: 80     │   │  Port: 80       │
└──────────────┘   └─────────────────┘
```

## Version History

- **v0.1**: Initial API Gateway configuration
  - Basic routing for auth and model services
  - CORS support
  - Request logging

## Related Projects

- **Backend Service**: [mindsync-backend](../mindsync-backend) - Authentication and user management
- **ML Model Service**: [mindsync-model-flask](../mindsync-model-flask) - Mental health predictions

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/NewRoute`)
3. Update kong.yml with new service/route
4. Add tests in tests/ directory
5. Commit changes (`git commit -m 'Add new route'`)
6. Push to branch (`git push origin feature/NewRoute`)
7. Create Pull Request

## License

This project is part of the MindSync application suite.

---

**Questions or Issues?** Please create an issue in the repository.
