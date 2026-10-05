# Banco de dados de barragens ANA

Projeto acadêmico de modelagem relacional e preservação da matriz original de barragens hidrelétricas.

## Execução

Use PostgreSQL 18.4 e, em um banco PostgreSQL vazio e dedicado, execute nesta ordem:

```sh
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f sql/01_criacao.sql
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f sql/02_carga.sql
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f sql/03_validacao.sql
```

Com `psql`, configure a conexão para seu banco de teste e execute cada arquivo com `-v ON_ERROR_STOP=1`, para interromper no primeiro erro. No pgAdmin, selecione um banco vazio, abra o Query Tool e execute integralmente `01_criacao.sql`, depois `02_carga.sql` e, por fim, `03_validacao.sql`.

`sql/05_testes_restricoes.sql` é uma bateria negativa separada, executada em banco descartável; não integra a sequência obrigatória de criação e carga. `sql/06_exportacao_conferencia.sql` reconstrói a matriz pela proveniência. Para exportar e comparar todas as células com o CSV de origem, use `python3 scripts/03_conferir_dados.py --banco NOME_DO_BANCO --port 5432` (com `psql` disponível no PATH). A validação em PostgreSQL 18.4 encontrou 887 barragens, 33 campos e 29.271 células, sem diferenças nas duas conferências; consulte `docs/08_resultados_validacao.md`. O CSV de conferência é gravado em `dados/analise/barragens_conferidas.csv`.

## Projeto e resultados

- Modelo e justificativas: `docs/01_modelagem.md`, `docs/02_dicionario_dados.md` e `docs/03_decisoes_dados.md`.
- Instruções completas de execução: `docs/04_guia_execucao.md`.
- Evidências da validação realizada: `docs/08_resultados_validacao.md`.
- Checklist da avaliação: `docs/07_checklist_avaliacao.md`.
