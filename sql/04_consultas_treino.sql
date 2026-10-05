-- Consultas simples de treino. Executadas em PostgreSQL 18.4.
-- Todos os rótulos, filtros e categorias refletem os valores carregados.

-- 1. Quantas barragens existem na base?
-- Resultado conferido: 887.
SELECT COUNT(*) AS total_barragens
FROM barragem;

-- 2. Quantas barragens há em cada UF?
-- Resultado conferido: MG 137, SP 111, SC 94, RS 77, MT 73, GO 69,
-- PR 68, PA 50, RJ 39, RO 34, BA 26, MS 25, TO 23, ES 16, AM 13,
-- RR 11, AP 8, PE 5, SE 4, AL 2, DF 1 e PI 1.
SELECT u.sigla, COUNT(*) AS barragens
FROM barragem b
JOIN municipio m ON m.id_municipio = b.id_municipio
JOIN uf u ON u.sigla = m.uf_sigla
GROUP BY u.sigla
ORDER BY COUNT(*) DESC, u.sigla;

-- 3. Qual barragem está em ABRE CAMPO, MG?
-- Resultado conferido: 1; código 5211; PCH Túlio Cordeiro de Mello
-- (Antiga Granada) - Tulio Cordeiro de Mello.
SELECT b.cod_snisb, b.nome, m.nome AS municipio, u.sigla AS uf
FROM barragem b
JOIN municipio m ON m.id_municipio = b.id_municipio
JOIN uf u ON u.sigla = m.uf_sigla
WHERE m.nome = 'ABRE CAMPO'
  AND u.sigla = 'MG';

-- 4. Quais são as cinco maiores alturas de fundação?
-- Resultado conferido: (4776, 210.0), (4721, 201.43), (4759, 185.0),
-- (4415, 160.0), (5013, 158.0).
SELECT cod_snisb, altura_fundacao_m
FROM barragem
ORDER BY altura_fundacao_m DESC, cod_snisb
LIMIT 5;

-- 5. Quantas barragens há em cada par de risco e dano potencial?
-- Resultado conferido: Alto/Alto 2, Alto/Baixo 1, Baixo/Alto 657,
-- Baixo/Baixo 132, Baixo/Médio 68, Médio/Alto 14, Médio/Baixo 7,
-- Médio/Médio 6.
SELECT categoria_risco, dano_potencial_associado, COUNT(*) AS barragens
FROM barragem
GROUP BY categoria_risco, dano_potencial_associado
ORDER BY categoria_risco, dano_potencial_associado;

-- 6. Quantas têm plano de segurança?
-- Resultado conferido: true 675; false 212.
SELECT possui_plano_seguranca, COUNT(*) AS barragens
FROM barragem
GROUP BY possui_plano_seguranca
ORDER BY possui_plano_seguranca DESC;

-- 7. Como se distribui o PAE, incluindo ausências?
-- Resultado conferido: true 629, false 50 e vazio/NULL 208.
SELECT possui_pae, COUNT(*) AS barragens
FROM barragem
GROUP BY possui_pae
ORDER BY possui_pae;

-- 8. Quais empreendedores têm mais barragens com plano de segurança?
-- Resultado conferido: AXIA ENERGIA NORTE S.A. 36; NORTE ENERGIA S/A 33;
-- AXIA ENERGIA S.A. 29; AXIA ENERGIA NORDESTE S.A. 21;
-- COMPANHIA BRASILEIRA DE ALUMINIO 18.
SELECT e.nome, COUNT(*) AS barragens_com_plano
FROM barragem b
JOIN empreendedor e ON e.id_empreendedor = b.id_empreendedor
WHERE b.possui_plano_seguranca = TRUE
GROUP BY e.nome
ORDER BY COUNT(*) DESC, e.nome
LIMIT 5;

-- 9. Quantas barragens pertencem a cada região hidrográfica?
-- Resultado conferido: Paraná 243; Atlântico Sudeste 158; Amazônica 139;
-- Uruguai 97; Atlântico Sul 74; Tocantins-Araguaia 67; São Francisco 51;
-- Paraguai 37; Atlântico Leste 16; Atlântico Nordeste Oriental 4;
-- Parnaíba 1. Os nomes completos aparecem no resultado.
SELECT r.nome AS regiao_hidrografica, COUNT(*) AS barragens
FROM barragem b
JOIN regiao_hidrografica r
  ON r.id_regiao_hidrografica = b.id_regiao_hidrografica
GROUP BY r.nome
ORDER BY COUNT(*) DESC, r.nome;

-- 10. Como se distribuem as categorias de risco no Paraná e no Uruguai?
-- Resultado conferido: Paraná Alto 1/Baixo 228/Médio 14;
-- Uruguai Alto 1/Baixo 93/Médio 3.
SELECT r.nome AS regiao_hidrografica,
       b.categoria_risco,
       COUNT(*) AS barragens
FROM barragem b
JOIN regiao_hidrografica r
  ON r.id_regiao_hidrografica = b.id_regiao_hidrografica
WHERE r.nome IN (
    'Região Hidrográfica do PARANÁ',
    'Região Hidrográfica do URUGUAI'
)
GROUP BY r.nome, b.categoria_risco
ORDER BY r.nome,
         b.categoria_risco;

-- 11. Como aparecem os primeiros valores de capacidade preservados?
-- Resultado conferido: 20457/62.66/NULL; 20458/51.48/NULL;
-- 20460/9.19/NULL. A capacidade padronizada está NULL nas 887 linhas.
-- O texto é mostrado como foi carregado; não há conversão nem ranking.
SELECT cod_snisb,
       capacidade_reservatorio_texto,
       capacidade_reservatorio_padronizada
FROM barragem
ORDER BY cod_snisb
LIMIT 3;

-- 12. O que conta um JOIN com a proveniência 1:N?
-- Resultado conferido: 29.271 células e 887 barragens distintas.
SELECT COUNT(*) AS celulas_apos_join,
       COUNT(DISTINCT b.cod_snisb) AS barragens_distintas
FROM barragem b
JOIN registro_origem ro ON ro.cod_snisb = b.cod_snisb
JOIN valor_origem vo ON vo.id_registro = ro.id_registro;

-- 13. Pergunta simulada: qual município tem mais barragens e em qual UF?
-- Resultado conferido: VITÓRIA DO XINGU, PA, 32 barragens.
SELECT m.nome AS municipio, u.sigla AS uf, COUNT(*) AS barragens
FROM barragem b
JOIN municipio m ON m.id_municipio = b.id_municipio
JOIN uf u ON u.sigla = m.uf_sigla
GROUP BY m.nome, u.sigla
ORDER BY COUNT(*) DESC, m.nome, u.sigla
LIMIT 1;

-- 14. Pergunta simulada: quantas barragens de risco Alto há por região?
-- Resultado conferido: AMAZÔNICA 1, PARANÁ 1, URUGUAI 1.
SELECT r.nome AS regiao_hidrografica, COUNT(*) AS barragens_risco_alto
FROM barragem b
JOIN regiao_hidrografica r
  ON r.id_regiao_hidrografica = b.id_regiao_hidrografica
WHERE b.categoria_risco = 'Alto'
GROUP BY r.nome
ORDER BY r.nome;
