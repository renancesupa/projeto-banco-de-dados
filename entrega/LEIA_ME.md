# Entrega — Banco de dados de barragens da ANA

**Equipe:** Alexandre Arthur, Enrique Luis e Renan Gomes.

## Scripts obrigatórios

Os arquivos `01_criacao.sql` e `02_carga.sql` criam e populam o banco. Foram executados nessa ordem em um banco PostgreSQL vazio, usando PostgreSQL 18.4 e `psql` 18.4. Não precisam do CSV nem de Python para carregar os dados.

Crie ou selecione um banco vazio e execute, na raiz do projeto:

```sh
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f entrega/01_criacao.sql
psql -p 5432 -d NOME_DO_BANCO -v ON_ERROR_STOP=1 -f entrega/02_carga.sql
```

`ON_ERROR_STOP=1` interrompe a execução ao primeiro erro. Não execute sobre um banco com dados que deseja preservar.

## Conferência e material de apoio

Depois da carga, execute `sql/03_validacao.sql` para conferir contagens, chaves e relacionamentos. A evidência da comparação célula a célula está em `docs/08_resultados_validacao.md`.

- Modelo, dependências e decisões: `docs/01_modelagem.md`, `docs/02_dicionario_dados.md` e `docs/03_decisoes_dados.md`.
- Consultas e gabaritos: `sql/04_consultas_treino.sql` e `docs/06_guia_consultas.md`.
- Roteiro e perguntas de ensaio: `docs/05_roteiro_apresentacao.md` e `apresentacao/`.
- CSV original e perfil: `dados/originais/` e `dados/analise/`.

A capacidade do reservatório foi mantida como texto original. A coluna numérica padronizada permanece `NULL`, pois a unidade não foi confirmada na fonte.
