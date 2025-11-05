// --- LOGIN.HTML ---
document.addEventListener('DOMContentLoaded', function() {
  const loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', async e => {
      e.preventDefault();
      const email = document.getElementById('email').value.trim();
      const senha = document.getElementById('password').value.trim();
      const errorMsg = document.getElementById('errorMsg');
      const btn = loginForm.querySelector('button[type="submit"]');
      const originalText = btn.innerHTML;
      btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Entrando...';
      btn.disabled = true;
      errorMsg.style.display = 'none';
      try {
        const res = await fetch('http://localhost:3000/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, senha })
        });
        if (res.ok) {
          window.location.href = 'dashboard.html';
        } else {
          errorMsg.style.display = 'block';
          btn.innerHTML = originalText;
          btn.disabled = false;
        }
      } catch (error) {
        console.error('Erro:', error);
        errorMsg.textContent = 'Erro na conexão com o servidor';
        errorMsg.style.display = 'block';
        btn.innerHTML = originalText;
        btn.disabled = false;
      }
    });
  }

  // --- REGISTER.HTML ---
  const registerForm = document.getElementById('registerForm');
  if (registerForm) {
    const senhaInput = document.getElementById('senha');
    const confirmarSenhaInput = document.getElementById('confirmarSenha');
    const passwordMatch = document.getElementById('passwordMatch');
    const passwordStrength = document.getElementById('passwordStrength');
    if (senhaInput && confirmarSenhaInput && passwordMatch && passwordStrength) {
      senhaInput.addEventListener('input', function() {
        const senha = this.value;
        let strength = 0;
        if (senha.length >= 8) strength++;
        if (senha.match(/[a-z]/) && senha.match(/[A-Z]/)) strength++;
        if (senha.match(/\d/)) strength++;
        if (senha.match(/[^a-zA-Z\d]/)) strength++;
        passwordStrength.className = 'strength-fill';
        if (senha.length === 0) {
          passwordStrength.style.width = '0%';
        } else if (strength <= 1) {
          passwordStrength.classList.add('strength-weak');
        } else if (strength <= 3) {
          passwordStrength.classList.add('strength-medium');
        } else {
          passwordStrength.classList.add('strength-strong');
        }
      });
      confirmarSenhaInput.addEventListener('input', function() {
        if (this.value && this.value === senhaInput.value) {
          passwordMatch.style.display = 'block';
        } else {
          passwordMatch.style.display = 'none';
        }
      });
    }
    registerForm.addEventListener('submit', async e => {
      e.preventDefault();
      const email = document.getElementById('email').value.trim();
      const senha = document.getElementById('senha').value.trim();
      const confirmarSenha = document.getElementById('confirmarSenha').value.trim();
      const errorMsg = document.getElementById('errorMsg');
      const successMsg = document.getElementById('successMsg');
      errorMsg.style.display = 'none';
      successMsg.style.display = 'none';
      if (senha !== confirmarSenha) {
        errorMsg.textContent = 'As senhas não coincidem';
        errorMsg.style.display = 'block';
        return;
      }
      if (senha.length < 6) {
        errorMsg.textContent = 'A senha deve ter pelo menos 6 caracteres';
        errorMsg.style.display = 'block';
        return;
      }
      const btn = registerForm.querySelector('button[type="submit"]');
      const originalText = btn.innerHTML;
      btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Criando conta...';
      btn.disabled = true;
      try {
        const res = await fetch('http://localhost:3000/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, senha })
        });
        const data = await res.json();
        if (res.ok) {
          successMsg.textContent = data.message || 'Conta criada com sucesso!';
          successMsg.style.display = 'block';
          setTimeout(() => {
            window.location.href = 'login.html';
          }, 2000);
        } else {
          errorMsg.textContent = data.error || 'Erro ao registrar usuário';
          errorMsg.style.display = 'block';
          btn.innerHTML = originalText;
          btn.disabled = false;
        }
      } catch (err) {
        errorMsg.textContent = 'Erro na conexão com o servidor';
        errorMsg.style.display = 'block';
        btn.innerHTML = originalText;
        btn.disabled = false;
      }
    
    
    
    });
  }
});
// ...existing code...
async function carregarMateriais() {
    const res = await fetch("http://localhost:3306/materiais");
    const dados = await res.json();
    const tabela = document.getElementById("tabela-materiais");
    tabela.innerHTML = "";
    dados.forEach(m => {
        tabela.innerHTML += `<tr><td>${m.id}</td><td>${m.nome}</td><td>${m.quantidade}</td></tr>`;
    });
}
async function adicionarMaterial() {
    const nome = document.getElementById("nome").value;
    const quantidade = document.getElementById("quantidade").value;
    await fetch("http://localhost:3000/materiais", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ nome, quantidade: Number(quantidade) })
    });
    carregarMateriais();
}
function toggleSidebar() {
  const sidebar = document.getElementById('sidebar');
  const content = document.getElementById('mainContent');
  sidebar.classList.toggle('active');
  content.classList.toggle('active');
}
// Rota para pegar todos os chamados (para listar)
app.get("/chamados", (req, res) => {
  db.query("SELECT * FROM chamados ORDER BY criado_em DESC", (err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
});

// Rota para deletar TODOS os chamados
app.delete("/chamados", (req, res) => {
  db.query("DELETE FROM chamados", (err, results) => {
    if (err) {
      console.error("Erro ao deletar chamados:", err);
      return res.status(500).json({ message: "Erro ao deletar chamados" });
    }
    console.log(`✅ ${results.affectedRows} chamados deletados`);
    res.json({ 
      message: "Todos os chamados foram deletados com sucesso!",
      deletedCount: results.affectedRows 
    });
  });
});

// Rota para deletar UM chamado específico
app.delete("/chamados/:id", (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM chamados WHERE id = ?", [id], (err, results) => {
    if (err) return res.status(500).json(err);
    res.json({ message: "Chamado deletado com sucesso", deletedId: id });
  });
});