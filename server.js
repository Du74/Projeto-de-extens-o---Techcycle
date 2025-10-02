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

// Log todas as requisições
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.url}`);
  next();
});

// Servir arquivos estáticos
app.use(express.static(__dirname, {
  index: false
}));

// ==================== VERIFICAÇÃO DE ARQUIVOS ====================
console.log("🔍 Verificando arquivos HTML...");
const files = [
  'introducao_techcycle.html',
  'login.html', 
  'register.html',
  'dashboard.html',
  'about.html'
];

files.forEach(file => {
  const filePath = path.join(__dirname, file);
  if (fs.existsSync(filePath)) {
    console.log(`✅ ${file} - ENCONTRADO`);
  } else {
    console.log(`❌ ${file} - NÃO ENCONTRADO`);
  }
});

// ==================== ROTAS DE PÁGINAS HTML ====================
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, 'introducao_techcycle.html'));
});

app.get("/login", (req, res) => {
  res.sendFile(path.join(__dirname, 'login.html'));
});

app.get("/register", (req, res) => {
  res.sendFile(path.join(__dirname, 'register.html'));
});

app.get("/dashboard", (req, res) => {
  res.sendFile(path.join(__dirname, 'dashboard.html'));
});

app.get("/about", (req, res) => {
  res.sendFile(path.join(__dirname, 'about.html'));
});

// ==================== ROTA DE TESTE ====================
app.get("/test", (req, res) => {
  res.json({ 
    message: "Servidor RODANDO!",
    directory: __dirname,
    files: fs.readdirSync(__dirname)
  });
});

// ==================== ROTAS API ====================

// ROTA PARA PEGAR TODOS OS CHAMADOS (GET) - APENAS UMA!
app.get("/chamados", (req, res) => {
  console.log("🔍 GET /chamados - Buscando no MySQL...");
  
  const sql = `
    SELECT 
      id,
      nome_chamado,
      tipo,
      marca,
      data_abertura,
      dashboard,
      problema,
      status,
      criado_em
    FROM chamados 
    ORDER BY criado_em DESC
  `;
  
  db.query(sql, (err, results) => {
    if (err) {
      console.error("❌ Erro MySQL em /chamados:", err);
      return res.status(500).json({ 
        error: "Erro no banco de dados",
        details: err.message 
      });
    }
    
    console.log(`✅ GET /chamados - Retornando ${results.length} chamados`);
    res.json(results);
  });
});

// ROTA PARA CRIAR CHAMADO (POST)
app.post("/chamados", (req, res) => {
  console.log("📨 POST /chamados - Criando chamado...");
  
  const { nome_chamado, tipo, marca, data_abertura, dashboard, problema } = req.body;
  
  const sql = `INSERT INTO chamados (nome_chamado, tipo, marca, data_abertura, dashboard, problema) VALUES (?, ?, ?, ?, ?, ?)`;
  
  db.query(sql, [nome_chamado, tipo, marca, data_abertura, dashboard, problema], (err, results) => {
    if (err) {
      console.error("❌ Erro ao criar chamado:", err);
      return res.status(500).json({ error: err.message });
    }
    
    console.log("✅ Chamado criado com ID:", results.insertId);
    res.json({ id: results.insertId, message: "Chamado criado com sucesso" });
  });
});

// ROTA PARA ESTATÍSTICAS
app.get("/estatisticas", (req, res) => {
  console.log("📊 GET /estatisticas - Calculando estatísticas...");
  
  const queries = {
    total: "SELECT COUNT(*) as total FROM chamados",
    pendentes: "SELECT COUNT(*) as pendentes FROM chamados WHERE status = 'Aberto' OR status = 'Pendente' OR status IS NULL",
    concluidos: "SELECT COUNT(*) as concluidos FROM chamados WHERE status = 'Concluído'",
    recentes: "SELECT * FROM chamados ORDER BY criado_em DESC LIMIT 5"
  };

  db.query(queries.total, (err, totalResult) => {
    if (err) {
      console.error("❌ Erro em query total:", err);
      return res.status(500).json(err);
    }
    
    const total = totalResult[0].total || 0;
    console.log(`📊 Total de chamados: ${total}`);
    
    db.query(queries.pendentes, (err, pendentesResult) => {
      if (err) {
        console.error("❌ Erro em query pendentes:", err);
        return res.status(500).json(err);
      }
      
      const pendentes = pendentesResult[0].pendentes || 0;
      console.log(`📊 Pendentes: ${pendentes}`);
      
      db.query(queries.concluidos, (err, concluidosResult) => {
        if (err) {
          console.error("❌ Erro em query concluidos:", err);
          return res.status(500).json(err);
        }
        
        const concluidos = concluidosResult[0].concluidos || 0;
        console.log(`📊 Concluídos: ${concluidos}`);
        
        db.query(queries.recentes, (err, recentesResult) => {
          if (err) {
            console.error("❌ Erro em query recentes:", err);
            return res.status(500).json(err);
          }
          
          console.log(`📊 Recentes: ${recentesResult.length} chamados`);
          
          const taxaSucesso = total > 0 ? Math.round((concluidos / total) * 100) : 0;
          
          const estatisticas = {
            total,
            pendentes,
            concluidos,
            taxaSucesso,
            recentes: recentesResult
          };
          
          console.log("✅ Estatísticas calculadas:", estatisticas);
          res.json(estatisticas);
        });
      });
    });
  });
});
;
// ==================== ROTAS DELETE ====================

// ROTA PARA DELETAR TODOS OS CHAMADOS
app.delete("/chamados", (req, res) => {
  console.log("🗑️ DELETE /chamados - Limpando todos os chamados...");
  
  const sql = "DELETE FROM chamados";
  
  db.query(sql, (err, results) => {
    if (err) {
      console.error("❌ Erro ao deletar chamados:", err);
      return res.status(500).json({ 
        error: "Erro ao deletar chamados",
        details: err.message 
      });
    }
    
    console.log(`✅ ${results.affectedRows} chamados deletados`);
    res.json({ 
      message: "Todos os chamados foram deletados com sucesso!",
      deletedCount: results.affectedRows 
    });
  });
});

// ROTA PARA DELETAR UM CHAMADO ESPECÍFICO
app.delete("/chamados/:id", (req, res) => {
  const { id } = req.params;
  console.log(`🗑️ DELETE /chamados/${id} - Deletando chamado...`);
  
  const sql = "DELETE FROM chamados WHERE id = ?";
  
  db.query(sql, [id], (err, results) => {
    if (err) {
      console.error("❌ Erro ao deletar chamado:", err);
      return res.status(500).json({ 
        error: "Erro ao deletar chamado",
        details: err.message 
      });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ message: "Chamado não encontrado" });
    }
    
    console.log(`✅ Chamado ${id} deletado com sucesso`);
    res.json({ 
      message: "Chamado deletado com sucesso", 
      deletedId: id 
    });
  });
});

// ==================== NOVAS ROTAS PARA AS PÁGINAS ====================

// Rota para Novo Chamado
app.get("/novo-chamado", (req, res) => {
  res.sendFile(path.join(__dirname, 'novo-chamado.html'));
});

// Rota para Relatórios
app.get("/relatorios", (req, res) => {
  res.sendFile(path.join(__dirname, 'relatorios.html'));
});

// Rota para Configurações
app.get("/configuracoes", (req, res) => {
  res.sendFile(path.join(__dirname, 'configuracoes.html'));
});




// ROTA DE TESTE DO BANCO
app.get("/test-db", (req, res) => {
  console.log("🔍 Testando conexão com o banco...");
  
  db.query("SELECT COUNT(*) as total FROM chamados", (err, results) => {
    if (err) {
      console.error("❌ Erro no teste do banco:", err);
      return res.status(500).json({ 
        error: "Erro no banco de dados",
        details: err.message 
      });
    }
    
    console.log("✅ Teste do banco OK - Total de chamados:", results[0].total);
    res.json({ 
      message: "Conexão com o banco OK",
      totalChamados: results[0].total,
      database: "techcycle"
    });
  });
});
// ==================== ROTAS DE AUTENTICAÇÃO ====================

// ROTA PARA REGISTRAR USUÁRIO
app.post("/register", async (req, res) => {
  console.log("📝 POST /register - Registrando usuário...");
  
  const { email, senha } = req.body;
  
  if (!email || !senha) {
    return res.status(400).json({ error: "Email e senha são obrigatórios" });
  }

  try {
    // Verificar se usuário já existe
    const checkSql = "SELECT * FROM usuarios WHERE email = ?";
    db.query(checkSql, [email], async (err, results) => {
      if (err) {
        console.error("❌ Erro ao verificar usuário:", err);
        return res.status(500).json({ error: "Erro no servidor" });
      }
      
      if (results.length > 0) {
        return res.status(400).json({ error: "Usuário já existe" });
      }
      
      // Hash da senha
      const hashedPassword = await bcrypt.hash(senha, 10);
      
      // Inserir usuário
      const insertSql = "INSERT INTO usuarios (email, senha) VALUES (?, ?)";
      db.query(insertSql, [email, hashedPassword], (err, results) => {
        if (err) {
          console.error("❌ Erro ao criar usuário:", err);
          return res.status(500).json({ error: "Erro ao criar usuário" });
        }
        
        console.log("✅ Usuário registrado com ID:", results.insertId);
        res.json({ 
          message: "Usuário registrado com sucesso!",
          id: results.insertId 
        });
      });
    });
    
  } catch (error) {
    console.error("❌ Erro no registro:", error);
    res.status(500).json({ error: "Erro interno do servidor" });
  }
});

// ROTA PARA LOGIN
app.post("/login", async (req, res) => {
  console.log("🔐 POST /login - Tentativa de login...");
  
  const { email, senha } = req.body;
  
  if (!email || !senha) {
    return res.status(400).json({ error: "Email e senha são obrigatórios" });
  }

  try {
    // Buscar usuário
    const sql = "SELECT * FROM usuarios WHERE email = ?";
    db.query(sql, [email], async (err, results) => {
      if (err) {
        console.error("❌ Erro ao buscar usuário:", err);
        return res.status(500).json({ error: "Erro no servidor" });
      }
      
      if (results.length === 0) {
        return res.status(401).json({ error: "Usuário não encontrado" });
      }
      
      const usuario = results[0];
      
      // Verificar senha
      const senhaValida = await bcrypt.compare(senha, usuario.senha);
      
      if (!senhaValida) {
        return res.status(401).json({ error: "Senha incorreta" });
      }
      
      console.log("✅ Login bem-sucedido para:", email);
      res.json({ 
        message: "Login bem-sucedido!",
        usuario: { id: usuario.id, email: usuario.email }
      });
    });
    
  } catch (error) {
    console.error("❌ Erro no login:", error);
    res.status(500).json({ error: "Erro interno do servidor" });
  }
});

// ==================== ROTAS DINÂMICAS PARA TODAS AS PÁGINAS HTML ====================

// Rota dinâmica para qualquer página HTML
app.get("/:pagina", (req, res) => {
  const pagina = req.params.pagina;
  
  // Lista de páginas permitidas
  const paginasPermitidas = [
    'novo-chamado',
    'relatorios', 
    'configuracoes',
    'dashboard',
    'login',
    'register',
    'about'
  ];
  
  if (paginasPermitidas.includes(pagina)) {
    const filePath = path.join(__dirname, `${pagina}.html`);
    
    // Verificar se o arquivo existe
    if (fs.existsSync(filePath)) {
      res.sendFile(filePath);
    } else {
      res.status(404).json({ error: 'Página não encontrada' });
    }
  } else {
    res.status(404).json({ error: 'Página não encontrada' });
  }
});




// ==================== INICIAR SERVIDOR ====================
app.listen(PORT, () => {
  console.log(`\n🚀 SERVIDOR INICIADO`);
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`📁 Diretório: ${__dirname}`);
  console.log(`🔍 Teste primeiro: http://localhost:${PORT}/test\n`);
});