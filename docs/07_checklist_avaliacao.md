# Checklist dos critérios de avaliação

Equipe: Alexandre Arthur, Enrique Luis e Renan Gomes.
Fonte: enunciado em `docs/referencias/enunciado_barragens_ana.txt`.

## Critérios do enunciado

| Critério | Evidência exigida | Situação nesta etapa |
|---|---|---|
| DDL e 3FN (1,5 ponto) | DDL, dependências, chaves, restrições e índices | Pendente da tarefa 2 e seguintes; sem alegar conformidade antes da modelagem e execução. |
| Carga completa (1,0 ponto) | Script SQL executável com todas as informações do CSV | Entrada recebida e perfilada; carga a produzir nas tarefas 2–5. |
| Consultas na apresentação (1,5 ponto) | Cada aluno responde perguntas com SQL escrito na hora | Preparação pendente das tarefas 6–7. |
| Comentário com integrantes | Nomes da equipe na entrega | Nomes recebidos; incluir nos scripts finais na tarefa 4. |
| Explicar decisões de modelagem | Justificativas por tabela, dependências, constantes e capacidade | Constantes identificadas nesta etapa; análise e justificativas finais pendentes da tarefa 2. |
| Execução em banco vazio | DDL e carga executados em sequência sem erros | Pendente da tarefa 5; ambiente PostgreSQL ainda precisa ser confirmado. |

## Cobertura da Tarefa 1

- [x] CSV original copiado para `dados/originais/ana_barragens_hidreletricas.csv`; SHA-256 registrado no perfil.
- [x] Leitura completa: 887 registros, 33 colunas, 29.271 células; UTF-8-SIG (compatível com UTF-8), vírgula; nenhuma linha malformada ou ignorada.
- [x] Perfil por coluna inclui vazios e todos os valores distintos observados; cabeçalhos duplicados são identificados por posição (nenhum encontrado).
- [x] `cod_snisb`: 887 valores não vazios e distintos; nenhum registro completo repetido.
- [x] Inspeção inicial de delimitadores em campos candidatos, coordenadas, separadores decimal e marcadores exatos de zero.
- [x] Cinco colunas constantes observadas e decisões provisórias registradas no perfil. Preservar todas as colunas; não descartá-las.
- [x] Matriz com 33 linhas na ordem da fonte. Destinos, tipos e regras de reconstrução definitivos ficam para a tarefa 2.

## Pendências para a entrega final

- [ ] Modelagem normalizada até 3FN justificada por dependências funcionais.
- [ ] Capacidade do reservatório tratada sem presumir unidade não demonstrada; decisão documentada.
- [ ] DDL completo e carga SQL com as 887 linhas e toda a informação original.
- [ ] Verificação célula a célula e execução reproduzível em banco vazio.
- [ ] Roteiro, consultas de treino e apresentação da equipe.
