# Resultados da validação integral

## Ambiente

- Servidor: PostgreSQL 18.4 (x86_64-apple-darwin24.6.0).
- Cliente: `psql` 18.4.
- Base usada: `barragens_ana_t5_keys`, criada vazia na instância isolada de teste.
- Execução sequencial, todos os comandos concluíram com código 0:

```sh
psql -h 127.0.0.1 -p 55432 -d barragens_ana_t5_keys -v ON_ERROR_STOP=1 -f sql/01_criacao.sql
psql -h 127.0.0.1 -p 55432 -d barragens_ana_t5_keys -v ON_ERROR_STOP=1 -f sql/02_carga.sql
psql -h 127.0.0.1 -p 55432 -d barragens_ana_t5_keys -v ON_ERROR_STOP=1 -f sql/03_validacao.sql
```

## Evidências

As consultas retornaram 887 linhas em `barragem`, 887 em `registro_origem`, 33 em `campo_origem` e 29.271 em `valor_origem`. Há 2.524 valores vazios preservados como `''`. Os SELECTs de todas as 20 PKs/UNIQUEs retornaram zero grupos duplicados; os SELECTs de todas as 10 FKs (UF, dimensões analíticas e proveniência) retornaram zero órfãos. A consulta de cobertura usa `registro_origem LEFT JOIN valor_origem`, inclui registros sem células e mostrou `esperado=0, encontrado=0` para registros com contagem diferente de 33. A validação usa somente SELECTs simples.

O comparador foi exercitado primeiro em RED (dois casos falharam por ausência do módulo), depois em GREEN (CSV idêntico: aprovado e zero diferenças; célula alterada: diferença na linha 2 e coluna `nome`). A comparação integral foi executada duas vezes contra a base final: em ambas, 887 linhas, 33 colunas, 29.271 células, zero diferenças e resultado `APROVADO`. SHA-256 original antes e depois: `ae9f20fc1e084ed48a0187f7cfba648c71a7a13f8fa13379cbe1df32be029aef`, igual ao perfil CSV. O marcador `__SQL_NULL_7f3a9c__` não foi encontrado nas células da fonte; o comparador trata esse marcador como valor distinto de `''`.

Teste negativo separado, feito com cópia temporária da fonte alterada em uma célula: retorno esperado e obtido `1`; reportou exatamente uma diferença na linha 2, coluna `nome`. A cópia de teste e o CSV exportado foram removidos. O comparador recria `dados/analise/barragens_conferidas.csv` durante o uso.

## Teste das cópias finais de entrega

As cópias `entrega/01_criacao.sql` e `entrega/02_carga.sql` têm SHA-256 idêntico aos scripts canônicos correspondentes em `sql/`. Foram executadas, nessa ordem, em uma segunda base recém-criada e vazia (`barragens_ana_entrega_final`), seguida de `sql/03_validacao.sql`. DDL, carga e validação retornaram código `0`.

Essa execução confirmou 887 barragens, 887 registros de origem, 33 campos e 29.271 células. As 20 verificações de PK/UNIQUE não apontaram grupos duplicados; as 10 verificações de FK não encontraram órfãos; a cobertura encontrou zero registros com quantidade de células diferente de 33. As cópias SQL não dependem do CSV, de Python ou de caminhos absolutos para carregar a base.
