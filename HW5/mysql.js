// mysql.js - The Database Connection Pool Module
const fs = require('fs');
const path = require('path');

const currentDir = __dirname;

// Path to the SQL file in the same folder
const sqlFilePath = path.join(currentDir, 'HW5.sql');

// Read the SQL file
const sqlQuery = fs.readFileSync(sqlFilePath, 'utf8');

// Configuration details
const dbConfig = {
    host: "localhost",
    user: "root",
    password: "521Annadale!", 
    database: "hw5",
    // Connection Pool settings are optional but good practice
    waitForConnections: true, 
    connectionLimit: 10,
    queueLimit: 0
};

// Create and export the connection pool
const pool = sqlQuery.createPool(dbConfig);

// A simple check to ensure the pool is working on startup
pool.getConnection()
    .then(connection => {
        console.log("Database Pool: MySQL connection successful and pool established.");
        connection.release(); // Release the test connection immediately
    })
    .catch(err => {
        console.error("Database Pool Error: Could not connect to MySQL! Check credentials and if the server is running.", err.message);
    });

module.exports = pool;