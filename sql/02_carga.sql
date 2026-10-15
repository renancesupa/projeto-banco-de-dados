CREATE UNLOGGED TABLE staging_barragens (
    cod_snisb TEXT,
    cod_fiscalizador TEXT,
    nome TEXT,
    altura_fundacao_m TEXT,
    altura_terreno_m TEXT,
    capacidade_reservatorio TEXT,
    data_cadastro TEXT,
    tipo_material TEXT,
    uso_principal TEXT,
    latitude TEXT,
    longitude TEXT,
    regulada_pnsb TEXT,
    empreendedor TEXT,
    uf TEXT,
    municipio TEXT,
    fase_vida TEXT,
    orgao_fiscalizador TEXT,
    numero_autorizacao TEXT,
    data_autorizacao TEXT,
    regiao_hidrografica TEXT,
    cod_trecho_curso_dagua TEXT,
    curso_dagua TEXT,
    dominio_curso_dagua TEXT,
    comite_federal TEXT,
    comite_estadual TEXT,
    unidade_gestao TEXT,
    possui_pae TEXT,
    possui_plano_seguranca TEXT,
    possui_revisao_periodica TEXT,
    categoria_risco TEXT,
    dano_potencial_associado TEXT,
    barragem_autuada TEXT,
    completude_cadastro TEXT
);

COPY staging_barragens 
FROM '/tmp/ana_barragens_hidreletricas (1).csv' 
DELIMITER ',' 
CSV HEADER;

-- 1. Inserir Estados (UF)
INSERT INTO uf (sigla)
SELECT DISTINCT TRIM(UPPER(uf)) FROM staging_barragens WHERE uf IS NOT NULL
ON CONFLICT (sigla) DO NOTHING;

-- 2. Inserir Municípios
INSERT INTO municipio (uf_sigla, nome)
SELECT DISTINCT TRIM(UPPER(uf)), TRIM(INITCAP(municipio)) FROM staging_barragens 
WHERE uf IS NOT NULL AND municipio IS NOT NULL
ON CONFLICT (uf_sigla, nome) DO NOTHING;

-- 3. Inserir Empreendedores
INSERT INTO empreendedor (nome)
SELECT DISTINCT TRIM(empreendedor) FROM staging_barragens WHERE empreendedor IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 4. Inserir Regiões Hidrográficas
INSERT INTO regiao_hidrografica (nome)
SELECT DISTINCT TRIM(regiao_hidrografica) FROM staging_barragens WHERE regiao_hidrografica IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 5. Inserir Comitês Federais
INSERT INTO comite_federal (nome)
SELECT DISTINCT TRIM(comite_federal) FROM staging_barragens WHERE comite_federal IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 6. Inserir Comitês Estaduais
INSERT INTO comite_estadual (nome)
SELECT DISTINCT TRIM(comite_estadual) FROM staging_barragens WHERE comite_estadual IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 7. Inserir Unidades de Gestão
INSERT INTO unidade_gestao (nome)
SELECT DISTINCT TRIM(unidade_gestao) FROM staging_barragens WHERE unidade_gestao IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

--8. populandop a tabela principal
INSERT INTO barragem (
    cod_snisb, cod_fiscalizador, nome, altura_fundacao_m, altura_terreno_m, 
    capacidade_reservatorio_texto, capacidade_reservatorio_padronizada, data_cadastro, 
    tipo_material, uso_principal, latitude, longitude, regulada_pnsb, 
    id_empreendedor, id_municipio, fase_vida, orgao_fiscalizador, 
    numero_autorizacao, data_autorizacao, id_regiao_hidrografica, 
    cod_trecho_curso_dagua, curso_dagua, dominio_curso_dagua, id_comite_federal, 
    id_comite_estadual, id_unidade_gestao, possui_pae, possui_plano_seguranca, 
    possui_revisao_periodica, categoria_risco, dano_potencial_associado, 
    barragem_autuada, completude_cadastro
)
SELECT 
    TRIM(s.cod_snisb),
    TRIM(s.cod_fiscalizador),
    TRIM(s.nome),
    CAST(NULLIF(TRIM(s.altura_fundacao_m), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.altura_terreno_m), '') AS NUMERIC),
    COALESCE(TRIM(s.capacidade_reservatorio), 'Não Informado'), -- Texto obrigatório
    CAST(NULLIF(TRIM(s.capacidade_reservatorio), '') AS NUMERIC), -- Número padronizado
    CAST(NULLIF(TRIM(s.data_cadastro), '') AS DATE),
    TRIM(s.tipo_material),
    COALESCE(TRIM(s.uso_principal), 'Não Informado'),
    CAST(NULLIF(TRIM(s.latitude), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.longitude), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.regulada_pnsb), '') AS BOOLEAN),
    e.id_empreendedor,
    m.id_municipio,
    TRIM(s.fase_vida),
    COALESCE(TRIM(s.orgao_fiscalizador), 'Não Informado'),
    COALESCE(TRIM(s.numero_autorizacao), 'Sem Autorização'),
    CAST(NULLIF(TRIM(s.data_autorizacao), '') AS DATE),
    r.id_regiao_hidrografica,
    TRIM(s.cod_trecho_curso_dagua),
    COALESCE(TRIM(s.curso_dagua), 'Não Informado'),
    TRIM(s.dominio_curso_dagua),
    cf.id_comite_federal,
    ce.id_comite_estadual,
    ug.id_unidade_gestao,
    CAST(NULLIF(TRIM(s.possui_pae), '') AS BOOLEAN),
    CAST(NULLIF(TRIM(s.possui_plano_seguranca), '') AS BOOLEAN),
    CAST(NULLIF(TRIM(s.possui_revisao_periodica), '') AS BOOLEAN),
    COALESCE(TRIM(s.categoria_risco), 'Não Informado'),
    COALESCE(TRIM(s.dano_potencial_associado), 'Não Informado'),
    CAST(NULLIF(TRIM(s.barragem_autuada), '') AS BOOLEAN),
    COALESCE(TRIM(s.completude_cadastro), 'Não Informado')
FROM staging_barragens s
LEFT JOIN uf u ON u.sigla = TRIM(UPPER(s.uf))
LEFT JOIN municipio m ON m.uf_sigla = u.sigla AND m.nome = TRIM(INITCAP(s.municipio))
LEFT JOIN empreendedor e ON e.nome = TRIM(s.empreendedor)
LEFT JOIN regiao_hidrografica r ON r.nome = TRIM(s.regiao_hidrografica)
LEFT JOIN comite_federal cf ON cf.nome = TRIM(s.comite_federal)
LEFT JOIN comite_estadual ce ON ce.nome = TRIM(s.comite_estadual)
LEFT JOIN unidade_gestao ug ON ug.nome = TRIM(s.unidade_gestao)
WHERE s.cod_snisb IS NOT NULL
ON CONFLICT (cod_snisb) DO NOTHING;

DROP TABLE staging_barragens;