# Dependências funcionais observadas

## Método

Os grupos foram montados com o texto CSV exato, sem trim, casefold, conversão de acentos ou descarte de vazio. Em cada grupo, contamos os valores distintos da coluna dependente. O agrupamento seguiu este padrão:

    def conflitos_dependencia(linhas, indices_chave, indice_valor):
        grupos = {}
        for linha in linhas:
            chave = tuple(linha[i] for i in indices_chave)
            grupos.setdefault(chave, set()).add(linha[indice_valor])
        return {chave: valores for chave, valores in grupos.items()
                if len(valores) > 1}

## Chaves candidatas da barragem

cod_snisb tem 887 grupos, nenhum vazio e nenhum conflito com qualquer outra coluna: cada grupo contém exatamente um valor de cada campo. Portanto é chave natural da barragem nesta fonte. cod_fiscalizador também tem 887 grupos distintos e nenhum vazio, mas fica sem UNIQUE no esquema porque a fonte não documenta a regra de negócio. nome tem 849 valores distintos para 887 registros, portanto não é chave.

## Dependências candidatas testadas

| A → B | Grupos por A | Grupos com mais de um B | Quantidade observada de B nos grupos conflitantes |
|---|---:|---:|---|
| municipio → uf | 448 | 5 | Todos têm 2 siglas. Nomes: BARRA BONITA, GUARACIABA, PETROLÂNDIA, PIRANHAS e SÃO DOMINGOS. |
| cod_trecho_curso_dagua → curso_dagua | 356 | 25 | 22 códigos têm 2 nomes; 3 códigos têm 3 nomes. |
| cod_trecho_curso_dagua → dominio_curso_dagua | 356 | 25 | Todos os 25 códigos conflitantes têm 2 valores exatos, incluindo vazio quando presente. |
| curso_dagua → regiao_hidrografica | 312 | 22 | 16 nomes têm 2 regiões; 4 têm 3; 1 tem 4; SEM NOME tem 10. |
| empreendedor → uf | 406 | 26 | 19 nomes têm 2 UFs; 3 têm 3; 1 tem 4; 2 têm 5; 1 tem 7. |
| comite_federal → regiao_hidrografica | 20 | 1 | O grupo vazio tem 9 regiões; nenhum rótulo federal não vazio conflita neste recorte. |
| comite_estadual → regiao_hidrografica | 119 | 3 | O grupo vazio tem 10 regiões; CBH do Alto Iguaçu e Afluentes do Alto Ribeira e CBH do Alto Tietê têm 2 cada. |
| unidade_gestao → regiao_hidrografica | 85 | 3 | O grupo vazio tem 7 regiões; CBH do Alto Iguaçu e Afluentes do Alto Ribeira e CBH do Alto Tietê têm 2 cada. |

A tabela acima conta string vazia como um valor, conforme a regra de comparação literal. Para os comitês/unidades, os conflitos no grupo vazio não são uma associação do rótulo: representam ausência de rótulo em barragens de regiões distintas. Mesmo onde não há conflito entre rótulos preenchidos, a amostra não estabelece regra universal com a região.

## Decisões que decorrem dos conflitos

- Município é dimensionado por (uf_sigla, nome), com chave técnica id_municipio e UNIQUE no par. Nome sozinho não determina UF.
- Empreendedor é dimensão por rótulo exato; UF fica no município e não é atributo do empreendedor.
- cod_trecho_curso_dagua, curso_dagua e dominio_curso_dagua ficam em barragem. Nenhum deles, isoladamente, sustenta uma chave de curso nem uma dependência entre código, nome e domínio.
- regiao_hidrografica fica ligada diretamente à barragem. Nome de rio não é usado para inferi-la.
- comite_federal, comite_estadual e unidade_gestao são dimensões independentes opcionais. Não se cria relação com região nem se divide um nome por vírgula.
- cod_snisb identifica barragem neste CSV; registro_origem ainda mantém uma linha por número de linha, e cod_snisb é FK UNIQUE nessa carga.

Os campos com valores categóricos, mas sem dependência ou ganho claro com mais relações, permanecem texto em barragem. As dependências descrevem apenas os 887 registros analisados; não são afirmações universais sobre a ANA.
