const express = require('express');
const pool = require('./mysql');
const app = express();
const PORT = 3000; // More secure to have the port number be a constant

// Middleware to parse json and url-encoded query strings
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// GET route at the root path /
app.get('/', async (req, res) => {
    try {
        // Extract search parameters from the query string
        const { category, author, format } = req.query;

        // Validate that at least one search parameter is provided
        if (!category && !author) {
            return res.status(400).json({
                error: 'Please provide a search parameter: ?category=Sci-Fi or ?author=George Orwell',
            });
        }

        let sql = 'SELECT * FROM books WHERE ';
        const conditions = [];
        const params = [];

        if (category) {
            conditions.push('category = ?');
            params.push(category);
        }

        if (author) {
            conditions.push('author = ?');
            params.push(author);
        }

        sql += conditions.join(' OR ');

        // Execute the query using the connection pool
        const [rows] = await pool.query(sql, params);

        if (format === 'text') {
            // Format the results as html
            if (rows.length === 0) {
                return res.send('<p>No books found matching your criteria.</p>');
            }

            let html = '<h2>Matching Books</h2><ul>';
            rows.forEach((book) => {
                html += `
          <li>
            <strong>Title:</strong> ${book.title}<br>
            <strong>Author:</strong> ${book.author}<br>
            <strong>Category:</strong> ${book.category}<br>
          </li>
        `;
            });
            html += '</ul>';

            res.send(html);
        } else {
            // Default to json response
            res.json({
                message: 'Books retrieved successfully',
                data: rows,
            });
        }
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({
            error: 'An error occurred while fetching books from the database.',
        });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});