javascript
Copy
const { Pool } = require('pg');
const { SecretsManager } = require('aws-sdk');

const sm = new SecretsManager();
let pool;

const initPool = async () => {
  if (!pool) {
    const secret = await sm.getSecretValue({
      SecretId: '${aws_secretsmanager_secret.db.name}'
    }).promise();
    
    const { username, password } = JSON.parse(secret.SecretString);
    
    pool = new Pool({
      host: '${module.db.cluster_endpoint}',
      user: username,
      password: password,
      database: '${local.app_name}_db',
      ssl: { rejectUnauthorized: false }
    });
  }
  return pool;
};

exports.handler = async (event) => {
  const client = await initPool().connect();
  
  try {
    const result = await client.query('SELECT NOW()');
    return {
      statusCode: 200,
      body: JSON.stringify({ time: result.rows[0].now })
    };
  } finally {
    client.release();
  }
};

// The code above is a simple Lambda function that connects to the RDS database and returns the current time. The function uses the AWS SDK to retrieve the db credentials from SM and the db endpoint from the tf output