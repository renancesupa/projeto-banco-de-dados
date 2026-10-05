# Checklist dos critérios de avaliação

Equipe: Alexandre Arthur, Enrique Luis e Renan Gomes.
Fonte: enunciado em `docs/referencias/enunciado_barragens_ana.txt`.

## Critérios do enunciado

| Critério | Evidência exigida | Situação nesta etapa |
|---|---|---|
| DDL e 3FN (1,5 ponto) | DDL, dependências, chaves, restrições e índices | Modelagem e DDL documentados; integridade e unicidade confirmadas na base descartável. |
| Carga completa (1,0 ponto) | Script SQL executável com todas as informações do CSV | Carga validada: 887 barragens e 29.271 valores de proveniência; zero diferenças no round-trip. |
| Consultas na apresentação (1,5 ponto) | Cada aluno responde perguntas com SQL escrito na hora | Tarefa 6 produziu 14 consultas conferidas, roteiro por integrante e duas perguntas de ensaio; ensaio oral ainda pendente. |
| Comentário com integrantes | Nomes da equipe na entrega | Nomes recebidos; incluir nos scripts finais na tarefa 4. |
| Explicar decisões de modelagem | Justificativas por tabela, dependências, constantes e capacidade | Justificativas e dependências documentadas em `docs/01_modelagem.md`, `docs/02_dicionario_dados.md` e `docs/03_decisoes_dados.md`. |
| Execução em banco vazio | DDL e carga executados em sequência sem erros | DDL, carga e validação executados em sequência sem erro em base descartável; evidência em `docs/08_resultados_validacao.md`. |

## Cobertura da Tarefa 1

- [x] CSV original copiado para `dados/originais/ana_barragens_hidreletricas.csv`; SHA-256 registrado no perfil.
- [x] Leitura completa: 887 registros, 33 colunas, 29.271 células; UTF-8-SIG (compatível com UTF-8), vírgula; nenhuma linha malformada ou ignorada.
- [x] Perfil por coluna inclui vazios e todos os valores distintos observados; cabeçalhos duplicados são identificados por posição (nenhum encontrado).
- [x] `cod_snisb`: 887 valores não vazios e distintos; nenhum registro completo repetido.
- [x] Inspeção inicial de delimitadores em campos candidatos, coordenadas, separadores decimal e marcadores exatos de zero.
- [x] Cinco colunas constantes observadas e decisões provisórias registradas no perfil. Preservar todas as colunas; não descartá-las.
- [x] Matriz com 33 linhas na ordem da fonte. Destinos, tipos e regras exatas de reconstrução foram definidos na tarefa 2.

## Cobertura da Tarefa 3

- [x] DDL cria as 11 tabelas na ordem definida e nomeia PKs, FKs, UNIQUE, NOT NULL e CHECK aplicáveis.
- [x] Cinco testes negativos foram executados em base PostgreSQL descartável e rejeitados pelas restrições esperadas; cada bloco terminou em `ROLLBACK`.
- [x] Após os testes, as 11 tabelas de teste permaneceram vazias. A carga completa e a validação integral foram concluídas na Tarefa 5.

## Cobertura da Tarefa 5

- [x] PostgreSQL e cliente `psql` 18.4; DDL, carga e validação executados em sequência em base nova com interrupção ao primeiro erro.
- [x] Conferidas as 887 barragens, 887 linhas de origem, 33 campos, 29.271 valores e 2.524 vazios; unicidade e FKs sem órfãos.
- [x] Comparação integral repetida duas vezes: 29.271 células, zero diferenças; SHA-256 original preservado.
- [x] Testes negativos separados; detalhes e resultados reais em `docs/08_resultados_validacao.md`.

## Cobertura da Tarefa 6

- [x] 14 SELECTs simples executados em modo somente leitura na base validada; exercícios e resultados em `docs/06_guia_consultas.md`, evidências PostgreSQL em `docs/08_resultados_validacao.md`.
- [x] Exercícios incluem perguntas, SQL, resultados resumidos e explicação cláusula por cláusula; capacidade permanece textual e sem unidade presumida.
- [x] Roteiro de 6–8 minutos distribui a prática SQL entre Alexandre Arthur, Enrique Luis e Renan Gomes; duas perguntas sem gabarito estão prontas para ensaio.
- [ ] Ensaio oral da equipe para confirmar autonomia ao escrever consultas na hora.

## Pendências para a entrega final

- [x] Modelagem normalizada até 3FN justificada por dependências funcionais em `docs/01_modelagem.md` e `dados/analise/dependencias_funcionais.md`.
- [x] Capacidade do reservatório tratada sem presumir unidade não demonstrada; decisão documentada em `docs/03_decisoes_dados.md`.
- [x] DDL completo e carga SQL com as 887 linhas e toda a informação original; carga integral e proveniência verificadas em `docs/08_resultados_validacao.md`.
- [x] Verificação célula a célula e execução reproduzível em banco vazio.
- [x] Roteiro, consultas de treino e material de apresentação produzidos; ensaio oral da equipe pendente.
