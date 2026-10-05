# Resumo da apresentação — Banco de barragens da ANA

## O que foi construído

Banco relacional em PostgreSQL 18.4 para as 887 barragens hidrelétricas do arquivo fornecido pela ANA. O esquema separa barragens, municípios, UFs, empreendedores e regiões hidrográficas, mantendo também uma trilha para reconstituir a matriz original.

## Relações principais

```text
uf 1 ── N municipio 1 ── N barragem N ── 1 empreendedor
                                  └──── N ── 1 regiao_hidrografica

barragem 1 ── 1 registro_origem 1 ── 33 valor_origem
campo_origem 1 ────────────────────── N valor_origem
```

As chaves primárias e estrangeiras identificam linhas e impedem vínculos sem correspondência. O par `(uf_sigla, nome)` identifica o município dentro do estado. Empreendedor e região têm dimensões próprias porque seus nomes são reutilizados.

## Integridade e decisões

- Uma barragem é identificada pelo `cod_snisb`.
- A carga preserva 887 linhas, 33 colunas e 29.271 valores na proveniência; vazios de origem ficam como texto vazio nesse histórico.
- `possui_pae` pode ser `NULL`; 208 linhas não informam esse dado.
- Cinco campos constantes foram mantidos na tabela: uso principal, regulação, órgão fiscalizador, autuação e completude.
- A capacidade aparece como texto literal. A coluna numérica padronizada continua `NULL` porque a fonte não demonstra sua unidade.

## Validação e consultas

DDL, carga e validação rodaram em PostgreSQL 18.4. Foram conferidas 887 barragens, 887 registros de origem, 33 campos, 29.271 células, chaves únicas e FKs sem órfãos. Duas reconstruções compararam as 29.271 células sem diferenças. Exemplos de consulta incluem contagem por UF, filtro por município, risco e dano, planos de segurança, PAE e região hidrográfica.

## Ideia-chave para a apresentação

Um JOIN de `barragem b`, `registro_origem ro` e `valor_origem vo` retorna 29.271 linhas porque cada barragem tem 33 células originais. Para contar entidades nesse resultado, `COUNT(DISTINCT b.cod_snisb)` retorna 887 barragens.
