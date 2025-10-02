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