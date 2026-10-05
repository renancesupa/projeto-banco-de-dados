-- Comparar esperado/encontrado. A execução é composta apenas por SELECTs simples.
SELECT 'barragem' AS verificacao, 887 AS esperado, COUNT(*) AS encontrado FROM barragem
UNION ALL SELECT 'registro_origem', 887, COUNT(*) FROM registro_origem
UNION ALL SELECT 'campo_origem', 33, COUNT(*) FROM campo_origem
UNION ALL SELECT 'valor_origem', 29271, COUNT(*) FROM valor_origem;

-- Duplicidades: cada total esperado é zero para toda PK e UNIQUE do DDL.
SELECT 'uf.sigla' AS verificacao, 0 AS duplicidades,
       COUNT(*) AS grupos_duplicados
FROM (SELECT sigla FROM uf GROUP BY sigla HAVING COUNT(*) > 1) d
UNION ALL SELECT 'municipio.id_municipio', 0, COUNT(*)
FROM (SELECT id_municipio FROM municipio GROUP BY id_municipio HAVING COUNT(*) > 1) d
UNION ALL SELECT 'municipio.uf_sigla,nome', 0, COUNT(*)
FROM (SELECT uf_sigla, nome FROM municipio GROUP BY uf_sigla, nome HAVING COUNT(*) > 1) d
UNION ALL SELECT 'empreendedor.id_empreendedor', 0, COUNT(*)
FROM (SELECT id_empreendedor FROM empreendedor GROUP BY id_empreendedor HAVING COUNT(*) > 1) d
UNION ALL SELECT 'empreendedor.nome', 0, COUNT(*)
FROM (SELECT nome FROM empreendedor GROUP BY nome HAVING COUNT(*) > 1) d
UNION ALL SELECT 'regiao_hidrografica.id_regiao_hidrografica', 0, COUNT(*)
FROM (
    SELECT id_regiao_hidrografica FROM regiao_hidrografica
    GROUP BY id_regiao_hidrografica HAVING COUNT(*) > 1
) d
UNION ALL SELECT 'regiao_hidrografica.nome', 0, COUNT(*)
FROM (SELECT nome FROM regiao_hidrografica GROUP BY nome HAVING COUNT(*) > 1) d
UNION ALL SELECT 'comite_federal.id_comite_federal', 0, COUNT(*)
FROM (SELECT id_comite_federal FROM comite_federal GROUP BY id_comite_federal HAVING COUNT(*) > 1) d
UNION ALL SELECT 'comite_federal.nome', 0, COUNT(*)
FROM (SELECT nome FROM comite_federal GROUP BY nome HAVING COUNT(*) > 1) d
UNION ALL SELECT 'comite_estadual.id_comite_estadual', 0, COUNT(*)
FROM (SELECT id_comite_estadual FROM comite_estadual GROUP BY id_comite_estadual HAVING COUNT(*) > 1) d
UNION ALL SELECT 'comite_estadual.nome', 0, COUNT(*)
FROM (SELECT nome FROM comite_estadual GROUP BY nome HAVING COUNT(*) > 1) d
UNION ALL SELECT 'unidade_gestao.id_unidade_gestao', 0, COUNT(*)
FROM (SELECT id_unidade_gestao FROM unidade_gestao GROUP BY id_unidade_gestao HAVING COUNT(*) > 1) d
UNION ALL SELECT 'unidade_gestao.nome', 0, COUNT(*)
FROM (SELECT nome FROM unidade_gestao GROUP BY nome HAVING COUNT(*) > 1) d
UNION ALL SELECT 'barragem.cod_snisb', 0, COUNT(*)
FROM (SELECT cod_snisb FROM barragem GROUP BY cod_snisb HAVING COUNT(*) > 1) d
UNION ALL SELECT 'registro_origem.id_registro', 0, COUNT(*)
FROM (SELECT id_registro FROM registro_origem GROUP BY id_registro HAVING COUNT(*) > 1) d
UNION ALL SELECT 'registro_origem.numero_linha', 0, COUNT(*)
FROM (SELECT numero_linha FROM registro_origem GROUP BY numero_linha HAVING COUNT(*) > 1) d
UNION ALL SELECT 'registro_origem.cod_snisb', 0, COUNT(*)
FROM (SELECT cod_snisb FROM registro_origem GROUP BY cod_snisb HAVING COUNT(*) > 1) d
UNION ALL SELECT 'campo_origem.ordem_coluna', 0, COUNT(*)
FROM (SELECT ordem_coluna FROM campo_origem GROUP BY ordem_coluna HAVING COUNT(*) > 1) d
UNION ALL SELECT 'campo_origem.nome_original', 0, COUNT(*)
FROM (SELECT nome_original FROM campo_origem GROUP BY nome_original HAVING COUNT(*) > 1) d
UNION ALL SELECT 'valor_origem.chave_composta', 0, COUNT(*)
FROM (
    SELECT id_registro, ordem_coluna FROM valor_origem
    GROUP BY id_registro, ordem_coluna HAVING COUNT(*) > 1
) d;

-- Órfãos por FK analítica e de proveniência; cada total esperado é zero.
SELECT 'municipio.uf_sigla -> uf.sigla' AS verificacao, 0 AS orfaos,
       COUNT(*) AS encontrados
FROM municipio m LEFT JOIN uf u ON u.sigla = m.uf_sigla
WHERE u.sigla IS NULL
UNION ALL SELECT 'barragem.id_empreendedor -> empreendedor', 0,
       COUNT(*) FROM barragem b
       LEFT JOIN empreendedor e USING (id_empreendedor)
       WHERE e.id_empreendedor IS NULL
UNION ALL SELECT 'barragem.id_municipio -> municipio', 0,
       COUNT(*) FROM barragem b LEFT JOIN municipio m USING (id_municipio)
       WHERE m.id_municipio IS NULL
UNION ALL SELECT 'barragem.id_regiao_hidrografica -> regiao_hidrografica', 0,
       COUNT(*) FROM barragem b
       LEFT JOIN regiao_hidrografica r USING (id_regiao_hidrografica)
       WHERE r.id_regiao_hidrografica IS NULL
UNION ALL SELECT 'barragem.id_comite_federal -> comite_federal', 0,
       COUNT(*) FROM barragem b LEFT JOIN comite_federal c USING (id_comite_federal)
       WHERE b.id_comite_federal IS NOT NULL AND c.id_comite_federal IS NULL
UNION ALL SELECT 'barragem.id_comite_estadual -> comite_estadual', 0,
       COUNT(*) FROM barragem b LEFT JOIN comite_estadual c USING (id_comite_estadual)
       WHERE b.id_comite_estadual IS NOT NULL AND c.id_comite_estadual IS NULL
UNION ALL SELECT 'barragem.id_unidade_gestao -> unidade_gestao', 0,
       COUNT(*) FROM barragem b LEFT JOIN unidade_gestao u USING (id_unidade_gestao)
       WHERE b.id_unidade_gestao IS NOT NULL AND u.id_unidade_gestao IS NULL
UNION ALL SELECT 'registro_origem.cod_snisb -> barragem', 0,
       COUNT(*) FROM registro_origem ro LEFT JOIN barragem b USING (cod_snisb)
       WHERE b.cod_snisb IS NULL
UNION ALL SELECT 'valor_origem.id_registro -> registro_origem', 0,
       COUNT(*) FROM valor_origem vo LEFT JOIN registro_origem ro USING (id_registro)
       WHERE ro.id_registro IS NULL
UNION ALL SELECT 'valor_origem.ordem_coluna -> campo_origem', 0,
       COUNT(*) FROM valor_origem vo LEFT JOIN campo_origem co USING (ordem_coluna)
       WHERE co.ordem_coluna IS NULL;

-- A distribuição deve ter exatamente 33 valores para cada registro de origem,
-- inclusive registros sem células. O total de divergências esperado é zero.
SELECT 0 AS divergencias_esperadas, COUNT(*) AS divergencias_encontradas
FROM (
    SELECT ro.id_registro
    FROM registro_origem ro
    LEFT JOIN valor_origem vo USING (id_registro)
    GROUP BY ro.id_registro
    HAVING COUNT(vo.id_registro) <> 33
) registros_incompletos;

-- Perfil por coluna: rótulos distintos excluem vazios.
SELECT co.ordem_coluna, co.nome_original,
       COUNT(*) FILTER (WHERE vo.valor_original = '') AS vazios,
       COUNT(DISTINCT NULLIF(vo.valor_original, '')) AS distintos_nao_vazios,
       MIN(vo.valor_original) AS menor_valor, MAX(vo.valor_original) AS maior_valor
FROM campo_origem co JOIN valor_origem vo USING (ordem_coluna)
GROUP BY co.ordem_coluna, co.nome_original
ORDER BY co.ordem_coluna;

-- Constantes: uma única representação literal em todas as linhas.
SELECT co.nome_original, MIN(vo.valor_original) AS valor_constante,
       COUNT(*) AS ocorrencias
FROM campo_origem co JOIN valor_origem vo USING (ordem_coluna)
GROUP BY co.ordem_coluna, co.nome_original
HAVING COUNT(DISTINCT vo.valor_original) = 1
ORDER BY co.ordem_coluna;
