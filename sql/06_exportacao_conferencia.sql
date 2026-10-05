-- Reconstrução da matriz integralmente pela proveniência, em ordem de origem.
-- Execute como consulta no pgAdmin; para CSV automatizado use scripts/03_conferir_dados.py.
SELECT
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'cod_snisb') AS "cod_snisb",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'cod_fiscalizador') AS "cod_fiscalizador",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'nome') AS "nome",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'altura_fundacao_m') AS "altura_fundacao_m",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'altura_terreno_m') AS "altura_terreno_m",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'capacidade_reservatorio') AS "capacidade_reservatorio",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'data_cadastro') AS "data_cadastro",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'tipo_material') AS "tipo_material",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'uso_principal') AS "uso_principal",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'latitude') AS "latitude",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'longitude') AS "longitude",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'regulada_pnsb') AS "regulada_pnsb",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'empreendedor') AS "empreendedor",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'uf') AS "uf",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'municipio') AS "municipio",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'fase_vida') AS "fase_vida",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'orgao_fiscalizador') AS "orgao_fiscalizador",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'numero_autorizacao') AS "numero_autorizacao",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'data_autorizacao') AS "data_autorizacao",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'regiao_hidrografica') AS "regiao_hidrografica",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'cod_trecho_curso_dagua') AS "cod_trecho_curso_dagua",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'curso_dagua') AS "curso_dagua",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'dominio_curso_dagua') AS "dominio_curso_dagua",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'comite_federal') AS "comite_federal",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'comite_estadual') AS "comite_estadual",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'unidade_gestao') AS "unidade_gestao",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'possui_pae') AS "possui_pae",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'possui_plano_seguranca') AS "possui_plano_seguranca",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'possui_revisao_periodica') AS "possui_revisao_periodica",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'categoria_risco') AS "categoria_risco",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'dano_potencial_associado') AS "dano_potencial_associado",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'barragem_autuada') AS "barragem_autuada",
       MAX(vo.valor_original) FILTER (WHERE co.nome_original = 'completude_cadastro') AS "completude_cadastro"
FROM registro_origem ro
JOIN valor_origem vo USING (id_registro)
JOIN campo_origem co USING (ordem_coluna)
GROUP BY ro.numero_linha
ORDER BY ro.numero_linha;
