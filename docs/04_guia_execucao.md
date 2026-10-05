# Guia de execução e conferência

## Requisitos

PostgreSQL 18.4 e `psql` (cliente PostgreSQL 18.4) foram usados na validação documentada em `docs/08_resultados_validacao.md`. Use uma base vazia dedicada. Os arquivos de criação e carga são SQL comum e podem ser executados tanto por `psql` quanto pelo pgAdmin.

## Fluxo com psql

Com uma conexão já configurada para seu banco de teste, na raiz deste projeto:

```sh
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f sql/01_criacao.sql
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f sql/02_carga.sql
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f sql/03_validacao.sql
```

`ON_ERROR_STOP=1` encerra a execução no primeiro erro. Não execute a criação sobre banco que contenha dados que deseja preservar.

## Fluxo com pgAdmin

Crie ou selecione um banco vazio dedicado. Abra o Query Tool conectado a esse banco e abra, execute integralmente e na ordem `sql/01_criacao.sql`, `sql/02_carga.sql` e `sql/03_validacao.sql`. Confira a aba de mensagens e os resultados de validação antes de prosseguir. O teste de restrições `sql/05_testes_restricoes.sql` é separado e deve ser executado em banco descartável, não como parte da sequência obrigatória.

## Exportar e comparar a matriz

`sql/06_exportacao_conferencia.sql` retorna a matriz remontada por `registro_origem`, `valor_origem` e `campo_origem`, com os nomes e a ordem originais e linhas ordenadas por `numero_linha`. No pgAdmin, execute a consulta e use a opção de salvar o resultado em CSV UTF-8.

Para produzir e comparar automaticamente:

```sh
python3 scripts/03_conferir_dados.py --banco NOME_DO_BANCO --port 5432
```

O script invoca `psql`, grava `dados/analise/barragens_conferidas.csv`, lê fonte e exportação via `csv.reader`, confere cabeçalhos, número de linhas e cada célula, e calcula SHA-256 da fonte antes e depois. O marcador `__SQL_NULL_7f3a9c__` representa NULL do SQL no CSV; o script primeiro confirma sua ausência em todas as células da fonte. A string vazia continua vazia, e NULL permanece diferente de vazio na comparação, gerando uma diferença com linha e coluna. Uma divergência retorna código de saída diferente de zero. Não trate a conferência como aprovada se houver diferenças.
