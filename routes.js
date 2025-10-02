const express = require('express');
const router = express.Router();
const db = require('./db');
const produtoRoutes = require('./routes');

app.use('/', produtoRoutes);

// Cadastrar produto
router.post('/produtos', (req, res) => {
  const { nome, preco, estoque } = req.body;
  const sql = 'INSERT INTO produtos (nome, preco, estoque) VALUES (?, ?, ?)';
  db.query(sql, [nome, preco, estoque], (err, result) => {
    if (err) throw err;
    res.send({ id: result.insertId, nome, preco, estoque });
  });
});

// Listar produtos
router.get('/produtos', (req, res) => {
  db.query('SELECT * FROM produtos', (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

module.exports = router;