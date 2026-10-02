/* ============================================================
   BANCO ACADÊMICO
   PostgreSQL
   Script idempotente:
   - CREATE TABLE IF NOT EXISTS
   - INSERT ... ON CONFLICT DO NOTHING
   - Pode ser executado repetidamente
   ============================================================ */


/* ============================================================
   0. DOMÍNIO PARA NOTAS
   ============================================================ */

DO $$
BEGIN
    CREATE DOMAIN nota_t AS NUMERIC(4,2)
        CHECK (VALUE >= 0 AND VALUE <= 10);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;



/* ============================================================
   1. CAMPUS
   ============================================================ */

CREATE TABLE IF NOT EXISTS campus (
    id_campus INT PRIMARY KEY,
    name_campus VARCHAR(60) NOT NULL,
    endereco_campus VARCHAR(200) NOT NULL,
    cep_campus VARCHAR(9),
    telefone_campus VARCHAR(11),

    CONSTRAINT uq_campus_nome
        UNIQUE (name_campus)
);


/* ============================================================
   2. ESTADO
   ============================================================ */

CREATE TABLE IF NOT EXISTS estado (
    id_estado INT PRIMARY KEY,
    nome_estado VARCHAR(100) NOT NULL,
    sigla_estado VARCHAR(2) NOT NULL,

    CONSTRAINT uq_estado_nome
        UNIQUE (nome_estado),

    CONSTRAINT uq_estado_sigla
        UNIQUE (sigla_estado),

    CONSTRAINT ck_estado_sigla
        CHECK (char_length(sigla_estado) = 2)
);


/* ============================================================
   3. CIDADE
   ============================================================ */

CREATE TABLE IF NOT EXISTS cidade (
    id_cidade INT PRIMARY KEY,
    id_estado INT NOT NULL,
    nome_cidade VARCHAR(120) NOT NULL,
    uf_cidade VARCHAR(2) NOT NULL,

    CONSTRAINT fk_cidade_estado
        FOREIGN KEY (id_estado)
        REFERENCES estado(id_estado),

    CONSTRAINT uq_cidade_estado_nome
        UNIQUE (id_estado, nome_cidade)
);


/* ============================================================
   4. FERIADO
   ============================================================ */

CREATE TABLE IF NOT EXISTS feriado (
    id_feriado INT PRIMARY KEY,
    nome_feriado VARCHAR(120) NOT NULL,
    descricao_feriado VARCHAR(200),
    data_feriado DATE NOT NULL
);


/* ============================================================
   5. CAMPUS_CIDADE
   ============================================================ */

CREATE TABLE IF NOT EXISTS campus_cidade (
    id_campus INT NOT NULL,
    id_cidade INT NOT NULL,

    PRIMARY KEY (id_campus, id_cidade),

    CONSTRAINT fk_campus_cidade_campus
        FOREIGN KEY (id_campus)
        REFERENCES campus(id_campus)
        ON DELETE CASCADE,

    CONSTRAINT fk_campus_cidade_cidade
        FOREIGN KEY (id_cidade)
        REFERENCES cidade(id_cidade)
        ON DELETE CASCADE
);


/* ============================================================
   6. CIDADE_FERIADO
   ============================================================ */

CREATE TABLE IF NOT EXISTS cidade_feriado (
    id_cidade INT NOT NULL,
    id_feriado INT NOT NULL,

    PRIMARY KEY (id_cidade, id_feriado),

    CONSTRAINT fk_cidade_feriado_cidade
        FOREIGN KEY (id_cidade)
        REFERENCES cidade(id_cidade)
        ON DELETE CASCADE,

    CONSTRAINT fk_cidade_feriado_feriado
        FOREIGN KEY (id_feriado)
        REFERENCES feriado(id_feriado)
        ON DELETE CASCADE
);


/* ============================================================
   7. ESTADO_FERIADO
   ============================================================ */

CREATE TABLE IF NOT EXISTS estado_feriado (
    id_feriado INT NOT NULL,
    id_estado INT NOT NULL,

    PRIMARY KEY (id_feriado, id_estado),

    CONSTRAINT fk_estado_feriado_feriado
        FOREIGN KEY (id_feriado)
        REFERENCES feriado(id_feriado)
        ON DELETE CASCADE,

    CONSTRAINT fk_estado_feriado_estado
        FOREIGN KEY (id_estado)
        REFERENCES estado(id_estado)
        ON DELETE CASCADE
);


/* ============================================================
   8. SALA
   ============================================================ */

CREATE TABLE IF NOT EXISTS sala (
    id_sala INT PRIMARY KEY,
    id_campus INT NOT NULL,
    codigo_sala VARCHAR(10) NOT NULL,
    tipo_sala VARCHAR(45) NOT NULL,
    capacidade_sala SMALLINT NOT NULL,

    CONSTRAINT fk_sala_campus
        FOREIGN KEY (id_campus)
        REFERENCES campus(id_campus),

    CONSTRAINT ck_sala_capacidade
        CHECK (capacidade_sala > 0),

    CONSTRAINT uq_sala_campus_codigo
        UNIQUE (id_campus, codigo_sala)
);


/* ============================================================
   9. CURSO
   ============================================================ */

CREATE TABLE IF NOT EXISTS curso (
    id_curso INT PRIMARY KEY,
    codigo_curso VARCHAR(10) NOT NULL,
    nome_curso VARCHAR(120) NOT NULL,
    grau_curso VARCHAR(20) NOT NULL,
    ch_total_curso VARCHAR(20),

    CONSTRAINT uq_curso_codigo
        UNIQUE (codigo_curso)
);


/* ============================================================
   10. CAMPUS_CURSO
   ============================================================ */

CREATE TABLE IF NOT EXISTS campus_curso (
    id_campus INT NOT NULL,
    id_curso INT NOT NULL,

    PRIMARY KEY (id_campus, id_curso),

    CONSTRAINT fk_campus_curso_campus
        FOREIGN KEY (id_campus)
        REFERENCES campus(id_campus)
        ON DELETE CASCADE,

    CONSTRAINT fk_campus_curso_curso
        FOREIGN KEY (id_curso)
        REFERENCES curso(id_curso)
        ON DELETE CASCADE
);


/* ============================================================
   11. CURRICULO
   ============================================================ */

CREATE TABLE IF NOT EXISTS curriculo (
    id_curriculo INT PRIMARY KEY,
    id_curso INT NOT NULL,
    modulo_curriculo CHAR(1),
    ativo_curriculo BOOLEAN NOT NULL DEFAULT TRUE,
    ano_inicio_curriculo SMALLINT NOT NULL,
    ano_previsto_fim_curriculo SMALLINT,

    CONSTRAINT fk_curriculo_curso
        FOREIGN KEY (id_curso)
        REFERENCES curso(id_curso),

    CONSTRAINT ck_curriculo_ano
        CHECK (
            ano_previsto_fim_curriculo IS NULL
            OR ano_previsto_fim_curriculo >= ano_inicio_curriculo
        )
);


/* ============================================================
   12. DISCIPLINA
   ============================================================ */

CREATE TABLE IF NOT EXISTS disciplina (
    id_disciplina INT PRIMARY KEY,
    codigo_disciplina VARCHAR(10) NOT NULL,
    nome_disciplina VARCHAR(120) NOT NULL,
    ementa_disciplina TEXT,
    ch_teorica_disciplina SMALLINT NOT NULL,
    ch_pratica_disciplina SMALLINT NOT NULL,
    ch_total_disciplina SMALLINT NOT NULL,

    CONSTRAINT uq_disciplina_codigo
        UNIQUE (codigo_disciplina),

    CONSTRAINT ck_disciplina_ch_teorica
        CHECK (ch_teorica_disciplina >= 0),

    CONSTRAINT ck_disciplina_ch_pratica
        CHECK (ch_pratica_disciplina >= 0),

    CONSTRAINT ck_disciplina_ch_total
        CHECK (
            ch_total_disciplina =
            ch_teorica_disciplina + ch_pratica_disciplina
        )
);


/* ============================================================
   13. CURRICULO_DISCIPLINA
   ============================================================ */

CREATE TABLE IF NOT EXISTS curriculo_disciplina (
    id_curriculo INT NOT NULL,
    id_disciplina INT NOT NULL,
    periodo_curriculo_disciplina VARCHAR(45) NOT NULL,
    tipo_curriculo_disciplina VARCHAR(45) NOT NULL,

    PRIMARY KEY (id_curriculo, id_disciplina),

    CONSTRAINT fk_curriculo_disciplina_curriculo
        FOREIGN KEY (id_curriculo)
        REFERENCES curriculo(id_curriculo)
        ON DELETE CASCADE,

    CONSTRAINT fk_curriculo_disciplina_disciplina
        FOREIGN KEY (id_disciplina)
        REFERENCES disciplina(id_disciplina)
        ON DELETE CASCADE
);


/* ============================================================
   14. PRE_REQUISITO
   ============================================================ */

CREATE TABLE IF NOT EXISTS pre_requisito (
    id_disciplina INT NOT NULL,
    id_disciplina_requisito INT NOT NULL,

    PRIMARY KEY (id_disciplina, id_disciplina_requisito),

    CONSTRAINT fk_pre_requisito_disciplina
        FOREIGN KEY (id_disciplina)
        REFERENCES disciplina(id_disciplina)
        ON DELETE CASCADE,

    CONSTRAINT fk_pre_requisito_requisito
        FOREIGN KEY (id_disciplina_requisito)
        REFERENCES disciplina(id_disciplina)
        ON DELETE CASCADE,

    CONSTRAINT ck_pre_requisito_nao_igual
        CHECK (id_disciplina <> id_disciplina_requisito)
);


/* ============================================================
   15. ALUNO
   ============================================================ */

CREATE TABLE IF NOT EXISTS aluno (
    id_aluno INT PRIMARY KEY,
    id_curriculo INT NOT NULL,
    matricula_aluno VARCHAR(15) NOT NULL,
    nome_aluno VARCHAR(120) NOT NULL,
    email_aluno VARCHAR(120) NOT NULL,
    cpf_aluno VARCHAR(14) NOT NULL,
    nascimento_aluno DATE NOT NULL,
    ingresso_aluno DATE NOT NULL,
    ativo_aluno BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_aluno_curriculo
        FOREIGN KEY (id_curriculo)
        REFERENCES curriculo(id_curriculo),

    CONSTRAINT uq_aluno_matricula
        UNIQUE (matricula_aluno),

    CONSTRAINT uq_aluno_email
        UNIQUE (email_aluno),

    CONSTRAINT uq_aluno_cpf
        UNIQUE (cpf_aluno)
);


/* ============================================================
   16. PERIODO_LETIVO
   ============================================================ */

CREATE TABLE IF NOT EXISTS periodo_letivo (
    id_periodo_letivo INT PRIMARY KEY,
    data_inicio_periodo_letivo DATE NOT NULL,
    data_fim_periodo_letivo DATE NOT NULL,
    semestre_periodo_letivo SMALLINT NOT NULL,
    ano_periodo_letivo SMALLINT NOT NULL,

    CONSTRAINT ck_periodo_datas
        CHECK (
            data_fim_periodo_letivo >= data_inicio_periodo_letivo
        ),

    CONSTRAINT ck_periodo_semestre
        CHECK (semestre_periodo_letivo IN (1, 2)),

    CONSTRAINT uq_periodo_ano_semestre
        UNIQUE (
            ano_periodo_letivo,
            semestre_periodo_letivo
        )
);


/* ============================================================
   17. TURMA
   ============================================================ */

CREATE TABLE IF NOT EXISTS turma (
    id_turma INT PRIMARY KEY,
    id_disciplina INT NOT NULL,
    periodo_letivo_id INT NOT NULL,
    codigo_turma VARCHAR(45) NOT NULL,
    turno_turma VARCHAR(45) NOT NULL,
    vagas_turmas SMALLINT NOT NULL,

    CONSTRAINT fk_turma_disciplina
        FOREIGN KEY (id_disciplina)
        REFERENCES disciplina(id_disciplina),

    CONSTRAINT fk_turma_periodo
        FOREIGN KEY (periodo_letivo_id)
        REFERENCES periodo_letivo(id_periodo_letivo),

    CONSTRAINT ck_turma_vagas
        CHECK (vagas_turmas > 0),

    CONSTRAINT uq_turma_periodo_codigo
        UNIQUE (periodo_letivo_id, codigo_turma)
);


/* ============================================================
   18. PROFESSOR
   ============================================================ */

CREATE TABLE IF NOT EXISTS professor (
    id_professor INT PRIMARY KEY,
    matricula_professor VARCHAR(12) NOT NULL,
    nome_professor VARCHAR(120) NOT NULL,
    email_professor VARCHAR(120) NOT NULL,
    titulacao_professor VARCHAR(20) NOT NULL,

    CONSTRAINT uq_professor_matricula
        UNIQUE (matricula_professor),

    CONSTRAINT uq_professor_email
        UNIQUE (email_professor)
);


/* ============================================================
   19. TURMA_PROFESSOR
   ============================================================ */

CREATE TABLE IF NOT EXISTS turma_professor (
    id_turma INT NOT NULL,
    id_professor INT NOT NULL,

    PRIMARY KEY (id_turma, id_professor),

    CONSTRAINT fk_turma_professor_turma
        FOREIGN KEY (id_turma)
        REFERENCES turma(id_turma)
        ON DELETE CASCADE,

    CONSTRAINT fk_turma_professor_professor
        FOREIGN KEY (id_professor)
        REFERENCES professor(id_professor)
        ON DELETE CASCADE
);


/* ============================================================
   20. TURMA_HORARIO
   ============================================================ */

CREATE TABLE IF NOT EXISTS turma_horario (
    id_turma_horario INT PRIMARY KEY,
    id_turma INT NOT NULL,
    id_sala INT NOT NULL,
    faixa_turma_horario VARCHAR(45) NOT NULL,
    dia_semana_turma_horario SMALLINT NOT NULL,

    CONSTRAINT fk_turma_horario_turma
        FOREIGN KEY (id_turma)
        REFERENCES turma(id_turma)
        ON DELETE CASCADE,

    CONSTRAINT fk_turma_horario_sala
        FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala),

    CONSTRAINT ck_turma_horario_dia
        CHECK (
            dia_semana_turma_horario BETWEEN 1 AND 7
        )
);


/* ============================================================
   21. MATRICULA
   ============================================================ */

CREATE TABLE IF NOT EXISTS matricula (
    id_matricula INT PRIMARY KEY,
    id_turma INT NOT NULL,
    id_aluno INT NOT NULL,
    data_matricula TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_matricula BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_matricula_turma
        FOREIGN KEY (id_turma)
        REFERENCES turma(id_turma),

    CONSTRAINT fk_matricula_aluno
        FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),

    CONSTRAINT uq_matricula_aluno_turma
        UNIQUE (id_aluno, id_turma)
);


/* ============================================================
   22. HISTORICO
   ============================================================ */

CREATE TABLE IF NOT EXISTS historico (
    id_historico INT PRIMARY KEY,
    id_matricula INT NOT NULL,
    nota_a1_historico nota_t,
    nota_a2_historico nota_t,
    nota_p3_historico nota_t,
    frequencia_historico SMALLINT,
    media_final_historico NUMERIC(4,2),

    CONSTRAINT fk_historico_matricula
        FOREIGN KEY (id_matricula)
        REFERENCES matricula(id_matricula)
        ON DELETE CASCADE,

    CONSTRAINT ck_historico_frequencia
        CHECK (
            frequencia_historico IS NULL
            OR frequencia_historico BETWEEN 0 AND 100
        ),

    CONSTRAINT ck_historico_media
        CHECK (
            media_final_historico IS NULL
            OR (
                media_final_historico >= 0
                AND media_final_historico <= 10
            )
        ),

    CONSTRAINT uq_historico_matricula
        UNIQUE (id_matricula)
);


/* ============================================================
   23. LOG_MATRICULA
   ============================================================ */

CREATE TABLE IF NOT EXISTS log_matricula (
    id_log_matricula INT PRIMARY KEY,
    id_matricula INT NOT NULL,
    acao_log_matricula VARCHAR(20) NOT NULL,
    usuario_log_matricula VARCHAR(20),
    ocorrido_em_log_matricula TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    matricula_id_log_matricula INT,
    detalhe_log_matricula JSONB,

    CONSTRAINT fk_log_matricula_matricula
        FOREIGN KEY (id_matricula)
        REFERENCES matricula(id_matricula)
        ON DELETE CASCADE
);


/* ============================================================
   ÍNDICES
   ============================================================ */

CREATE INDEX IF NOT EXISTS idx_cidade_estado
    ON cidade(id_estado);

CREATE INDEX IF NOT EXISTS idx_sala_campus
    ON sala(id_campus);

CREATE INDEX IF NOT EXISTS idx_aluno_curriculo
    ON aluno(id_curriculo);

CREATE INDEX IF NOT EXISTS idx_turma_disciplina
    ON turma(id_disciplina);

CREATE INDEX IF NOT EXISTS idx_turma_periodo
    ON turma(periodo_letivo_id);

CREATE INDEX IF NOT EXISTS idx_matricula_aluno
    ON matricula(id_aluno);

CREATE INDEX IF NOT EXISTS idx_matricula_turma
    ON matricula(id_turma);

CREATE INDEX IF NOT EXISTS idx_historico_matricula
    ON historico(id_matricula);

CREATE INDEX IF NOT EXISTS idx_pre_requisito_disciplina
    ON pre_requisito(id_disciplina);

CREATE INDEX IF NOT EXISTS idx_pre_requisito_requisito
    ON pre_requisito(id_disciplina_requisito);


/* ============================================================
   CARGA DE DADOS
   ============================================================ */


/* ------------------------------------------------------------
   ESTADOS
   ------------------------------------------------------------ */

INSERT INTO estado
    (id_estado, nome_estado, sigla_estado)
VALUES
    (1, 'Distrito Federal', 'DF'),
    (2, 'Goiás', 'GO')
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   CIDADES
   ------------------------------------------------------------ */

INSERT INTO cidade
    (id_cidade, id_estado, nome_cidade, uf_cidade)
VALUES
    (1, 1, 'Brasília', 'DF'),
    (2, 2, 'Goiânia', 'GO'),
    (3, 2, 'Anápolis', 'GO')
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   CAMPUS
   ------------------------------------------------------------ */

INSERT INTO campus
    (id_campus, name_campus, endereco_campus, cep_campus, telefone_campus)
VALUES
    (1, 'Campus Central', 'Campus Central, Brasília - DF', '70000000', '6130000000'),
    (2, 'Campus Goiânia', 'Campus Goiânia, Goiânia - GO', '74000000', '6230000000')
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   RELAÇÃO CAMPUS/CIDADE
   ------------------------------------------------------------ */

INSERT INTO campus_cidade
    (id_campus, id_cidade)
VALUES
    (1, 1),
    (2, 2)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   FERIADOS
   ------------------------------------------------------------ */

INSERT INTO feriado
    (id_feriado, nome_feriado, descricao_feriado, data_feriado)
VALUES
    (1, 'Confraternização Universal', 'Ano Novo', '2026-01-01'),
    (2, 'Independência do Brasil', 'Feriado nacional', '2026-09-07'),
    (3, 'Aniversário de Brasília', 'Feriado local', '2026-04-21')
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   RELAÇÕES DOS FERIADOS
   ------------------------------------------------------------ */

INSERT INTO estado_feriado
    (id_feriado, id_estado)
VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (2, 2)
ON CONFLICT DO NOTHING;

INSERT INTO cidade_feriado
    (id_cidade, id_feriado)
VALUES
    (1, 3)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   SALAS
   ------------------------------------------------------------ */

INSERT INTO sala
    (id_sala, id_campus, codigo_sala, tipo_sala, capacidade_sala)
VALUES
    (1, 1, 'A101', 'Sala de aula', 50),
    (2, 1, 'A102', 'Sala de aula', 50),
    (3, 1, 'LAB01', 'Laboratório', 40),
    (4, 2, 'B101', 'Sala de aula', 50)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   CURSO
   ------------------------------------------------------------ */

INSERT INTO curso
    (id_curso, codigo_curso, nome_curso, grau_curso, ch_total_curso)
VALUES
    (1, 'CC', 'Ciência da Computação', 'Bacharelado', '3200')
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   CAMPUS_CURSO
   ------------------------------------------------------------ */

INSERT INTO campus_curso
    (id_campus, id_curso)
VALUES
    (1, 1),
    (2, 1)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   CURRÍCULO
   ------------------------------------------------------------ */

INSERT INTO curriculo
    (id_curriculo, id_curso, modulo_curriculo, ativo_curriculo,
     ano_inicio_curriculo, ano_previsto_fim_curriculo)
VALUES
    (1, 1, 'A', TRUE, 2026, 2030)
ON CONFLICT DO NOTHING;


/* ============================================================
   DISCIPLINAS
   ============================================================ */

INSERT INTO disciplina
    (id_disciplina,
     codigo_disciplina,
     nome_disciplina,
     ementa_disciplina,
     ch_teorica_disciplina,
     ch_pratica_disciplina,
     ch_total_disciplina)
VALUES
    (1, 'ALG101', 'Algoritmos', 'Fundamentos de algoritmos e lógica.', 40, 40, 80),
    (2, 'PRG101', 'Programação I', 'Introdução à programação.', 40, 40, 80),
    (3, 'PRG201', 'Programação II', 'Programação orientada a objetos.', 40, 40, 80),
    (4, 'BD101', 'Banco de Dados', 'Modelagem e SQL.', 40, 40, 80),
    (5, 'BD201', 'Banco de Dados II', 'Consultas avançadas e administração.', 40, 40, 80),
    (6, 'EST101', 'Estruturas de Dados', 'Estruturas lineares e árvores.', 40, 40, 80),
    (7, 'WEB101', 'Desenvolvimento Web', 'Desenvolvimento de aplicações web.', 30, 50, 80),
    (8, 'ENG101', 'Engenharia de Software', 'Processos e práticas de software.', 40, 40, 80),
    (9, 'IA101', 'Inteligência Artificial', 'Fundamentos de inteligência artificial.', 40, 40, 80),
    (10, 'RED101', 'Redes de Computadores', 'Fundamentos de redes.', 50, 30, 80),
    (11, 'SO101', 'Sistemas Operacionais', 'Processos, memória e sistemas.', 50, 30, 80),
    (12, 'SEG101', 'Segurança da Informação', 'Princípios de segurança.', 40, 40, 80)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   CURRÍCULO/DISCIPLINA
   ------------------------------------------------------------ */

INSERT INTO curriculo_disciplina
    (id_curriculo, id_disciplina,
     periodo_curriculo_disciplina,
     tipo_curriculo_disciplina)
VALUES
    (1, 1, '1', 'Obrigatória'),
    (1, 2, '1', 'Obrigatória'),
    (1, 3, '2', 'Obrigatória'),
    (1, 4, '2', 'Obrigatória'),
    (1, 5, '3', 'Obrigatória'),
    (1, 6, '3', 'Obrigatória'),
    (1, 7, '3', 'Obrigatória'),
    (1, 8, '4', 'Obrigatória'),
    (1, 9, '5', 'Obrigatória'),
    (1, 10, '4', 'Obrigatória'),
    (1, 11, '4', 'Obrigatória'),
    (1, 12, '5', 'Obrigatória')
ON CONFLICT DO NOTHING;


/* ============================================================
   ÁRVORE DE PRÉ-REQUISITOS

   Algoritmos
       |
   Programação I
       |
   Programação II
      /      \
 Estruturas  Banco de Dados
 de Dados       |
      |      Banco de Dados II
      |
 Inteligência Artificial

   Banco de Dados -> Desenvolvimento Web
   Programação II -> Desenvolvimento Web
   Engenharia de Software -> IA
   Redes -> Segurança
   Sistemas Operacionais -> Segurança
   ============================================================ */

INSERT INTO pre_requisito
    (id_disciplina, id_disciplina_requisito)
VALUES
    (2, 1),   -- Programação I <- Algoritmos
    (3, 2),   -- Programação II <- Programação I
    (6, 3),   -- Estruturas de Dados <- Programação II
    (5, 4),   -- Banco de Dados II <- Banco de Dados
    (7, 3),   -- Desenvolvimento Web <- Programação II
    (7, 4),   -- Desenvolvimento Web <- Banco de Dados
    (9, 6),   -- IA <- Estruturas de Dados
    (9, 8),   -- IA <- Engenharia de Software
    (12, 10), -- Segurança <- Redes
    (12, 11)  -- Segurança <- Sistemas Operacionais
ON CONFLICT DO NOTHING;


/* ============================================================
   PERÍODOS LETIVOS
   ============================================================ */

INSERT INTO periodo_letivo
    (id_periodo_letivo,
     data_inicio_periodo_letivo,
     data_fim_periodo_letivo,
     semestre_periodo_letivo,
     ano_periodo_letivo)
VALUES
    (1, '2026-02-02', '2026-06-30', 1, 2026),
    (2, '2026-08-03', '2026-12-18', 2, 2026)
ON CONFLICT DO NOTHING;


/* ============================================================
   PROFESSORES
   ============================================================ */

INSERT INTO professor
    (id_professor,
     matricula_professor,
     nome_professor,
     email_professor,
     titulacao_professor)
VALUES
    (1, 'P0001', 'Ana Oliveira', 'ana.oliveira@universidade.edu.br', 'Doutorado'),
    (2, 'P0002', 'Bruno Martins', 'bruno.martins@universidade.edu.br', 'Mestrado'),
    (3, 'P0003', 'Carla Souza', 'carla.souza@universidade.edu.br', 'Doutorado'),
    (4, 'P0004', 'Daniel Costa', 'daniel.costa@universidade.edu.br', 'Mestrado'),
    (5, 'P0005', 'Eduardo Lima', 'eduardo.lima@universidade.edu.br', 'Doutorado'),
    (6, 'P0006', 'Fernanda Alves', 'fernanda.alves@universidade.edu.br', 'Mestrado')
ON CONFLICT DO NOTHING;


/* ============================================================
   6 TURMAS
   ============================================================ */

INSERT INTO turma
    (id_turma,
     id_disciplina,
     periodo_letivo_id,
     codigo_turma,
     turno_turma,
     vagas_turmas)
VALUES
    (1, 1, 1, 'ALG-A', 'Matutino', 50),
    (2, 2, 1, 'PRG1-A', 'Matutino', 50),
    (3, 3, 1, 'PRG2-A', 'Vespertino', 50),
    (4, 4, 1, 'BD1-A', 'Vespertino', 50),
    (5, 6, 1, 'ED-A', 'Noturno', 50),
    (6, 7, 2, 'WEB-A', 'Noturno', 50)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   PROFESSORES DAS TURMAS
   ------------------------------------------------------------ */

INSERT INTO turma_professor
    (id_turma, id_professor)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6)
ON CONFLICT DO NOTHING;


/* ------------------------------------------------------------
   HORÁRIOS
   ------------------------------------------------------------ */

INSERT INTO turma_horario
    (id_turma_horario,
     id_turma,
     id_sala,
     faixa_turma_horario,
     dia_semana_turma_horario)
VALUES
    (1, 1, 1, '08:00-10:00', 2),
    (2, 2, 2, '10:00-12:00', 2),
    (3, 3, 3, '14:00-16:00', 3),
    (4, 4, 1, '08:00-10:00', 4),
    (5, 5, 2, '10:00-12:00', 4),
    (6, 6, 3, '19:00-21:00', 5)
ON CONFLICT DO NOTHING;


/* ============================================================
   100 ALUNOS
   ============================================================ */

INSERT INTO aluno
    (id_aluno,
     id_curriculo,
     matricula_aluno,
     nome_aluno,
     email_aluno,
     cpf_aluno,
     nascimento_aluno,
     ingresso_aluno,
     ativo_aluno)
SELECT
    gs,
    1,
    '2026' || LPAD(gs::TEXT, 6, '0'),
    'Aluno ' || LPAD(gs::TEXT, 3, '0'),
    'aluno' || gs || '@universidade.edu.br',
    '000.' ||
        LPAD(gs::TEXT, 3, '0') ||
        '.000-00',
    DATE '2000-01-01' + ((gs * 37) % 2000),
    DATE '2026-02-02',
    TRUE
FROM generate_series(1, 100) AS gs
ON CONFLICT DO NOTHING;


/* ============================================================
   300 MATRÍCULAS

   Cada um dos 100 alunos é matriculado nas 3 primeiras turmas.
   100 x 3 = 300 matrículas.

   IDs:
     turma 1 -> 1..100
     turma 2 -> 101..200
     turma 3 -> 201..300

   As turmas 4, 5 e 6 ficam disponíveis para outras consultas
   e demonstram a existência de turmas sem necessariamente
   possuir matrícula.
   ============================================================ */

INSERT INTO matricula
    (id_matricula,
     id_turma,
     id_aluno,
     data_matricula,
     status_matricula)
SELECT
    ((t.id_turma - 1) * 100) + a.id_aluno,
    t.id_turma,
    a.id_aluno,
    CASE
        WHEN t.id_turma = 6
            THEN TIMESTAMP '2026-08-03 10:00:00'
        ELSE
            TIMESTAMP '2026-02-02 10:00:00'
    END,
    TRUE
FROM generate_series(1, 100) AS a(id_aluno)
CROSS JOIN generate_series(1, 3) AS t(id_turma)
ON CONFLICT DO NOTHING;


/* ============================================================
   HISTÓRICO

   Gera notas diferentes por aluno para permitir análises
   estatísticas e funções de janela.

   Para criar situações diferentes:
   - alguns alunos têm média alta;
   - outros média intermediária;
   - outros média baixa.
   ============================================================ */

INSERT INTO historico
    (id_historico,
     id_matricula,
     nota_a1_historico,
     nota_a2_historico,
     nota_p3_historico,
     frequencia_historico,
     media_final_historico)
SELECT
    m.id_matricula,
    m.id_matricula,

    ROUND(
        (5.0 + ((m.id_aluno * 7 + m.id_turma * 3) % 51) / 10.0)::NUMERIC,
        2
    ),

    ROUND(
        (5.0 + ((m.id_aluno * 11 + m.id_turma * 5) % 51) / 10.0)::NUMERIC,
        2
    ),

    ROUND(
        (4.0 + ((m.id_aluno * 13 + m.id_turma * 2) % 61) / 10.0)::NUMERIC,
        2
    ),

    70 + ((m.id_aluno * 3 + m.id_turma * 7) % 31),

    ROUND(
        (
            (
                5.0 + ((m.id_aluno * 7 + m.id_turma * 3) % 51) / 10.0
            )
            +
            (
                5.0 + ((m.id_aluno * 11 + m.id_turma * 5) % 51) / 10.0
            )
        ) / 2,
        2
    )

FROM (
    SELECT
        m.id_matricula,
        m.id_aluno,
        t.id_turma
    FROM matricula m
    JOIN turma t
        ON t.id_turma = m.id_turma
    WHERE m.id_matricula BETWEEN 1 AND 300
) AS m
ON CONFLICT DO NOTHING;


/* ============================================================
   LOGS DE MATRÍCULA
   ============================================================ */

INSERT INTO log_matricula
    (id_log_matricula,
     id_matricula,
     acao_log_matricula,
     usuario_log_matricula,
     ocorrido_em_log_matricula,
     matricula_id_log_matricula,
     detalhe_log_matricula)
SELECT
    m.id_matricula,
    m.id_matricula,
    'CRIACAO',
    'sistema',
    m.data_matricula,
    m.id_matricula,
    jsonb_build_object(
        'origem', 'carga_inicial',
        'status', m.status_matricula
    )
FROM matricula m
WHERE m.id_matricula BETWEEN 1 AND 300
ON CONFLICT DO NOTHING;


/* ============================================================
   AJUSTE DAS SEQUÊNCIAS
   ------------------------------------------------------------
   Atualmente os IDs são inseridos manualmente.
   Se no futuro as tabelas forem alteradas para SERIAL/
   IDENTITY, isto evita que a próxima geração tente usar
   IDs já existentes.
   ============================================================ */

/*
   Não é necessário neste modelo porque os IDs são INT normais
   e controlados explicitamente.
*/


/* ============================================================
   CONSULTAS
   ============================================================ */


/* ============================================================
   CONSULTA 1 — SIMPLES
   Listar todos os alunos ativos.
   ============================================================ */

SELECT
    id_aluno,
    matricula_aluno,
    nome_aluno,
    email_aluno
FROM aluno
WHERE ativo_aluno = TRUE
ORDER BY nome_aluno;


/* ============================================================
   CONSULTA 2 — JUNÇÃO SIMPLES
   Listar as turmas juntamente com suas disciplinas.
   ============================================================ */

SELECT
    t.id_turma,
    t.codigo_turma,
    d.codigo_disciplina,
    d.nome_disciplina,
    t.turno_turma,
    t.vagas_turmas
FROM turma t
JOIN disciplina d
    ON d.id_disciplina = t.id_disciplina
ORDER BY t.id_turma;


/* ============================================================
   CONSULTA 3 — JUNÇÃO + AGREGAÇÃO
   Quantidade de alunos matriculados em cada turma.

   COUNT + GROUP BY.
   ============================================================ */

SELECT
    t.id_turma,
    t.codigo_turma,
    d.nome_disciplina,
    COUNT(m.id_matricula) AS quantidade_alunos
FROM turma t
JOIN disciplina d
    ON d.id_disciplina = t.id_disciplina
LEFT JOIN matricula m
    ON m.id_turma = t.id_turma
GROUP BY
    t.id_turma,
    t.codigo_turma,
    d.nome_disciplina
ORDER BY
    quantidade_alunos DESC;


/* ============================================================
   CONSULTA 4 — JUNÇÃO EXTERNA + AGREGAÇÃO
   ------------------------------------------------------------
   Mostra TODAS as turmas, inclusive aquelas que ainda não
   possuem alunos matriculados.

   A combinação LEFT JOIN + COUNT é importante:
   uma turma sem matrícula continua aparecendo com zero.
   ============================================================ */

SELECT
    t.id_turma,
    t.codigo_turma,
    d.nome_disciplina,
    COUNT(m.id_matricula) AS total_matriculados,
    t.vagas_turmas,
    t.vagas_turmas - COUNT(m.id_matricula) AS vagas_disponiveis
FROM turma t
JOIN disciplina d
    ON d.id_disciplina = t.id_disciplina
LEFT JOIN matricula m
    ON m.id_turma = t.id_turma
GROUP BY
    t.id_turma,
    t.codigo_turma,
    d.nome_disciplina,
    t.vagas_turmas
ORDER BY
    t.id_turma;


/* ============================================================
   CONSULTA 5 — AGREGAÇÃO + HAVING
   ------------------------------------------------------------
   Identifica alunos cuja média geral é maior ou igual a 7.
   ============================================================ */

SELECT
    a.id_aluno,
    a.nome_aluno,
    ROUND(AVG(h.media_final_historico), 2) AS media_geral,
    COUNT(h.id_historico) AS disciplinas_avaliadas
FROM aluno a
JOIN matricula m
    ON m.id_aluno = a.id_aluno
JOIN historico h
    ON h.id_matricula = m.id_matricula
GROUP BY
    a.id_aluno,
    a.nome_aluno
HAVING AVG(h.media_final_historico) >= 7
ORDER BY
    media_geral DESC;


/* ============================================================
   CONSULTA 6 — FUNÇÃO DE JANELA:
                  RANKING + PERCENTIL
   ------------------------------------------------------------
   Calcula:
   - média geral do aluno;
   - posição no ranking;
   - percentil da média.

   RANK() cria a classificação.
   PERCENT_RANK() calcula a posição relativa.
   ============================================================ */

WITH medias AS (
    SELECT
        a.id_aluno,
        a.nome_aluno,
        AVG(h.media_final_historico) AS media_geral
    FROM aluno a
    JOIN matricula m
        ON m.id_aluno = a.id_aluno
    JOIN historico h
        ON h.id_matricula = m.id_matricula
    GROUP BY
        a.id_aluno,
        a.nome_aluno
)
SELECT
    id_aluno,
    nome_aluno,
    ROUND(media_geral, 2) AS media_geral,

    RANK() OVER (
        ORDER BY media_geral DESC
    ) AS ranking,

    ROUND(
        (
            PERCENT_RANK() OVER (
                ORDER BY media_geral
            )
        )::NUMERIC,
        4
    ) AS percentil
FROM medias
ORDER BY
    ranking;


/* ============================================================
   CONSULTA 7 — FUNÇÃO DE JANELA LAG()
   ------------------------------------------------------------
   Analisa a evolução do rendimento de cada aluno entre as
   disciplinas/turmas cursadas.

   LAG() recupera a média da matrícula anterior do mesmo aluno.
   ============================================================ */

WITH rendimento AS (
    SELECT
        a.id_aluno,
        a.nome_aluno,
        m.id_matricula,
        t.id_turma,
        d.nome_disciplina,
        h.media_final_historico,

        LAG(h.media_final_historico) OVER (
            PARTITION BY a.id_aluno
            ORDER BY m.id_matricula
        ) AS media_anterior

    FROM aluno a
    JOIN matricula m
        ON m.id_aluno = a.id_aluno
    JOIN turma t
        ON t.id_turma = m.id_turma
    JOIN disciplina d
        ON d.id_disciplina = t.id_disciplina
    JOIN historico h
        ON h.id_matricula = m.id_matricula
)
SELECT
    id_aluno,
    nome_aluno,
    id_matricula,
    nome_disciplina,
    ROUND(media_final_historico, 2) AS media_atual,
    ROUND(media_anterior, 2) AS media_anterior,

    CASE
        WHEN media_anterior IS NULL THEN NULL
        ELSE ROUND(
            (media_final_historico - media_anterior)::NUMERIC,
            2
        )
    END AS variacao

FROM rendimento
ORDER BY
    id_aluno,
    id_matricula;


/* ============================================================
   CONSULTA 8 — RECURSIVA:
                  ÁRVORE DE PRÉ-REQUISITOS
   ------------------------------------------------------------
   A CTE recursiva começa nas disciplinas que não possuem
   pré-requisitos e percorre a árvore até seus descendentes.

   "nivel" representa a profundidade na árvore.
   ============================================================ */

WITH RECURSIVE arvore AS (

    /* Raízes: disciplinas sem pré-requisito */
    SELECT
        d.id_disciplina,
        d.nome_disciplina,
        NULL::INT AS id_pai,
        0 AS nivel,
        d.nome_disciplina::TEXT AS caminho
    FROM disciplina d
    WHERE NOT EXISTS (
        SELECT 1
        FROM pre_requisito p
        WHERE p.id_disciplina = d.id_disciplina
    )

    UNION ALL

    /* Descendentes */
    SELECT
        filho.id_disciplina,
        filho.nome_disciplina,
        a.id_disciplina AS id_pai,
        a.nivel + 1,
        a.caminho || ' -> ' || filho.nome_disciplina
    FROM arvore a
    JOIN pre_requisito p
        ON p.id_disciplina_requisito = a.id_disciplina
    JOIN disciplina filho
        ON filho.id_disciplina = p.id_disciplina
)

SELECT
    nivel,
    REPEAT('    ', nivel) || nome_disciplina AS arvore,
    caminho
FROM arvore
ORDER BY
    caminho;


/* ============================================================
   CONSULTA 9 — RECURSIVA:
                  DISCIPLINAS QUE UM ALUNO JÁ PODE CURSAR
   ------------------------------------------------------------
   Aluno escolhido:
       id_aluno = 1

   A consulta verifica:

   1. disciplinas já aprovadas;
   2. pré-requisitos dessas disciplinas;
   3. toda a cadeia recursiva de pré-requisitos;
   4. elimina disciplinas cujo pré-requisito ainda não foi
      concluído;
   5. elimina disciplinas que o aluno já cursou.

   Consideramos aprovação:
       média >= 6
       frequência >= 75
   ============================================================ */

WITH RECURSIVE

/* ------------------------------------------------------------
   Disciplinas já concluídas pelo aluno.
   ------------------------------------------------------------ */

concluidas AS (
    SELECT DISTINCT
        t.id_disciplina
    FROM matricula m
    JOIN turma t
        ON t.id_turma = m.id_turma
    JOIN historico h
        ON h.id_matricula = m.id_matricula
    WHERE m.id_aluno = 1
      AND h.media_final_historico >= 6
      AND h.frequencia_historico >= 75
),

/* ------------------------------------------------------------
   Todos os pré-requisitos, incluindo os indiretos.
   ------------------------------------------------------------ */

cadeia AS (

    SELECT
        p.id_disciplina,
        p.id_disciplina_requisito
    FROM pre_requisito p

    UNION

    SELECT
        c.id_disciplina,
        p.id_disciplina_requisito
    FROM cadeia c
    JOIN pre_requisito p
        ON p.id_disciplina = c.id_disciplina_requisito
),

/* ------------------------------------------------------------
   Candidatas = disciplinas do currículo que o aluno ainda
   não concluiu.
   ------------------------------------------------------------ */

candidatas AS (
    SELECT
        cd.id_disciplina
    FROM curriculo_disciplina cd
    WHERE cd.id_curriculo = (
        SELECT id_curriculo
        FROM aluno
        WHERE id_aluno = 1
    )
    AND cd.id_disciplina NOT IN (
        SELECT id_disciplina
        FROM concluidas
    )
),

/* ------------------------------------------------------------
   Conta quantos pré-requisitos totais cada disciplina possui.
   ------------------------------------------------------------ */

requisitos AS (
    SELECT
        c.id_disciplina,
        COUNT(*) AS total_requisitos
    FROM cadeia c
    GROUP BY
        c.id_disciplina
),

/* ------------------------------------------------------------
   Conta quantos pré-requisitos já foram concluídos.
   ------------------------------------------------------------ */

requisitos_concluidos AS (
    SELECT
        c.id_disciplina,
        COUNT(*) AS requisitos_ok
    FROM cadeia c
    JOIN concluidas co
        ON co.id_disciplina = c.id_disciplina_requisito
    GROUP BY
        c.id_disciplina
)

SELECT
    d.id_disciplina,
    d.codigo_disciplina,
    d.nome_disciplina,
    COALESCE(r.total_requisitos, 0) AS total_requisitos,
    COALESCE(rc.requisitos_ok, 0) AS requisitos_concluidos
FROM candidatas c
JOIN disciplina d
    ON d.id_disciplina = c.id_disciplina
LEFT JOIN requisitos r
    ON r.id_disciplina = c.id_disciplina
LEFT JOIN requisitos_concluidos rc
    ON rc.id_disciplina = c.id_disciplina
WHERE
    COALESCE(r.total_requisitos, 0)
    =
    COALESCE(rc.requisitos_ok, 0)
ORDER BY
    d.id_disciplina;


/* ============================================================
   CONSULTA 10 — CONSULTA COMPLEXA
   ------------------------------------------------------------
   Relatório acadêmico completo:

   - aluno;
   - curso;
   - quantidade de disciplinas;
   - média geral;
   - ranking;
   - percentil;
   - média anterior;
   - evolução;
   - situação acadêmica.

   Combina:
   JOIN
   LEFT JOIN
   GROUP BY
   CTE
   funções de janela
   RANK
   PERCENT_RANK
   LAG
   CASE
   ============================================================ */

WITH rendimento AS (

    SELECT
        a.id_aluno,
        a.nome_aluno,
        c.nome_curso,
        m.id_matricula,
        h.media_final_historico,

        AVG(h.media_final_historico) OVER (
            PARTITION BY a.id_aluno
        ) AS media_geral,

        RANK() OVER (
            ORDER BY h.media_final_historico DESC
        ) AS ranking_nota,

        PERCENT_RANK() OVER (
            ORDER BY h.media_final_historico
        ) AS percentil_nota,

        LAG(h.media_final_historico) OVER (
            PARTITION BY a.id_aluno
            ORDER BY m.id_matricula
        ) AS nota_anterior

    FROM aluno a

    JOIN curriculo cr
        ON cr.id_curriculo = a.id_curriculo

    JOIN curso c
        ON c.id_curso = cr.id_curso

    JOIN matricula m
        ON m.id_aluno = a.id_aluno

    JOIN historico h
        ON h.id_matricula = m.id_matricula
),

resumo AS (

    SELECT
        id_aluno,
        nome_aluno,
        nome_curso,

        COUNT(*) AS disciplinas_avaliadas,

        ROUND(
            AVG(media_final_historico),
            2
        ) AS media_aluno,

        MAX(ranking_nota) AS maior_ranking_individual,

        ROUND(
            AVG(percentil_nota)::NUMERIC,
            4
        ) AS percentil_medio,

        ROUND(
            AVG(
                CASE
                    WHEN nota_anterior IS NOT NULL
                    THEN media_final_historico - nota_anterior
                END
            )::NUMERIC,
            2
        ) AS evolucao_media

    FROM rendimento

    GROUP BY
        id_aluno,
        nome_aluno,
        nome_curso
)

SELECT
    id_aluno,
    nome_aluno,
    nome_curso,
    disciplinas_avaliadas,
    media_aluno,
    maior_ranking_individual,
    percentil_medio,
    evolucao_media,

    CASE
        WHEN media_aluno >= 8
            THEN 'Excelente'
        WHEN media_aluno >= 6
            THEN 'Aprovado'
        WHEN media_aluno >= 4
            THEN 'Recuperação'
        ELSE
            'Reprovado'
    END AS situacao

FROM resumo

ORDER BY
    media_aluno DESC,
    nome_aluno;