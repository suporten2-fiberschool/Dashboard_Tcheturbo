// FiberDB - Schema DBML
// Visualize em: https://dbdiagram.io ou https://dbdocs.io

Project FiberDB {
  database_type: 'PostgreSQL'
  Note: 'Modelo de dados para plataforma LMS multi-tenant'
}

// ============================================
// CORE
// ============================================

Table instancias {
  id bigint [pk]
  instancia_mae bigint [note: 'ID da instância mãe (franquia)']
  subdominio text
  dominio text
  plano_id bigint
  limite_de_alunos bigint
  certificados_emitidos bigint [default: 0]
  removido_em timestamp
  criado_em timestamp

  indexes {
    criado_em
  }
}

// ============================================
// USUARIOS
// ============================================

Table alunos {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  nome text
  email text
  candidato boolean [note: 'true = aluno gratuito/candidato']
  celular varchar(50)
  documento varchar(50)
  pontos integer
  comecou_em timestamp [note: 'Primeiro acesso ao conteúdo']
  ultimo_acesso_em timestamp
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table admins {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  nome text
  email text
  celular text
  documento text
  ultimo_acesso_em timestamp
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table tags {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  origem_id bigint [note: 'ID original quando herdada']
  nome text
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table alunos_tags {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  usuario_id bigint [ref: > alunos.id]
  tag_id bigint [ref: > tags.id]

  indexes {
    instancia_id
  }
}

// ============================================
// CONTEUDO
// ============================================

Table cursos {
  id integer [pk]
  instancia_id integer [ref: > instancias.id]
  origem_id integer
  vitrine_id integer
  ic_gratis smallint [default: 0]
  ic_rascunho smallint [default: 0]
  ic_naolistado smallint [default: 0]
  ic_oculto smallint [default: 0]
  nome text
  removido_em timestamp
  criado_em timestamp

  indexes {
    instancia_id
    origem_id
  }
}

Table produtos {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  origem_id bigint
  vitrine_id bigint [ref: > cursos.id, note: 'Curso ao qual pertence']
  ic_gratis smallint [default: 0]
  ic_rascunho smallint [default: 0]
  ic_naolistado smallint [default: 0]
  ic_oculto smallint [default: 0]
  nome text
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table modulos {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  origem_id bigint
  produto_id bigint [ref: > produtos.id]
  secao_id bigint [note: 'ID da seção pai (hierarquia)']
  ic_rascunho smallint [default: 0]
  nome text
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
    produto_id
  }
}

Table aulas {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  origem_id bigint
  produto_id bigint [ref: > produtos.id]
  secao_id bigint [ref: > modulos.id, note: 'Módulo ao qual pertence']
  ic_rascunho smallint [default: 0]
  formato text [note: 'Tipo: video, texto, etc']
  titulo text
  video text [note: 'URL ou ID do vídeo']
  resumo text
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table provas {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  produto_id bigint [ref: > produtos.id]
  titulo text
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

// ============================================
// TRILHAS
// ============================================

Table trilhas {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  origem_id bigint
  referencia text [note: 'Identificador externo']
  nome text
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table trilhas_produtos {
  instancia_id bigint [ref: > instancias.id]
  trilha_id bigint [ref: > trilhas.id]
  produto_id bigint [ref: > produtos.id]
  trilha_origem_id bigint
  produto_origem_id bigint

  indexes {
    instancia_id
  }
}

Table trilhas_tags {
  id bigint [pk]
  tag_id bigint [ref: > tags.id]
  trilha_id bigint [ref: > trilhas.id]
  removido_em timestamp
  criado_em timestamp

  indexes {
    criado_em
  }
}

Table alunos_trilhas {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  origem_id bigint
  trilha_id bigint [ref: > trilhas.id]
  usuario_id bigint [ref: > alunos.id]
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

// ============================================
// PROGRESSO
// ============================================

Table alunos_progressos {
  instancia_id bigint [ref: > instancias.id]
  usuario_id bigint [ref: > alunos.id]
  item_id bigint [note: 'ID da aula ou item concluído']
  acao smallint [note: 'Tipo de ação realizada']
  criado_em timestamp

  indexes {
    instancia_id
    criado_em
  }
}

Table alunos_progressos_produtos {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id, not null]
  usuario_id bigint [ref: > alunos.id, not null]
  produto_id bigint [ref: > produtos.id, not null]
  progresso decimal(5,2) [default: 0, note: 'Percentual de conclusão (0-100)']
  criado_em timestamp [default: `CURRENT_TIMESTAMP`]
}

Table certificados {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  produto_id bigint [ref: > produtos.id]
  uid text [note: 'Código único do certificado']
  usuario_id bigint [ref: > alunos.id]
  criado_em timestamp

  indexes {
    instancia_id
    criado_em
  }
}

Table provas_resultados {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  produto_id bigint [ref: > produtos.id]
  prova_id bigint [ref: > provas.id]
  usuario_id bigint [ref: > alunos.id]
  nota_minima float [note: 'Nota mínima para aprovação']
  resultado float [note: 'Nota obtida']
  acertos integer
  erros integer
  removido_em timestamp
  criado_em timestamp

  indexes {
    (instancia_id, removido_em)
    criado_em
  }
}

Table pontuacoes {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  usuario_id bigint [ref: > alunos.id]
  produto_id bigint [ref: > produtos.id]
  tipo text [note: 'Tipo de pontuação']
  chave text [note: 'Identificador da ação']
  item_id bigint
  pontos integer
  criado_em timestamp

  indexes {
    instancia_id
    criado_em
    usuario_id
  }
}

// ============================================
// LOGS
// ============================================

Table logs {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  usuario_id bigint [ref: > alunos.id]
  referencia text [note: 'Página ou recurso acessado']
  ip text
  useragent text
  criado_em timestamp

  indexes {
    instancia_id
    criado_em
  }
}

Table admins_logs {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  admin_id bigint [ref: > admins.id]
  referencia text [note: 'Página ou recurso acessado']
  ip text
  useragent text
  criado_em timestamp

  indexes {
    instancia_id
    criado_em
  }
}

// ============================================
// MENSAGENS
// ============================================

Table mensagens {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  mensagem_id bigint [note: 'ID da mensagem pai (threads)']
  status text
  tipo text [note: 'Tipo de contexto da mensagem']
  tipo_id bigint [note: 'ID do registro relacionado ao tipo']
  papel text [note: 'Papel do remetente']
  papel_id bigint [note: 'ID do remetente conforme o papel']
  mensagem text
  meta text
  deleted_by bigint [note: 'ID de quem removeu']
  removido_em timestamp
  criado_em timestamp
}

// ============================================
// AVALIACOES
// ============================================

Table aulas_avaliacoes {
  id bigint [pk]
  instancia_id bigint [ref: > instancias.id]
  produto_id bigint [ref: > produtos.id]
  item_id bigint [note: 'ID da aula avaliada']
  usuario_id bigint [ref: > alunos.id]
  vote smallint [note: 'Voto do aluno']
  criado_em timestamp
}
