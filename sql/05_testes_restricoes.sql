-- Testes negativos da Tarefa 3. Executar somente em banco descartavel.
-- Cada bloco deve rejeitar o INSERT indicado e terminar com ROLLBACK.

-- 1. Esperado: violacao da PK pk_uf.
BEGIN;
INSERT INTO uf (sigla) VALUES ('ZZ');
INSERT INTO uf (sigla) VALUES ('ZZ');
ROLLBACK;

-- 2. Esperado: violacao da FK fk_municipio_uf.
BEGIN;
INSERT INTO municipio (uf_sigla, nome) VALUES ('ZZ', 'Municipio sem UF');
ROLLBACK;

-- 3. Esperado: violacao de NOT NULL em municipio.nome.
BEGIN;
INSERT INTO uf (sigla) VALUES ('ZZ');
INSERT INTO municipio (uf_sigla, nome) VALUES ('ZZ', NULL);
ROLLBACK;

-- 4. Esperado: violacao de uq_municipio_uf_nome.
BEGIN;
INSERT INTO uf (sigla) VALUES ('ZZ');
INSERT INTO municipio (uf_sigla, nome) VALUES ('ZZ', 'Municipio repetido');
INSERT INTO municipio (uf_sigla, nome) VALUES ('ZZ', 'Municipio repetido');
ROLLBACK;

-- 5. Esperado: violacao de ck_barragem_latitude.
BEGIN;
INSERT INTO uf (sigla) VALUES ('ZZ');
INSERT INTO municipio (uf_sigla, nome) VALUES ('ZZ', 'Municipio de teste');
INSERT INTO empreendedor (nome) VALUES ('Empreendedor de teste');
INSERT INTO regiao_hidrografica (nome) VALUES ('Regiao de teste');
INSERT INTO barragem (
    cod_snisb, cod_fiscalizador, nome, altura_fundacao_m,
    capacidade_reservatorio_texto, data_cadastro, uso_principal,
    latitude, longitude, regulada_pnsb, id_empreendedor, id_municipio,
    orgao_fiscalizador, numero_autorizacao, id_regiao_hidrografica,
    curso_dagua, possui_plano_seguranca, possui_revisao_periodica,
    categoria_risco, dano_potencial_associado, barragem_autuada,
    completude_cadastro
)
SELECT
    'TESTE-CHECK', 'TESTE-CHECK', 'Barragem de teste', 1,
    'sem unidade confirmada', DATE '2020-01-01', 'Hidroeletrica',
    91, 0, TRUE, e.id_empreendedor, m.id_municipio,
    'Orgao de teste', 'AUT-1', r.id_regiao_hidrografica,
    'Curso de teste', FALSE, FALSE, 'Baixo', 'Baixo', FALSE, 'boa'
FROM empreendedor e
CROSS JOIN municipio m
CROSS JOIN regiao_hidrografica r
WHERE e.nome = 'Empreendedor de teste'
  AND m.nome = 'Municipio de teste'
  AND r.nome = 'Regiao de teste';
ROLLBACK;
