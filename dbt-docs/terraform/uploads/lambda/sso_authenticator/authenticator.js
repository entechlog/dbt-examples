'use strict';

const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

// Constants
const SECRET_NAME = "SECRET-NAME-PLACEHOLDER";
const REGION = "us-east-1";
const COOKIE_NAME = "session_token";

// Initialize Secrets Manager client
const secretsClient = new SecretsManagerClient({ region: REGION });

// Cache for secrets
let secretCache = null;
let secretExpiry = 0;

// Function to get secrets with caching
async function getSecret() {
  const now = Date.now();
  
  // Use cached secret if available and not expired
  if (secretCache && now < secretExpiry) {
    return secretCache;
  }
  
  // Get secret from Secrets Manager
  try {
    const command = new GetSecretValueCommand({ SecretId: SECRET_NAME });
    const response = await secretsClient.send(command);
    secretCache = JSON.parse(response.SecretString);
    secretExpiry = now + (15 * 60 * 1000); // 15 minute cache
    return secretCache;
  } catch (error) {
    console.error("Error fetching secret:", error);
    throw error;
  }
}

exports.handler = async (event) => {
  try {
    // Get CloudFront request
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    
    // Check for existing session cookie
    if (headers.cookie && headers.cookie.some(cookie => 
      cookie.value.includes(`${COOKIE_NAME}=`))) {
      // User is authenticated, allow the request
      return request;
    }
    
    // Get auth configuration from Secrets Manager
    const config = await getSecret();
    const CLIENT_ID = config.client_id;
    const TENANT_ID = config.tenant;
    const REDIRECT_URI = config.redirect_uri;
    
    // Build auth URL
    const authUrl = `https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/authorize?` +
      `client_id=${CLIENT_ID}` +
      `&response_type=code` +
      `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}` +
      `&scope=openid%20email%20profile` +
      `&response_mode=query`;
    
    // Redirect to Microsoft login
    return {
      status: '302',
      statusDescription: 'Found',
      headers: {
        location: [{
          key: 'Location',
          value: authUrl
        }],
        'cache-control': [{
          key: 'Cache-Control',
          value: 'no-cache, no-store, must-revalidate'
        }],
        pragma: [{
          key: 'Pragma',
          value: 'no-cache'
        }]
      }
    };
  } catch (error) {
    console.error("Auth Lambda error:", error);
    return {
      status: '500',
      statusDescription: 'Internal Server Error',
      body: 'Authentication service unavailable'
    };
  }
};

