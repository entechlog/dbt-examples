'use strict';

const https = require('https');
const querystring = require('querystring');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

// Constants
const SECRET_NAME = "dbt-sso-secret";
const REGION = "us-east-1";
const COOKIE_NAME = "session_token";
const COOKIE_MAX_AGE = 3600; // 1 hour

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

// Function to exchange code for tokens
function getTokens(code, clientId, clientSecret, redirectUri, tenantId) {
  return new Promise((resolve, reject) => {
    // Prepare token request
    const tokenUrl = `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`;
    const postData = querystring.stringify({
      client_id: clientId,
      client_secret: clientSecret,
      code: code,
      grant_type: 'authorization_code',
      redirect_uri: redirectUri
    });
    
    // Parse URL to get hostname and path
    const urlParts = tokenUrl.replace('https://', '').split('/');
    const hostname = urlParts[0];
    const path = '/' + urlParts.slice(1).join('/');
    
    const options = {
      hostname: hostname,
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(JSON.parse(data));
          } catch (error) {
            reject(new Error(`Failed to parse token response: ${error.message}`));
          }
        } else {
          reject(new Error(`Token endpoint returned ${res.statusCode}: ${data}`));
        }
      });
    });
    
    req.on('error', (error) => {
      reject(new Error(`Request error: ${error.message}`));
    });
    
    req.write(postData);
    req.end();
  });
}

exports.handler = async (event) => {
  try {
    // Get CloudFront request
    const request = event.Records[0].cf.request;
    
    // Parse query parameters from querystring
    const params = querystring.parse(request.querystring || '');
    const code = params.code;
    
    // Get host from headers for cookie domain
    const host = request.headers.host && request.headers.host[0].value;
    const domain = host ? host.split(':')[0] : '';
    
    // Check for authorization code
    if (!code) {
      return {
        status: '400',
        statusDescription: 'Bad Request',
        body: 'Missing authorization code'
      };
    }
    
    // Get auth configuration from Secrets Manager
    const config = await getSecret();
    const CLIENT_ID = config.client_id;
    const CLIENT_SECRET = config.client_secret;
    const TENANT_ID = config.tenant;
    const REDIRECT_URI = config.redirect_uri;
    
    // Exchange code for tokens
    const tokenResponse = await getTokens(
      code,
      CLIENT_ID,
      CLIENT_SECRET,
      REDIRECT_URI,
      TENANT_ID
    );
    
    // Check if we got an ID token
    if (!tokenResponse.id_token) {
      console.error("No id_token in response");
      return {
        status: '401',
        statusDescription: 'Unauthorized',
        body: 'Authentication failed'
      };
    }
    
    // Set cookie and redirect to home page
    return {
      status: '302',
      statusDescription: 'Found',
      headers: {
        'set-cookie': [{
          key: 'Set-Cookie',
          value: `${COOKIE_NAME}=${tokenResponse.id_token}; Path=/; Max-Age=${COOKIE_MAX_AGE}; HttpOnly; Secure; SameSite=Lax${domain ? `; Domain=${domain}` : ''}`
        }],
        'location': [{
          key: 'Location',
          value: '/'
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
    console.error("Callback Lambda error:", error);
    return {
      status: '500',
      statusDescription: 'Internal Server Error',
      body: 'Authentication process failed'
    };
  }
};
