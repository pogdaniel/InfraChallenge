const { Pool } = require('pg');

exports.handler = async (event) => {
  const pool = new Pool({
    host: process.env.DB_ENDPOINT,
    database: process.env.DB_NAME,
    user: await getSecret('db_username'),
    password: await getSecret('db_password'),
  });
  
  // Business logic here
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Success" }),
  };
};
