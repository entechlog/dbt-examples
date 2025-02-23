const querystring = require("querystring");
const AWS = require("aws-sdk");

// Hard-code your secret's name:
const SECRET_NAME = "dbt-sso-secret";

// Single Secrets Manager client
const secretsClient = new AWS.SecretsManager({ region: "us-east-1" });

// We'll store the secret config in this variable after the first fetch
let secretConfig = null;

// Make this an async function so we can use `await`
async function getSecret() {
  // if we already fetched it once, just return
  if (secretConfig) return secretConfig;

  // fetch secret from Secrets Manager
  const data = await secretsClient.getSecretValue({ SecretId: SECRET_NAME }).promise();
  secretConfig = JSON.parse(data.SecretString);

  return secretConfig;
}

exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  const COOKIE_NAME = "session_token";

  // If a session cookie is present, allow the request
  if (headers.cookie && headers.cookie.find(c => c.value.includes(COOKIE_NAME))) {
    return request;
  }

  try {
    // Get secret config (CLIENT_ID, TENANT_ID, etc.)
    const config = await getSecret();
    const CLIENT_ID    = config.client_id;
    const TENANT_ID    = config.tenant;
    const REDIRECT_URI = config.redirect_uri;
    const AUTH_URL     = `https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/authorize`;

    // Build the querystring for the redirect
    const authQueryParams = querystring.stringify({
      client_id: CLIENT_ID,
      response_type: "code",
      redirect_uri: REDIRECT_URI,
      scope: "openid email profile",
      response_mode: "query"
    });

    return {
      status: "302",
      headers: {
        location: [
          { key: "Location", value: `${AUTH_URL}?${authQueryParams}` }
        ]
      }
    };
  } catch (error) {
    console.error("Error in authenticator:", error);
    return { status: "500", body: "Internal Server Error" };
  }
};
