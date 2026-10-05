# Guia de consultas SQL

Os exemplos usam o esquema carregado no PostgreSQL 18.4 e foram conferidos em modo somente leitura na base validada. As tabelas principais para a apresentação são `barragem`, `uf`, `municipio`, `empreendedor` e `regiao_hidrografica`. O arquivo `sql/04_consultas_treino.sql` contém as mesmas consultas prontas para executar.

## Como montar uma consulta

Construa a consulta nesta ordem de raciocínio: escolha as tabelas necessárias; escreva os `JOIN`s pelas chaves estrangeiras; acrescente o `WHERE` para filtrar linhas; escolha as colunas do `SELECT`; use `GROUP BY` quando houver agregação por categoria; ordene com `ORDER BY`; e limite a amostra com `LIMIT`, se a pergunta pedir os primeiros resultados. Por exemplo, para contar por UF, barragem liga a municipio por `id_municipio`, e municipio liga a uf por `uf_sigla`/`sigla`.

Os exemplos mantêm as categorias e grafias encontradas: `Alto`, `Baixo`, `Médio`, `true` e `false`. `possui_pae` aceita SQL `NULL`; use `IS NULL` para reconhecê-lo, pois `= NULL` não funciona. `cod_snisb` identifica cada barragem. Para capacidade, use apenas o texto original e a coluna padronizada, que permanece `NULL` porque a unidade de origem não foi confirmada.

## Como explicar a 3FN no esquema

- `uf`: `sigla` identifica a linha; nenhum nome por extenso foi fornecido.
- `municipio`: `id_municipio` identifica o município; `(uf_sigla, nome)` é único. A sigla da UF fica em `uf`, evitando repetir atributos da UF nos municípios.
- `empreendedor`, `regiao_hidrografica`, `comite_federal`, `comite_estadual` e `unidade_gestao`: cada tabela identifica uma entidade por ID e mantém seu rótulo único. O rótulo fica guardado uma vez e as barragens referenciam o ID.
- `barragem`: os atributos descritivos dependem do código único `cod_snisb`. Município, empreendedor e região são referências a entidades próprias; seus nomes não são repetidos na tabela.
- `registro_origem`: `id_registro` identifica a linha da fonte; `numero_linha` e `cod_snisb` são únicos nesta carga. A linha original fica separada dos atributos analíticos da barragem.
- `campo_origem`: `ordem_coluna` identifica o campo e `nome_original` também é único. O cabeçalho não se repete em cada célula.
- `valor_origem`: a chave composta `(id_registro, ordem_coluna)` identifica uma célula; `valor_original` depende da linha e da coluna. Assim a proveniência não guarda 33 atributos como colunas repetidas.

## Exercícios com gabarito

### 1. Total de barragens

**Pergunta:** quantas barragens há na base?

```sql
SELECT COUNT(*) AS total_barragens
FROM barragem;
```

**Resultado conferido:** 887.

**Cláusulas:** `SELECT COUNT(*)` conta as linhas; `FROM barragem` define que cada linha é uma barragem. Não é necessário `JOIN`, filtro nem agrupamento.

### 2. Contagem por UF

**Pergunta:** quantas barragens há em cada estado?

```sql
SELECT u.sigla, COUNT(*) AS barragens
FROM barragem b
JOIN municipio m ON m.id_municipio = b.id_municipio
JOIN uf u ON u.sigla = m.uf_sigla
GROUP BY u.sigla
ORDER BY COUNT(*) DESC, u.sigla;
```

**Resultado conferido:** MG 137; SP 111; SC 94; RS 77; MT 73; GO 69; PR 68; PA 50; RJ 39; RO 34; BA 26; MS 25; TO 23; ES 16; AM 13; RR 11; AP 8; PE 5; SE 4; AL 2; DF 1; PI 1.

**Cláusulas:** `SELECT` mostra a sigla e a contagem. `FROM barragem b` começa com a entidade contada. Os dois `JOIN`s seguem as FKs de barragem para município e de município para UF. `GROUP BY u.sigla` cria um total por estado. `ORDER BY COUNT(*) DESC` põe os maiores primeiro; `u.sigla` desempata alfabeticamente.

### 3. Filtro por município e UF

**Pergunta:** qual barragem está em ABRE CAMPO, MG?

```sql
SELECT b.cod_snisb, b.nome, m.nome AS municipio, u.sigla AS uf
FROM barragem b
JOIN municipio m ON m.id_municipio = b.id_municipio
JOIN uf u ON u.sigla = m.uf_sigla
WHERE m.nome = 'ABRE CAMPO'
  AND u.sigla = 'MG';
```

**Resultado conferido:** uma linha: código 5211, `PCH Túlio Cordeiro de Mello (Antiga Granada) - Tulio Cordeiro de Mello`, ABRE CAMPO, MG.

**Cláusulas:** `SELECT` escolhe código, nome e rótulos geográficos. `FROM` e `JOIN`s ligam a barragem ao município e à UF. `WHERE` mantém somente o par pedido; `AND` exige que as duas condições sejam verdadeiras. Não há agrupamento porque a pergunta pede registros, não totais.

### 4. Maiores alturas de fundação

**Pergunta:** quais são as cinco maiores alturas de fundação?

```sql
SELECT cod_snisb, altura_fundacao_m
FROM barragem
ORDER BY altura_fundacao_m DESC, cod_snisb
LIMIT 5;
```

**Resultado conferido:** (4776, 210.0), (4721, 201.43), (4759, 185.0), (4415, 160.0), (5013, 158.0).

**Cláusulas:** `SELECT` mostra o identificador e a altura. `FROM` lê a tabela de barragens. `ORDER BY altura_fundacao_m DESC` põe os valores maiores primeiro; `cod_snisb` desempata. `LIMIT 5` retorna apenas cinco linhas.

### 5. Categoria de risco e dano potencial

**Pergunta:** quantas barragens há em cada combinação de risco e dano potencial?

```sql
SELECT categoria_risco, dano_potencial_associado, COUNT(*) AS barragens
FROM barragem
GROUP BY categoria_risco, dano_potencial_associado
ORDER BY categoria_risco, dano_potencial_associado;
```

**Resultado conferido:** Alto/Alto 2; Alto/Baixo 1; Baixo/Alto 657; Baixo/Baixo 132; Baixo/Médio 68; Médio/Alto 14; Médio/Baixo 7; Médio/Médio 6.

**Cláusulas:** `SELECT` apresenta as duas categorias e conta linhas. `FROM` usa barragem. `GROUP BY` forma um grupo para cada par de rótulos. `ORDER BY` ordena os nomes das categorias alfabeticamente, sem alterar os dados.

### 6. Plano de segurança

**Pergunta:** quantas barragens têm ou não plano de segurança?

```sql
SELECT possui_plano_seguranca, COUNT(*) AS barragens
FROM barragem
GROUP BY possui_plano_seguranca
ORDER BY possui_plano_seguranca DESC;
```

**Resultado conferido:** `true` 675; `false` 212.

**Cláusulas:** `SELECT` mostra o valor booleano e o total. `FROM barragem` conta registros de barragem. `GROUP BY` separa verdadeiro e falso. `ORDER BY ... DESC` mostra `true` antes de `false` no PostgreSQL.

### 7. PAE e valores ausentes

**Pergunta:** como se distribui a informação sobre PAE, incluindo os valores ausentes?

```sql
SELECT possui_pae, COUNT(*) AS barragens
FROM barragem
GROUP BY possui_pae
ORDER BY possui_pae;
```

**Resultado conferido:** `true` 629; `false` 50; vazio (SQL `NULL`) 208.

**Cláusulas:** `SELECT` mostra o valor booleano e a contagem. `FROM` lê barragem. `GROUP BY possui_pae` mantém três grupos: falso, verdadeiro e `NULL`. `ORDER BY possui_pae` os apresenta em ordem, com `NULL` no final no PostgreSQL. A célula vazia da fonte foi carregada como `NULL`; para buscar essas linhas, use `WHERE possui_pae IS NULL`, nunca `= NULL`.

### 8. Empreendedores com mais planos de segurança

**Pergunta:** quais cinco empreendedores têm mais barragens com plano de segurança?

```sql
SELECT e.nome, COUNT(*) AS barragens_com_plano
FROM barragem b
JOIN empreendedor e ON e.id_empreendedor = b.id_empreendedor
WHERE b.possui_plano_seguranca = TRUE
GROUP BY e.nome
ORDER BY COUNT(*) DESC, e.nome
LIMIT 5;
```

**Resultado conferido:** AXIA ENERGIA NORTE S.A. 36; NORTE ENERGIA S/A 33; AXIA ENERGIA S.A. 29; AXIA ENERGIA NORDESTE S.A. 21; COMPANHIA BRASILEIRA DE ALUMINIO 18.

**Cláusulas:** `SELECT` mostra o empreendedor e o total. `FROM` parte de barragem, que é a entidade contada. `JOIN` obtém o nome da dimensão empreendedor. `WHERE` mantém apenas `TRUE`. `GROUP BY` soma por empreendedor; `ORDER BY` põe os maiores totais primeiro e desempata por nome. `LIMIT 5` seleciona os cinco primeiros.

### 9. Contagem por região hidrográfica

**Pergunta:** quantas barragens estão em cada região?

```sql
SELECT r.nome AS regiao_hidrografica, COUNT(*) AS barragens
FROM barragem b
JOIN regiao_hidrografica r
  ON r.id_regiao_hidrografica = b.id_regiao_hidrografica
GROUP BY r.nome
ORDER BY COUNT(*) DESC, r.nome;
```

**Resultado conferido:** Região Hidrográfica do PARANÁ 243; Região Hidrográfica ATLÂNTICO SUDESTE 158; Região Hidrográfica AMAZÔNICA 139; Região Hidrográfica do URUGUAI 97; Região Hidrográfica ATLÂNTICO SUL 74; Região Hidrográfica do TOCANTINS-ARAGUAIA 67; Região Hidrográfica do SÃO FRANCISCO 51; Região Hidrográfica do PARAGUAI 37; Região Hidrográfica ATLÂNTICO LESTE 16; Região Hidrográfica ATLÂNTICO NORDESTE ORIENTAL 4; Região Hidrográfica do PARNAÍBA 1.

**Cláusulas:** `SELECT` mostra o nome da região e total de barragens. `FROM` começa nas barragens. `JOIN` liga a dimensão pelo identificador estrangeiro. `GROUP BY r.nome` cria um total por rótulo. `ORDER BY COUNT(*) DESC` mostra as regiões mais frequentes primeiro; o nome desempata.

### 10. Comparação agrupada por região e risco

**Pergunta:** como se distribuem as categorias de risco no Paraná e no Uruguai?

```sql
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
ORDER BY r.nome, b.categoria_risco;
```

**Resultado conferido:** PARANÁ—Alto 1, Baixo 228, Médio 14; URUGUAI—Alto 1, Baixo 93, Médio 3.

**Cláusulas:** `SELECT` mostra região, categoria e contagem. `FROM` parte de barragem; `JOIN` lê o rótulo da região. `WHERE ... IN` mantém exatamente as duas regiões indicadas, com grafia igual à carga. `GROUP BY` conta cada combinação. `ORDER BY` agrupa a exibição pelo nome da região e categoria.

### 11. Capacidade sem inferir unidade

**Pergunta:** como aparecem alguns valores de capacidade preservados na origem?

```sql
SELECT cod_snisb,
       capacidade_reservatorio_texto,
       capacidade_reservatorio_padronizada
FROM barragem
ORDER BY cod_snisb
LIMIT 3;
```

**Resultado conferido:** código 20457 tem texto `62.66` e valor padronizado `NULL`; 20458 tem `51.48` e `NULL`; 20460 tem `9.19` e `NULL`. Os 887 valores padronizados estão `NULL`.

**Cláusulas:** `SELECT` exibe código, texto literal e campo padronizado. `FROM barragem` consulta a entidade. `ORDER BY cod_snisb` define a amostra por código; `LIMIT 3` mostra três linhas. A consulta não converte, compara nem classifica a capacidade: a unidade não foi comprovada.

### 12. Contagem após JOIN com proveniência

**Pergunta:** por que a contagem de linhas muda ao juntar cada registro às células de origem?

```sql
SELECT COUNT(*) AS celulas_apos_join,
       COUNT(DISTINCT b.cod_snisb) AS barragens_distintas
FROM barragem b
JOIN registro_origem ro ON ro.cod_snisb = b.cod_snisb
JOIN valor_origem vo ON vo.id_registro = ro.id_registro;
```

**Resultado conferido:** `celulas_apos_join` 29.271; `barragens_distintas` 887.

**Cláusulas:** `SELECT COUNT(*)` conta cada linha produzida pelos `JOIN`s; `COUNT(DISTINCT b.cod_snisb)` conta códigos de barragem diferentes. `FROM barragem`, `JOIN registro_origem` e `JOIN valor_origem` atravessam a relação 1:N: cada barragem tem 33 células originais. Portanto, depois desses JOINs, `COUNT(*)` responde células, não barragens.

### 13. Município com mais barragens

**Pergunta simulada:** qual município tem mais barragens e em qual UF ele está?

```sql
SELECT m.nome AS municipio, u.sigla AS uf, COUNT(*) AS barragens
FROM barragem b
JOIN municipio m ON m.id_municipio = b.id_municipio
JOIN uf u ON u.sigla = m.uf_sigla
GROUP BY m.nome, u.sigla
ORDER BY COUNT(*) DESC, m.nome, u.sigla
LIMIT 1;
```

**Resultado conferido:** VITÓRIA DO XINGU, PA, 32 barragens.

**Cláusulas:** `SELECT` mostra nome, UF e quantidade. `FROM barragem` conta barragens. Os `JOIN`s ligam cada barragem ao seu município e à UF. `GROUP BY m.nome, u.sigla` soma por par município/estado. `ORDER BY COUNT(*) DESC` põe a maior quantidade primeiro, com município e UF como desempates. `LIMIT 1` mostra a primeira colocada.

### 14. Risco alto por região

**Pergunta simulada:** quantas barragens com categoria de risco `Alto` há em cada região hidrográfica?

```sql
SELECT r.nome AS regiao_hidrografica,
       COUNT(*) AS barragens_risco_alto
FROM barragem b
JOIN regiao_hidrografica r
  ON r.id_regiao_hidrografica = b.id_regiao_hidrografica
WHERE b.categoria_risco = 'Alto'
GROUP BY r.nome
ORDER BY r.nome;
```

**Resultado conferido:** Região Hidrográfica AMAZÔNICA 1; Região Hidrográfica do PARANÁ 1; Região Hidrográfica do URUGUAI 1.

**Cláusulas:** `SELECT` mostra cada região e a contagem. `FROM barragem` parte da entidade contada. `JOIN` traz o nome da região pela FK. `WHERE` limita aos registros cuja categoria é exatamente `Alto`. `GROUP BY r.nome` soma os registros por região. `ORDER BY r.nome` exibe os grupos alfabeticamente.
