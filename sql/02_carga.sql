CREATE UNLOGGED TABLE staging_barragens (
    cod_snisb VARCHAR,
    cod_fiscalizador VARCHAR,
    nome VARCHAR,
    altura_fundacao_m VARCHAR,
    altura_terreno_m VARCHAR,
    capacidade_reservatorio VARCHAR,
    data_cadastro VARCHAR,
    tipo_material VARCHAR,
    uso_principal VARCHAR,
    latitude VARCHAR,
    longitude VARCHAR,
    regulada_pnsb VARCHAR,
    empreendedor VARCHAR,
    uf VARCHAR,
    municipio VARCHAR,
    fase_vida VARCHAR,
    orgao_fiscalizador VARCHAR,
    numero_autorizacao VARCHAR,
    data_autorizacao VARCHAR,
    regiao_hidrografica VARCHAR,
    cod_trecho_curso_dagua VARCHAR,
    curso_dagua VARCHAR,
    dominio_curso_dagua VARCHAR,
    comite_federal VARCHAR,
    comite_estadual VARCHAR,
    unidade_gestao VARCHAR,
    possui_pae VARCHAR,
    possui_plano_seguranca VARCHAR,
    possui_revisao_periodica VARCHAR,
    categoria_risco VARCHAR,
    dano_potencial_associado VARCHAR,
    barragem_autuada VARCHAR,
    completude_cadastro VARCHAR
);

COPY staging_barragens 
FROM '/tmp/ana_barragens_hidreletricas (1).csv' 
DELIMITER ',' 
CSV HEADER;

-- 1. Empreendedores
INSERT INTO empreendedor (nome)
SELECT DISTINCT TRIM(empreendedor) FROM staging_barragens WHERE empreendedor IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 2. Municípios (Agora inclui a UF)
INSERT INTO municipio (nome, uf)
SELECT DISTINCT TRIM(INITCAP(municipio)), TRIM(UPPER(uf)) FROM staging_barragens 
WHERE municipio IS NOT NULL AND uf IS NOT NULL
ON CONFLICT (nome, uf) DO NOTHING;

-- 3. Órgãos Fiscalizadores
INSERT INTO orgao_fiscalizador (nome)
SELECT DISTINCT TRIM(orgao_fiscalizador) FROM staging_barragens WHERE orgao_fiscalizador IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 4. Tipos de Material
INSERT INTO tipo_material (nome)
SELECT DISTINCT TRIM(tipo_material) FROM staging_barragens WHERE tipo_material IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 5. Fases da Vida
INSERT INTO fase_vida (nome)
SELECT DISTINCT TRIM(fase_vida) FROM staging_barragens WHERE fase_vida IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 6. Regiões Hidrográficas
INSERT INTO regiao_hidrografica (nome)
SELECT DISTINCT TRIM(regiao_hidrografica) FROM staging_barragens WHERE regiao_hidrografica IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 7. Cursos d'água
INSERT INTO curso_dagua (nome)
SELECT DISTINCT TRIM(curso_dagua) FROM staging_barragens WHERE curso_dagua IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 8. Comitês Federais
INSERT INTO comite_federal (nome)
SELECT DISTINCT TRIM(comite_federal) FROM staging_barragens WHERE comite_federal IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 9. Comitês Estaduais
INSERT INTO comite_estadual (nome)
SELECT DISTINCT TRIM(comite_estadual) FROM staging_barragens WHERE comite_estadual IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

-- 10. Unidades de Gestão
INSERT INTO unidade_gestao (nome)
SELECT DISTINCT TRIM(unidade_gestao) FROM staging_barragens WHERE unidade_gestao IS NOT NULL
ON CONFLICT (nome) DO NOTHING;

INSERT INTO barragem (
    cod_snisb, cod_fiscalizador, nome, altura_fundacao_m, altura_terreno_m, 
    capacidade_reservatorio, data_cadastro, tipo_material, uso_principal, 
    latitude, longitude, regulada_pnsb, empreendedor, municipio, fase_vida, 
    orgao_fiscalizador, numero_autorizacao, data_autorizacao, regiao_hidrografica, 
    cod_trecho_curso_dagua, curso_dagua, dominio_curso_dagua, comite_federal, 
    comite_estadual, unidade_gestao, possui_pae, possui_plano_seguranca, 
    possui_revisao_periodica, categoria_risco, dano_potencial_associado, 
    barragem_autuada, completude_cadastro
)
SELECT 
    TRIM(s.cod_snisb),
    TRIM(s.cod_fiscalizador),
    TRIM(s.nome),
    CAST(NULLIF(TRIM(s.altura_fundacao_m), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.altura_terreno_m), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.capacidade_reservatorio), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.data_cadastro), '') AS DATE),
    tm.id_tipo_material,
    COALESCE(TRIM(s.uso_principal), 'Não Informado'),
    CAST(NULLIF(TRIM(s.latitude), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.longitude), '') AS NUMERIC),
    CAST(NULLIF(TRIM(s.regulada_pnsb), '') AS BOOLEAN),
    e.id_empreendedor,
    m.id_municipio,
    fv.id_fase_vida,
    ofisc.id_orgao_fiscalizador,
    COALESCE(TRIM(s.numero_autorizacao), 'S/N'),
    CAST(NULLIF(TRIM(s.data_autorizacao), '') AS DATE),
    rh.id_regiao_hidrografica,
    TRIM(s.cod_trecho_curso_dagua),
    cd.id_curso_dagua,
    TRIM(s.dominio_curso_dagua),
    cf.id_comite_federal,
    ce.id_comite_estadual,
    ug.id_unidade_gestao,
    CAST(NULLIF(TRIM(s.possui_pae), '') AS BOOLEAN),
    CAST(NULLIF(TRIM(s.possui_plano_seguranca), '') AS BOOLEAN),
    CAST(NULLIF(TRIM(s.possui_revisao_periodica), '') AS BOOLEAN),
    TRIM(s.categoria_risco),
    TRIM(s.dano_potencial_associado),
    CAST(NULLIF(TRIM(s.barragem_autuada), '') AS BOOLEAN),
    TRIM(s.completude_cadastro)
FROM staging_barragens s
LEFT JOIN tipo_material tm ON tm.nome = TRIM(s.tipo_material)
LEFT JOIN empreendedor e ON e.nome = TRIM(s.empreendedor)
LEFT JOIN municipio m ON m.nome = TRIM(INITCAP(s.municipio)) AND m.uf = TRIM(UPPER(s.uf))
LEFT JOIN fase_vida fv ON fv.nome = TRIM(s.fase_vida)
LEFT JOIN orgao_fiscalizador ofisc ON ofisc.nome = TRIM(s.orgao_fiscalizador)
LEFT JOIN regiao_hidrografica rh ON rh.nome = TRIM(s.regiao_hidrografica)
LEFT JOIN curso_dagua cd ON cd.nome = TRIM(s.curso_dagua)
LEFT JOIN comite_federal cf ON cf.nome = TRIM(s.comite_federal)
LEFT JOIN comite_estadual ce ON ce.nome = TRIM(s.comite_estadual)
LEFT JOIN unidade_gestao ug ON ug.nome = TRIM(s.unidade_gestao)
WHERE s.cod_snisb IS NOT NULL
ON CONFLICT (cod_snisb) DO NOTHING;

DROP TABLE staging_barragens;