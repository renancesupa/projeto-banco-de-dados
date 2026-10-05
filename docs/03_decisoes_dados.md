# Decisões de tratamento dos dados

## Identidade e normalização geográfica

cod_snisb tem 887 valores não vazios e distintos em 887 linhas; será a chave primária natural de barragem. cod_fiscalizador também tem 887 valores distintos, mas fica sem UNIQUE porque o arquivo não documenta essa regra. O nome tem 849 valores distintos e não é chave.

registro_origem dá um id e número de linha diferentes a cada observação e liga cod_snisb à barragem. O vínculo é UNIQUE nesta carga porque cada SNISB ocorre uma vez. Se uma versão futura repetir o código, revisar a unicidade sem colapsar registros de origem.

municipio é separado por id interno e pelo par de negócio (uf_sigla, nome). Há cinco nomes de municípios em mais de uma UF e 453 pares distintos. uf contém só a sigla, pois o CSV não informa nome por extenso.

## Empreendedor, rio, região e comitês

empreendedor é dimensão própria por ter rótulos reutilizados; 26 nomes aparecem em mais de uma UF. Não se associa UF ao empreendedor.

A região hidrográfica é independente do nome do curso d’água: 22 nomes de rios aparecem em mais de uma região. Há 25 códigos de trecho com conflitos de nome e de domínio. Assim, codigo do trecho, nome do curso e domínio permanecem atributos da barragem, sem criar uma dependência código → nome/domínio. A região tem sua dimensão própria e não é inferida pelo rio.

Cada campo de comitê/unidade tem uma célula textual. Não há ponto e vírgula, barra vertical ou quebras de linha dentro desses valores. Há vírgulas internas em 25 valores de comitê estadual e três valores de unidade de gestão; são parte de nomes e não separam itens. Não se divide por vírgula. Comitê federal, comitê estadual e unidade de gestão são dimensões separadas, opcionais, e não recebem relação com região. Dois rótulos estaduais e dois de unidade de gestão aparecem em mais de uma região.

## Ausências e conversões

valor_origem armazena todos os 29.271 textos exatamente, com strings vazias como ''. Na camada de consulta, os campos opcionais vazios viram NULL: altura_terreno_m, tipo_material, fase_vida, data_autorizacao, cod_trecho_curso_dagua, dominio_curso_dagua, três vínculos de comitê/unidade e possui_pae. Nenhum valor é inventado.

Códigos e numero_autorizacao ficam TEXT. Alturas em metros e coordenadas são NUMERIC alimentados por Decimal. Datas no padrão ISO são DATE. Valores true/false são BOOLEAN; em possui_pae, vazio vira NULL. Proveniência retém a grafia e formatação originais.

## Capacidade

Há 887 valores de capacidade em formato numérico simples, mas o arquivo não possui coluna de unidade. Nenhum valor é convertido nem recebe unidade inferida. capacidade_reservatorio_texto preserva a representação e capacidade_reservatorio_padronizada fica NULL em todas as linhas até uma fonte confiável comprovar a unidade e permitir registrar a regra.

## Constantes e categorias

uso_principal = Hidroelétrica, regulada_pnsb = true, orgao_fiscalizador = Agência Nacional de Energia Elétrica - ANEEL, barragem_autuada = false e completude_cadastro = boa são constantes desta amostra. Permanecem como colunas de barragem e como valores exatos em valor_origem; não viram restrições permanentes nem são descartadas.

Categorias simples como fase_vida, tipo_material, dominio_curso_dagua, categoria_risco e dano_potencial_associado ficam TEXT; dimensões de palavras acrescentariam IDs sem benefício claro para as consultas simples.
