


// Rotas para todos os arquivos HTML (deve ficar após a definição do app, antes do app.listen)
// --- Adicione logo antes do app.listen ---
// app.get("/about.html", ...)
const express = require("express");
const cors = require("cors");
const db = require("./db");
const bcrypt = require('bcryptjs');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Log todas as requisições

// Rota para introducao_techcycle.html (deve vir após a inicialização do app)
app.get("/introducao_techcycle.html", (req, res) => {
  console.log("🏠 Rota /introducao_techcycle.html solicitada");
  sendHTML(res, 'introducao_techcycle.html');
});
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.url}`);
  next();
});

// ==================== DIAGNÓSTICO ====================
console.log("🔍 DIAGNÓSTICO DO SERVIDOR:");
console.log("📁 Diretório atual:", __dirname);

// Verificar se as pastas existem
const folders = [
  'public',
  'public/html', 
  'public/css',
  'public/js'
];

folders.forEach(folder => {
  const folderPath = path.join(__dirname, folder);
  if (fs.existsSync(folderPath)) {
    console.log(`✅ ${folder} - EXISTE`);
    // Listar arquivos na pasta
    try {
      const files = fs.readdirSync(folderPath);
      console.log(`   📄 Arquivos: ${files.join(', ')}`);
    } catch (e) {
      console.log(`   📄 (sem arquivos)`);
    }
  } else {
    console.log(`❌ ${folder} - NÃO EXISTE`);
  }
});

// ==================== ROTAS COM VERIFICAÇÃO ====================
function sendHTML(res, filename) {
  const filePath = path.join(__dirname, 'public/html', filename);
  console.log(`📄 Tentando enviar: ${filePath}`);
  
  if (fs.existsSync(filePath)) {
    console.log(`✅ Arquivo encontrado!`);
    res.sendFile(filePath);
  } else {
    console.log(`❌ Arquivo NÃO encontrado!`);
    res.status(404).json({ 
      error: 'Página não encontrada',
      file: filename,
      fullPath: filePath
    });
  }
}

app.get("/", (req, res) => {
  console.log("🏠 Rota / solicitada");
  sendHTML(res, 'introducao_techcycle.html');
});

app.get("/login", (req, res) => {
  console.log("🔐 Rota /login solicitada");
  sendHTML(res, 'login.html');
});

app.get("/register", (req, res) => {
  console.log("📝 Rota /register solicitada");
  sendHTML(res, 'register.html');
});

app.get("/dashboard", (req, res) => {
  console.log("📊 Rota /dashboard solicitada");
  sendHTML(res, 'dashboard.html');
});

app.get("/novo-chamado", (req, res) => {
  console.log("➕ Rota /novo-chamado solicitada");
  sendHTML(res, 'novo-chamado.html');
});

app.get("/relatorios", (req, res) => {
  console.log("📈 Rota /relatorios solicitada");
  sendHTML(res, 'relatorios.html');
});

app.get("/configuracoes", (req, res) => {
  console.log("⚙️ Rota /configuracoes solicitada");
  sendHTML(res, 'configuracoes.html');
});

app.get("/about", (req, res) => {
  console.log("ℹ️ Rota /about solicitada");
  sendHTML(res, 'about.html');
});

// ==================== ROTAS API (mantenha as mesmas) ====================
app.get("/chamados", (req, res) => {
  const sql = `SELECT * FROM chamados ORDER BY criado_em DESC`;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post("/chamados", (req, res) => {
  const { nome_chamado, tipo, marca, data_abertura, dashboard, problema } = req.body;
  const sql = `INSERT INTO chamados (nome_chamado, tipo, marca, data_abertura, dashboard, problema) VALUES (?, ?, ?, ?, ?, ?)`;
  
  db.query(sql, [nome_chamado, tipo, marca, data_abertura, dashboard, problema], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results.insertId, message: "Chamado criado com sucesso" });
  });
});

app.get("/estatisticas", (req, res) => {
  const queries = {
    total: "SELECT COUNT(*) as total FROM chamados",
    pendentes: "SELECT COUNT(*) as pendentes FROM chamados WHERE status = 'Aberto' OR status = 'Pendente' OR status IS NULL",
    concluidos: "SELECT COUNT(*) as concluidos FROM chamados WHERE status = 'Concluído'"
  };

  db.query(queries.total, (err, totalResult) => {
    if (err) return res.status(500).json(err);
    db.query(queries.pendentes, (err, pendentesResult) => {
      if (err) return res.status(500).json(err);
      db.query(queries.concluidos, (err, concluidosResult) => {
        if (err) return res.status(500).json(err);
        
        const total = totalResult[0].total || 0;
        const pendentes = pendentesResult[0].pendentes || 0;
        const concluidos = concluidosResult[0].concluidos || 0;
        const taxaSucesso = total > 0 ? Math.round((concluidos / total) * 100) : 0;
        
        res.json({ total, pendentes, concluidos, taxaSucesso });
      });
    });
  });
});

app.delete("/chamados", (req, res) => {
  const sql = "DELETE FROM chamados";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "Todos os chamados deletados!", deletedCount: results.affectedRows });
  });
});

app.delete("/chamados/:id", (req, res) => {
  const { id } = req.params;
  const sql = "DELETE FROM chamados WHERE id = ?";
  db.query(sql, [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.affectedRows === 0) return res.status(404).json({ message: "Chamado não encontrado" });
    res.json({ message: "Chamado deletado com sucesso", deletedId: id });
  });
});

app.post("/register", async (req, res) => {
  const { email, senha } = req.body;
  if (!email || !senha) return res.status(400).json({ error: "Email e senha são obrigatórios" });

  try {
    const checkSql = "SELECT * FROM usuarios WHERE email = ?";
    db.query(checkSql, [email], async (err, results) => {
      if (err) return res.status(500).json({ error: "Erro no servidor" });
      if (results.length > 0) return res.status(400).json({ error: "Usuário já existe" });
      
      const hashedPassword = await bcrypt.hash(senha, 10);
      const insertSql = "INSERT INTO usuarios (email, senha) VALUES (?, ?)";
      
      db.query(insertSql, [email, hashedPassword], (err, results) => {
        if (err) return res.status(500).json({ error: "Erro ao criar usuário" });
        res.json({ message: "Usuário registrado com sucesso!", id: results.insertId });
      });
    });
  } catch (error) {
    res.status(500).json({ error: "Erro interno do servidor" });
  }
});

app.post("/login", async (req, res) => {
  const { email, senha } = req.body;
  if (!email || !senha) return res.status(400).json({ error: "Email e senha são obrigatórios" });

  try {
    const sql = "SELECT * FROM usuarios WHERE email = ?";
    db.query(sql, [email], async (err, results) => {
      if (err) return res.status(500).json({ error: "Erro no servidor" });
      if (results.length === 0) return res.status(401).json({ error: "Usuário não encontrado" });
      
      const usuario = results[0];
      const senhaValida = await bcrypt.compare(senha, usuario.senha);
      if (!senhaValida) return res.status(401).json({ error: "Senha incorreta" });
      
      res.json({ message: "Login bem-sucedido!", usuario: { id: usuario.id, email: usuario.email } });
    });
  } catch (error) {
    res.status(500).json({ error: "Erro interno do servidor" });
  }
});

// Rotas para todos os arquivos HTML (adicione sempre antes do app.listen)
app.get("/about.html", (req, res) => { sendHTML(res, 'about.html'); });
app.get("/configuracoes.html", (req, res) => { sendHTML(res, 'configuracoes.html'); });
app.get("/dashboard.html", (req, res) => { sendHTML(res, 'dashboard.html'); });
app.get("/introducao_techcycle.html", (req, res) => { sendHTML(res, 'introducao_techcycle.html'); });
app.get("/login.html", (req, res) => { sendHTML(res, 'login.html'); });
app.get("/novo-chamado.html", (req, res) => { sendHTML(res, 'novo-chamado.html'); });
app.get("/register.html", (req, res) => { sendHTML(res, 'register.html'); });
app.get("/relatorios.html", (req, res) => { sendHTML(res, 'relatorios.html'); });

// ==================== INICIAR SERVIDOR ====================
app.listen(PORT, () => {
  console.log(`\n🚀 SERVIDOR INICIADO COM SUCESSO!`);
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`📁 Diretório: ${__dirname}`);
  console.log(`🔍 Teste: http://localhost:${PORT}/test\n`);
});