# Roteiro sugerido — apresentação de 6 a 8 minutos

Tempo recomendado: cerca de 7 minutos. Ajustem conforme a duração definida pelo professor.

| Tempo | Integrante | Tópico e demonstração |
|---|---|---|
| 0:00–0:45 | Alexandre Arthur | Apresentar a fonte da ANA: 887 barragens, 33 campos e 22 UFs. Explicar que `cod_snisb` identifica uma barragem. |
| 0:45–2:20 | Enrique Luis | Mostrar o modelo: `barragem` guarda atributos da barragem; `municipio` depende de UF; `empreendedor` e `regiao_hidrografica` são dimensões reutilizadas. Explicar chaves e FKs como controles de integridade. |
| 2:20–3:30 | Renan Gomes | Descrever a carga e a proveniência: 887 registros, 33 campos e 29.271 células. Cada linha original liga a `registro_origem`; cada célula fica em `valor_origem`. A comparação integral recuperou todas as células sem divergência. |
| 3:30–4:30 | Alexandre Arthur | Explicar os JOINs geográficos e executar a contagem por UF. Há 137 barragens em MG e 111 em SP. |
| 4:30–5:30 | Enrique Luis | Mostrar o filtro municipal e os agrupamentos de risco/dano. Em ABRE CAMPO/MG, a consulta encontra uma barragem. |
| 5:30–6:30 | Renan Gomes | Explicar `NULL`, as constantes e a capacidade: `possui_pae` tem 208 ausências; capacidade permanece como texto e não recebe unidade presumida. |
| 6:30–7:30 | Todos | Resolver duas perguntas “na hora”, construindo `SELECT`, `JOIN`, `WHERE`, `GROUP BY` e `ORDER BY`. Cada integrante deve conduzir ao menos uma resposta. |

## Ensaio de SQL

- **Alexandre Arthur:** preparar os exercícios 2 e 3. Juntos, praticam `SELECT`, `JOIN`, `WHERE`, `GROUP BY` e `ORDER BY`; explicar como município determina a UF sem duplicar o nome por extenso.
- **Enrique Luis:** preparar o exercício 8, que usa as cinco cláusulas para contar barragens com plano por empreendedor. Repassar o exercício 10 como alternativa de comparação por região e risco.
- **Renan Gomes:** preparar o exercício 10, que reúne seleção, JOIN, filtro, agrupamento e ordenação; também explicar o exercício 11 e por que a capacidade padronizada é `NULL`.

## Fechamento

Reforçar que o banco preserva os textos de origem, mantém a unidade da capacidade desconhecida e permite reproduzir os 29.271 valores originais. Encerrar mostrando a diferença entre contar 29.271 células depois do JOIN com proveniência e contar as 887 barragens distintas.
