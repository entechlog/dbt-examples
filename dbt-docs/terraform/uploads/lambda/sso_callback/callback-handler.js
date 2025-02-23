const https = require("https");
const querystring = require("querystring");
const jwt = require("jsonwebtoken");
const AWS = require("aws-sdk");

let secretConfig;

const SECRET_NAME = "dbt-sso-secret"; // Must match what you used in Terraform
const secretsClient = new AWS.SecretsManager({ region: "us-east-1" });

const data = await secretsClient.getSecretValue({ SecretId: SECRET_NAME }).promise();

async function getSecret() {
  if (secretConfig) return secretConfig;

  const client = new AWS.SecretsManager({ region: "us-east-1" });
  const data = await client.getSecretValue({ SecretId: SECRET_ID }).promise();
  secretConfig = JSON.parse(data.SecretString);
  return secretConfig;
}

exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const uri = request.uri;
  const queryParams = new URLSearchParams(uri.split("?")[1] || "");
  const code = queryParams.get("code");

  if (!code) {
    return { status: "400", body: "Missing authorization code" };
  }

  try {
    const config = await getSecret();
    const CLIENT_ID     = config.client_id;
    const CLIENT_SECRET = config.client_secret;
    const TENANT_ID     = config.tenant;
    const REDIRECT_URI  = config.redirect_uri;
    const TOKEN_URL     = `https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token`;
    const COOKIE_NAME   = "session_token";

    const tokenResponse = await getAccessToken(
      code, CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, TOKEN_URL
    );
    if (!tokenResponse.id_token) {
      return { status: "401", body: "Authentication failed" };
    }

    const decoded = jwt.decode(tokenResponse.id_token);
    if (!decoded || !decoded.email) {
      return { status: "401", body: "Invalid token" };
    }

    return {
      status: "302",
      headers: {
        "set-cookie": [
          {
            key: "Set-Cookie",
            value: `${COOKIE_NAME}=${tokenResponse.id_token}; Path=/; HttpOnly; Secure; SameSite=Lax;`
          }
        ],
        location: [{ key: "Location", value: "/" }]
      }
    };
  } catch (error) {
    // optional: log the error
    console.error("Error in callback-handler:", error);
    return { status: "500", body: "Internal Server Error" };
  }
};

function getAccessToken(code, clientId, clientSecret, redirectUri, tokenUrl) {
  const postData = querystring.stringify({
    client_id: clientId,
    client_secret: clientSecret,
    code,
    grant_type: "authorization_code",
    redirect_uri: redirectUri
  });

  return new Promise((resolve, reject) => {
    const req = https.request(
      tokenUrl,
      { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" } },
      (res) => {
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => resolve(JSON.parse(data)));
      }
    );
    req.on("error", reject);
    req.write(postData);
    req.end();
  });
}
