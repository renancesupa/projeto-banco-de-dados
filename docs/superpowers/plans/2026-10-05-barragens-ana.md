# Plano de implementação do banco de barragens ANA

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task, with GPT Luna as implementer and a separate review after each task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** entregar um banco PostgreSQL em 3FN, totalmente populado a partir do CSV da ANA, com scripts SQL reproduzíveis e material para explicar a modelagem e escrever consultas na apresentação.

**Architecture:** analisar o CSV, registrar dependências funcionais, modelar as relações e gerar DDL e carga SQL. Usar Python apenas como apoio à análise e à geração de INSERTs; o professor deve conseguir criar e popular o banco executando somente os dois scripts SQL. Guardar o arquivo original e verificar a correspondência de cada célula com o banco.

**Tech Stack:** PostgreSQL, SQL simples e Python com biblioteca padrão (`csv`, `json`, `decimal`, `hashlib`, `pathlib`); editor SQL disponível, como pgAdmin, e `psql` para verificação quando disponível. Sem ORM, aplicação web, Docker obrigatório, PostGIS, APIs ou frameworks.

**Spec:** `docs/referencias/enunciado_barragens_ana.txt`, transcrição textual do DOCX fornecido, e este plano. O DOCX original permanece a referência principal:
`docs/referencias/enunciado_barragens_ana.txt` (transcrição local do DOCX).

## Situação e autorização

- Planejamento preparado em 05/10/2026. Apresentação considerada em 08/10/2026, quinta-feira, conforme o pedido do usuário; o enunciado não fornece uma data.
- O usuário aprovou o plano, forneceu o CSV e informou a equipe. A implementação foi encaminhada ao GPT Luna.
- O CSV real tem 887 registros, 33 colunas, delimitador vírgula e nenhuma linha malformada. SHA-256: `ae9f20fc1e084ed48a0187f7cfba648c71a7a13f8fa13379cbe1df32be029aef`.
- Equipe: Alexandre Arthur, Enrique Luis e Renan Gomes.
- O repositório remoto `renancesupa/projeto-banco-de-dados` existe, mas está vazio. A conexão GitHub informa `push: false`; o trabalho está sendo preparado no clone local, em um branch novo, e a publicação aguarda uma conexão com permissão de escrita.
- PostgreSQL 18.4 está instalado em `/Library/PostgreSQL/18/bin`; o serviço não está respondendo na porta padrão. Pode-se iniciar um cluster de teste isolado em `/private/tmp` para validar os scripts sem tocar em bancos do usuário.

## Global Constraints

Exigências do enunciado, com os valores preservados:

- “Atividade avaliativa em equipes (até 4 pessoas)”.
- “887 barragens” e “33 colunas”. Conferir com o CSV real; se houver divergência, registrá-la e preservar todas as linhas recebidas, sem fabricar ou descartar registros para ajustar a contagem.
- “Projetar e implementar um banco de dados em PostgreSQL”.
- “normalizado até a 3ª Forma Normal e totalmente populado, sem perda de nenhuma informação da planilha original”.
- “Analisem as dependências entre elas antes de decidir as tabelas.”
- “Algumas colunas têm o mesmo valor em todas as linhas. Discutam se elas devem virar tabela, virar constante ou ser mantidas, e justifiquem.”
- “A coluna de capacidade do reservatório tem inconsistências de unidade na fonte oficial. Registrem o problema e expliquem como o trataram.”
- DDL: “chaves primárias e estrangeiras, restrições (NOT NULL, UNIQUE, CHECK) e índices essenciais”.
- Carga: “É permitido usar Python ou Excel como apoio, mas a entrega deve ser um script SQL executável.”
- Apresentação: “O professor fará 2 perguntas sobre os dados. Cada aluno, individualmente ou em dupla, responderá com uma consulta SQL escrita na hora.”
- Entrega: DDL completo, script de carga “(INSERT ou COPY)” a partir do zero e “Um comentário na entrega informando os membros da equipe”.
- “Os scripts devem rodar em sequência, em um banco vazio, sem erros.”
- Explicar “por que cada tabela existe, como as dependências foram eliminadas e como os dados foram carregados”.

Regras do usuário e do workspace:

- Código simples, em português nos identificadores quando possível, sem acentos e com `snake_case`.
- Preferir `SELECT`, `JOIN`, `WHERE`, `GROUP BY`, `ORDER BY`, agregações e subconsultas curtas. Não introduzir triggers, procedures ou funções SQL sem necessidade demonstrada.
- Um arquivo tem uma responsabilidade. SQL com comentários curtos explicando decisões.
- Não alterar, renomear, mover ou apagar arquivos em `sources/`, nem modificar o DOCX original.
- Trabalhar na raiz deste workspace. Copiar entradas para `dados/originais/` somente durante a execução aprovada.
- Não enviar mensagens para terceiros. Não publicar alterações no GitHub sem uma conexão com escrita; entregar o branch e solicitar a publicação após tornar as mudanças revisáveis.

## Critérios e evidências

| Critério | Pontos | Evidência de atendimento | Tarefas |
|---|---:|---|---|
| DDL e 3FN | 1,5 | `sql/01_criacao.sql`, dependências, diagrama e testes de restrições | 2, 3, 5 |
| Carga completa | 1,0 | `sql/02_carga.sql`, mapeamento das 33 colunas e comparação célula a célula | 1, 4, 5 |
| Consultas ao vivo | 1,5 | treino individual ou em dupla e simulação de duas perguntas | 6, 7 |
| Integrantes | exigência de entrega | comentário SQL com nomes reais de até quatro pessoas | 1, 7 |
| Decisões de modelagem | exigência da apresentação | explicação por tabela, dependências, constantes e capacidade | 2, 6 |
| Execução em banco vazio | exigência de entrega | duas execuções completas, cada uma em banco de teste novo | 5, 7 |

O treino apoia a preparação; a nota das consultas depende da execução dos alunos durante a apresentação.

## Estrutura final dos arquivos

Criar os arquivos de cada tarefa apenas quando ela começar. Os únicos arquivos produzidos agora são este plano e a transcrição de referência.

```text
projeto-barragens-ana/                 # raiz interna do pacote ZIP final
  README.md                          # ordem de execução e mapa dos arquivos
  dados/
    originais/
      ana_barragens_hidreletricas.csv  # cópia intacta do CSV recebido
    analise/
      perfil_csv.json                # contagens, cabeçalho e valores distintos
      dependencias_funcionais.md     # evidências e regras da modelagem
      mapeamento_colunas.csv         # origem, destino e tratamento de cada coluna
  scripts/
    01_analisar_csv.py                # análise sem modificar a origem
    02_gerar_carga.py                 # geração dos INSERTs finais
    03_conferir_dados.py              # comparação original x exportação do banco
  sql/
    01_criacao.sql                    # somente criação do esquema e objetos
    02_carga.sql                      # somente carga completa e transacional
    03_validacao.sql                  # verificações de integridade e contagem
    04_consultas_treino.sql           # exemplos comentados para aprender
    05_testes_restricoes.sql          # violações deliberadas, só para banco de teste
    06_exportacao_conferencia.sql     # reconstrução das 33 colunas para comparação
  docs/
    referencias/
      enunciado_barragens_ana.txt
    superpowers/plans/
      2026-10-05-barragens-ana.md
    01_modelagem.md                   # regras, 3FN e diagrama Mermaid
    02_dicionario_dados.md            # tipos, chaves, nulidade e descrição
    03_decisoes_dados.md              # constantes, unidades e valores ausentes
    04_guia_execucao.md               # execução pelo pgAdmin e pelo psql
    05_roteiro_apresentacao.md        # fala e demonstração
    06_guia_consultas.md              # exercícios e gabarito explicado
    07_checklist_avaliacao.md         # cobertura de cada exigência
    08_resultados_validacao.md        # ambiente, comandos, resultados e limites
  apresentacao/
    01_resumo_apresentacao.md         # resumo para abrir durante a apresentação
    02_perguntas_simuladas.md         # perguntas para treino sem olhar respostas
  entrega/
    01_criacao.sql                    # cópia final verificada
    02_carga.sql                      # cópia final verificada
    LEIA_ME.md                       # integrantes e instruções breves
```

Durante o desenvolvimento, usar as pastas diretamente na raiz do workspace. Criar o pacote `projeto-barragens-ana.zip` apenas no fechamento, preservando essa árvore e excluindo arquivos temporários, credenciais e dumps de teste. Não criar cópias divergentes: atualizar `entrega/` somente após validar os arquivos canônicos em `sql/`.

## Padrão de execução para GPT Luna

1. Ler a referência e o plano antes de editar qualquer arquivo.
2. Executar uma tarefa por vez, na ordem. Marcar as caixas somente com evidência real.
3. Cada passo corresponde a uma ação curta; dividir em passos menores quando levar mais de cinco minutos.
4. Informar o que concluiu, os resultados e a próxima tarefa. Se faltar uma entrada indispensável, solicitar apenas essa entrada e avançar no trabalho independente.
5. Registrar decisões técnicas justificadas nos arquivos indicados. Não substituir o CSV por dados inventados ou por outro dataset.
6. Depois da análise, atualizar neste plano os nomes exatos de tabelas, colunas, tipos e exemplos SQL usados nas tarefas seguintes. Isso é refinamento com dados reais, não autorização para mudar o escopo.
7. Sem CSV real não há declaração de “projeto completo”. Sem PostgreSQL executado não há declaração de “scripts testados”.
8. Se houver repositório Git existente, fazer um commit local por tarefa concluída, incluindo apenas os arquivos daquela tarefa. Não criar repositório nem enviar alterações remotamente só por exigência da skill.

### Task 1 — Confirmar as entradas e analisar o CSV

**Files:** criar `dados/originais/ana_barragens_hidreletricas.csv`, `scripts/01_analisar_csv.py`, `dados/analise/perfil_csv.json`, `dados/analise/mapeamento_colunas.csv` e `docs/07_checklist_avaliacao.md`.

**Interfaces:** recebe o CSV original e os nomes da equipe; produz cabeçalhos reais, número de registros, identificação da codificação e do delimitador, contagens de vazios e valores distintos. O mapeamento deve conter exatamente uma entrada por coluna original, na mesma ordem do cabeçalho.

- [x] Obter o CSV fornecido pelo professor e os nomes dos integrantes. Procurar nos arquivos disponibilizados na sessão; se ausente, pedir o arquivo ao usuário. A ausência dos nomes não impede a análise.
- [x] Copiar o CSV sem modificar seu conteúdo; registrar origem, data e SHA-256 no perfil. Manter a cópia original intacta.
- [x] Identificar codificação e delimitador, testar leitura e verificar se as linhas têm a mesma quantidade de campos do cabeçalho. Falha de leitura deve interromper a carga, não ignorar linhas.
- [x] Implementar análise com biblioteca padrão. Depois de identificar a codificação e o delimitador, usar a leitura explícita abaixo, substituindo os dois parâmetros pelos valores confirmados:

```python
import csv
from pathlib import Path

def ler_csv(caminho, codificacao, delimitador):
    with Path(caminho).open(encoding=codificacao, newline="") as arquivo:
        leitor = csv.reader(arquivo, delimiter=delimitador)
        cabecalho = next(leitor)
        linhas = list(leitor)
    for numero, linha in enumerate(linhas, start=2):
        if len(linha) != len(cabecalho):
            raise ValueError(f"Linha {numero}: quantidade de colunas incorreta")
    return cabecalho, linhas

def resumir_coluna(linhas, indice):
    valores = [linha[indice] for linha in linhas]
    return {
        "vazios": sum(valor == "" for valor in valores),
        "valores_distintos": sorted(set(valores)),
    }
```

- [x] Registrar 887/33 como contagens esperadas, confrontá-las com as contagens obtidas e explicar qualquer divergência. Registrar cabeçalhos duplicados se existirem; identificá-los também pela posição da coluna.
- [x] Inspecionar identificadores repetidos, registros repetidos, campos multivalorados, coordenadas, números com vírgula/ponto e marcadores textuais de ausência. Preservar diferenças entre vazio, “não informado”, “não se aplica”, zero e “não”.
- [x] Identificar as colunas constantes, inclusive constantes vazias. Listar o valor observado e a decisão proposta para cada uma.
- [x] Criar a matriz de cobertura com campos `ordem_coluna`, `coluna_original`, `tabela_destino`, `coluna_destino`, `tipo`, `tratamento`, `como_reconstruir`. Completar os destinos na tarefa 2, antes de escrever DDL.
- [x] **Aceite:** leitura completa sem linha ignorada; perfil de todas as colunas; hash registrado; entradas disponíveis. Não avançar para modelagem definitiva sem esse aceite.

### Task 2 — Definir a modelagem e provar a 3FN

**Files:** criar dados/analise/dependencias_funcionais.md, docs/01_modelagem.md, docs/02_dicionario_dados.md, docs/03_decisoes_dados.md; completar dados/analise/mapeamento_colunas.csv.

**Interfaces:** consome perfil e CSV; fixa nomes, chaves, FKs, tipos, nulidade e reconstrução. Tarefas 3–6 devem usar exatamente este esquema.

**Esquema definitivo:** dimensões uf(sigla), municipio(id_municipio, uf_sigla, nome), empreendedor(id_empreendedor, nome), regiao_hidrografica(id_regiao_hidrografica, nome), comite_federal(id_comite_federal, nome), comite_estadual(id_comite_estadual, nome) e unidade_gestao(id_unidade_gestao, nome). municipio referencia uf.sigla e tem UNIQUE(uf_sigla, nome). Cada dimensão de rótulo usa chave identity e nome UNIQUE.

barragem usa cod_snisb TEXT como PK. Colunas: cod_fiscalizador, nome, altura_fundacao_m, altura_terreno_m, capacidade_reservatorio_texto, capacidade_reservatorio_padronizada, data_cadastro, tipo_material, uso_principal, latitude, longitude, regulada_pnsb, id_empreendedor, id_municipio, fase_vida, orgao_fiscalizador, numero_autorizacao, data_autorizacao, id_regiao_hidrografica, cod_trecho_curso_dagua, curso_dagua, dominio_curso_dagua, id_comite_federal, id_comite_estadual, id_unidade_gestao, possui_pae, possui_plano_seguranca, possui_revisao_periodica, categoria_risco, dano_potencial_associado, barragem_autuada e completude_cadastro. Tipos e nulidade constam no dicionário.

Procedência: registro_origem(id_registro PK, numero_linha UNIQUE NOT NULL, cod_snisb FK UNIQUE NOT NULL); campo_origem(ordem_coluna PK, nome_original UNIQUE NOT NULL); valor_origem(id_registro FK, ordem_coluna FK, valor_original TEXT NOT NULL, PK(id_registro, ordem_coluna)). registro_origem.cod_snisb referencia barragem.cod_snisb. Não criar tabela-ponte. Strings vazias ficam como '' em valor_origem. As 887 linhas recebem id_registro independente.

- [x] Identificar cod_snisb como chave natural: 887 valores não vazios e distintos. Preservar cada linha por id_registro e numero_linha.
- [x] Agrupar dependências com texto literal: municipio→UF tem 5 conflitos; cod_trecho→nome/domínio, 25; curso→região, 22; empreendedor→UF, 26; rótulos de comitê/unidade cruzam regiões. Evidências em dados/analise/dependencias_funcionais.md.
- [x] Modelar municipio com UF; manter curso, código e domínio em barragem e região separada. Não inferir município pelo nome nem região pelo rio.
- [x] Comitês são células escalares sem delimitador de lista confirmado; não dividir vírgulas em nomes. Manter FKs opcionais para comitê federal, comitê estadual e unidade.
- [x] Manter as cinco colunas constantes em barragem; não descartar nem criar restrições que generalizem a amostra.
- [x] Manter capacidade como texto; capacidade_reservatorio_padronizada NUMERIC fica NULL sem unidade comprovada.
- [x] Preservar textos em valor_origem; números tipados usam Decimal, datas ISO tornam-se DATE e true/false tornam-se BOOLEAN. Original preserva zeros, espaços e grafia.
- [x] Confirmar 887 × 33 = 29.271 células no CSV. Tarefa 4 carrega e Tarefa 5 compara as 29.271 células do banco.
- [x] Produzir diagrama Mermaid, dicionário, decisões e mapa de 33 colunas com destino e regra de reconstrução.
- [x] Aceite de modelagem: nenhuma coluna omitida; cardinalidades e conflitos documentados; capacidade tratada; nomes prontos para DDL.

### Task 3 — Escrever DDL claro e completo

**Files:** criar `sql/01_criacao.sql` e `sql/05_testes_restricoes.sql`; atualizar dicionário.

**Interfaces:** consome esquema definitivo; produz banco estruturalmente válido em PostgreSQL vazio. A carga depende de seus nomes e da ordem das FKs.

- [x] Escrever primeiro os casos de rejeição esperados: PK repetida, FK inexistente, campo realmente obrigatório nulo, unicidade natural comprovada violada e valor inválido para um CHECK legítimo. Os cinco testes deram RED por objetos ausentes no banco descartável vazio e depois rejeitaram os casos pelas restrições esperadas.
- [x] Criar nesta ordem: uf, municipio, empreendedor, regiao_hidrografica, comite_federal, comite_estadual, unidade_gestao, barragem, registro_origem, campo_origem e valor_origem; usar BEGIN e COMMIT.
- [x] Implementar registro_origem(id_registro, numero_linha, cod_snisb), campo_origem(ordem_coluna, nome_original) e valor_origem(id_registro, ordem_coluna, valor_original) exatamente como na Tarefa 2; cod_snisb referencia barragem e a PK composta impede célula duplicada.
- [x] Usar `INTEGER GENERATED BY DEFAULT AS IDENTITY` para IDs artificiais e `TEXT`, `NUMERIC` e `BOOLEAN` quando representarem corretamente a fonte. Usar booleano somente com correspondência documentada de todos os valores.
- [x] Nomear restrições e adicionar PK, FK, `NOT NULL`, `UNIQUE` e `CHECK` onde os dados e o domínio permitirem. Campos ausentes não recebem valores inventados para satisfazer `NOT NULL`.
- [x] Coordenadas numéricas confirmadas admitem CHECK de latitude entre -90 e 90 e longitude entre -180 e 180. A fonte não viola esses limites; os textos originais seguem preservados na proveniência. Não excluir linha.
- [x] Indexar FKs usadas nas relações e filtros essenciais demonstrados pelas consultas. PK e UNIQUE já têm índice; não criar índice duplicado.
- [x] Construir testes negativos em transações isoladas com `ROLLBACK`, executadas separadamente dos scripts de entrega. `BEGIN; ... INSERT inválido ... ROLLBACK;` produziu cada erro esperado e deixou as tabelas de teste sem linhas.
- [x] **Aceite:** DDL executa em banco vazio; dicionário corresponde ao SQL; restrições rejeitam seus casos negativos; dados legítimos da fonte são representáveis.

### Task 4 — Gerar carga SQL autossuficiente

**Files:** criar `scripts/02_gerar_carga.py` e `sql/02_carga.sql`; atualizar `docs/03_decisoes_dados.md`.

**Interfaces:** recebe CSV e mapeamento aprovados; produz SQL com todos os valores incorporados, sem depender de Python, CSV externo ou caminho do computador durante a execução pelo professor.

- [x] Usar `INSERT INTO tabela (colunas...) VALUES (...);`, com colunas explícitas. É suficiente para 887 registros e mais fácil de demonstrar que um fluxo de importação dependente de caminhos.
- [x] Gerar 887 linhas de origem, 33 definições de campo e exatamente 29.271 valores de origem, incluindo todos os campos vazios. A carga deve preservar os 33 textos originais como strings CSV.
- [x] Criar verificações do escape antes de gerar a carga. Usar o padrão abaixo para texto e ausência; números válidos devem ter serialização própria com `Decimal` e ponto decimal, sem conversão por `float`:

```python
def literal_texto(valor):
    if valor is None:
        return "NULL"
    return "'" + valor.replace("'", "''") + "'"

assert literal_texto("D'água") == "'D''água'"
assert literal_texto("") == "''"
assert literal_texto(None) == "NULL"
```

- [x] Abrir o script com `BEGIN;` e `SET LOCAL standard_conforming_strings = on;`. Gerar arquivo UTF-8 e fechá-lo com `COMMIT;`. Não transformar vazio em NULL automaticamente; seguir a matriz e preservar o original quando a conversão perder distinções.
- [x] Atribuir IDs determinísticos em ordem de aparição usando dicionários Python. Inserir dimensões, barragem, registro_origem, campo_origem e valor_origem, nessa ordem. Deduplicar dimensões conforme suas chaves e manter um id_registro por linha.
- [x] Não usar `ON CONFLICT DO NOTHING` como forma de esconder duplicatas. Se inserir IDs explícitos em colunas identity, ajustar suas sequências ao maior ID após a carga.
- [x] Gerar comentários curtos com fonte, contagem, codificação e tratamento de capacidade. Inserir comentário SQL com os nomes reais da equipe; ausência dos nomes bloqueia apenas a versão final de entrega.
- [x] Executar a carga no banco de teste que recebeu o DDL. Corrigir erros na geração, não editar manualmente centenas de INSERTs que serão sobrescritos.
- [x] Gerar novamente e comparar os dois resultados: mesmo CSV e mesmo mapeamento devem produzir o mesmo SQL.
- [x] **Aceite:** apenas DDL e carga bastam para popular o banco; nenhuma linha ignorada; todas as relações e constantes são carregadas; geração reproduzível.

### Task 5 — Verificar integralidade e reprodução

**Files:** criar `sql/03_validacao.sql`, `sql/06_exportacao_conferencia.sql`, `scripts/03_conferir_dados.py`, `docs/04_guia_execucao.md`, `docs/08_resultados_validacao.md` e `README.md`.

**Interfaces:** recebe banco carregado e matriz; produz exportação com as colunas originais, na ordem original e ordenada pela linha de origem, e relatório de diferenças. Banco vazio significa banco de teste dedicado, não reset destrutivo do banco de uso.

- [x] Documentar PostgreSQL 18.4 e `psql` 18.4, confirmados durante a validação.
- [x] Executar em banco de teste novo, com interrupção ao primeiro erro (instância isolada em `127.0.0.1:55432`):

```bash
  psql -h 127.0.0.1 -p 55432 -d barragens_ana_t5_keys -v ON_ERROR_STOP=1 -f sql/01_criacao.sql
  psql -h 127.0.0.1 -p 55432 -d barragens_ana_t5_keys -v ON_ERROR_STOP=1 -f sql/02_carga.sql
  psql -h 127.0.0.1 -p 55432 -d barragens_ana_t5_keys -v ON_ERROR_STOP=1 -f sql/03_validacao.sql
```

- [x] Explicar o fluxo no pgAdmin: selecionar banco vazio, abrir Query Tool, executar integralmente criação, carga e validação nesta ordem. Os scripts de entrega não contêm comandos específicos de psql.
- [x] Validar 887 barragens, 887 registros de origem, 33 campos e 29.271 células, unicidade das chaves, todas as FKs sem órfãos e perfil de vazios/constantes. Os distintos excluem vazios.
- [x] Reconstruir com `registro_origem`, `valor_origem` e `campo_origem`, preservando cabeçalhos/ordem, texto literal, vazios e ordem de linha; comparar todas as células.
- [x] Exportar para CSV UTF-8 com marcador de NULL verificado contra a fonte. O comparador lê exportação e fonte com `csv.reader` e compara cabeçalho, linhas e cada célula. Duas rodadas produziram zero diferenças; detalhes e hash em `docs/08_resultados_validacao.md`. A comparação integral segue este padrão:

```python
def comparar(cabecalho_original, linhas_originais,
             cabecalho_exportado, linhas_exportadas):
    if cabecalho_original != cabecalho_exportado:
        raise ValueError("Cabecalhos diferentes")
    if len(linhas_originais) != len(linhas_exportadas):
        raise ValueError("Quantidades de linhas diferentes")
    diferencas = []
    for numero, (original, exportada) in enumerate(
            zip(linhas_originais, linhas_exportadas), start=2):
        if len(original) != len(exportada):
            raise ValueError(f"Linha {numero}: numero de campos diferente")
        for coluna, (antes, depois) in enumerate(zip(original, exportada)):
            if antes != depois:
                diferencas.append((numero, cabecalho_original[coluna],
                                   antes, depois))
    return diferencas
```

- [x] Conferir SHA-256 antes/depois; a fonte permaneceu byte a byte intacta.
- [x] Executar teste negativo separado e registrar retorno e diferença; não houve divergência nas rodadas válidas.
- [x] **Aceite:** zero diferenças nas duas rodadas; quantidades conferidas; DDL/carga sem erro; restrições verificadas. Evidências em `docs/08_resultados_validacao.md`.

### Task 6 — Preparar explicação e consultas simples

**Files:** criar `sql/04_consultas_treino.sql`, `docs/05_roteiro_apresentacao.md`, `docs/06_guia_consultas.md`, `apresentacao/01_resumo_apresentacao.md` e `apresentacao/02_perguntas_simuladas.md`.

**Interfaces:** consome o esquema e os resultados validados; produz consultas executáveis no banco real, explicadas em português, e roteiro coerente com as decisões efetivamente implementadas.

- [ ] Criar pelo menos dez exercícios com o esquema definitivo: total em barragem; contagem por uf via municipio; filtro por municipio.nome e uf.sigla; alturas; risco/dano; plano; PAE; empreendedor; regiao_hidrografica; comparação de categorias com JOIN e GROUP BY. Ajustar categorias aos dados reais.
- [ ] Cada exercício deve conter pergunta, SQL completo, resultado real resumido e explicação de cada cláusula. Exemplo inicial de sintaxe a adaptar ao esquema definitivo: `SELECT COUNT(*) AS total FROM barragem;` — contar observações em vez de entidades se a tarefa 2 identificar múltiplas observações por barragem.
- [ ] Para capacidade, consultar barragem.capacidade_reservatorio_texto e capacidade_reservatorio_padronizada; esta fica NULL enquanto unidade não for confirmada. Não comparar ou ranquear como medida conhecida.
- [ ] Ensinar ordem básica de construção: escolher tabelas e JOINs, filtro, agrupamento, agregação, ordenação e limite. Incluir erro comum de COUNT após JOIN com proveniência 1:N: COUNT(*) conta células e COUNT(DISTINCT b.cod_snisb) conta barragens.
- [ ] Criar perguntas sem gabarito em `02_perguntas_simuladas.md`; deixar respostas no guia e no SQL de treino para permitir tentativa independente.
- [ ] Preparar roteiro sugerido de 6–8 minutos, ajustável ao tempo dado pelo professor: contexto, diagrama e dependências, restrições, carga/conferência, constantes/capacidade e consultas. Essa duração é recomendação, não exigência do documento.
- [ ] Distribuir a explicação entre os integrantes reais, garantindo que todos pratiquem SELECT, JOIN, filtro, agrupamento e ordenação. Simular duas perguntas escritas na hora, individualmente ou em dupla.
- [ ] Exemplos com nomes finais: SELECT COUNT(*) AS total FROM barragem; e SELECT u.sigla, COUNT(*) FROM barragem b JOIN municipio m ON m.id_municipio = b.id_municipio JOIN uf u ON u.sigla = m.uf_sigla GROUP BY u.sigla ORDER BY COUNT(*) DESC.
- [ ] **Aceite:** todas as consultas executam no banco real; resultados coerentes; explicação da 3FN por tabela; equipe entende a carga e consegue construir consultas sem copiar o gabarito.

### Task 7 — Fechar a entrega e ensaiar

**Files:** criar `entrega/01_criacao.sql`, `entrega/02_carga.sql`, `entrega/LEIA_ME.md` e `projeto-barragens-ana.zip`; atualizar checklist, README e resultados.

**Interfaces:** recebe arquivos canônicos aprovados; produz pacote final organizado com instruções e comentário de integrantes. Nenhum arquivo de teste negativo faz parte da sequência obrigatória de entrega.

- [ ] Verificar que há nomes reais de até quatro integrantes no comentário SQL. Não finalizar o pacote com nomes genéricos ou campos em branco.
- [ ] Copiar os dois scripts de `sql/` para `entrega/` e confirmar que são idênticos às versões validadas.
- [ ] Executar essas cópias em um segundo banco de teste novo. Confirmar que não dependem do CSV, de Python, de caminho absoluto, do banco anterior ou de extensão não instalada.
- [ ] Atualizar o checklist critério por critério com caminhos e resultados. Registrar contagens reais, zero diferenças de reconstrução e tratamento da capacidade.
- [ ] Criar `LEIA_ME.md` com nomes, PostgreSQL utilizado e ordem de execução. Separar claramente entrega obrigatória e material auxiliar de treino/documentação.
- [ ] Criar o ZIP organizado e conferir o conteúdo. Incluir original, scripts, documentação e apresentação; excluir temporários, credenciais, dependências e ambientes locais.
- [ ] Ensaiar a abertura dos arquivos e o roteiro em ambiente disponível na apresentação. Manter o SQL de entrega acessível separadamente do ZIP.
- [ ] **Aceite final:** duas execuções completas em bancos vazios; integralidade comprovada; nomes reais; arquivos organizados; duas perguntas simuladas por aluno ou dupla; nenhum requisito obrigatório pendente.

## Cronograma até quinta-feira

| Data | Prioridade | Resultado necessário |
|---|---|---|
| Segunda, 05/10 | Aprovar plano, trocar para Luna, obter CSV e integrantes; tarefas 1–2 | análise e esquema definitivo |
| Terça, 06/10 | tarefas 3–5 | DDL, carga e verificação integral |
| Quarta, 07/10 | tarefas 6–7 | treino, pacote e ensaio completo |
| Quinta, 08/10 | revisar roteiro e testar acesso antes da aula | apresentação e consultas ao vivo |

Se o CSV chegar tarde, priorizar DDL, carga, conferência e treino. Reduzir acabamento do material auxiliar; nunca reduzir preservação dos dados, 3FN ou verificação dos scripts.

## Revisão deste planejamento

- Cobertura: todas as exigências explícitas do enunciado têm tarefa e evidência na matriz.
- Incertezas: serviço PostgreSQL não está ativo; executar a verificação numa instância isolada de teste. A publicação do branch depende da permissão de escrita no GitHub.
- Dependências: modelagem precede DDL; DDL precede carga; comparação precede entrega; consultas usam nomes definitivos da modelagem.
- Limite técnico desta versão: DDL completo e consultas definitivas dependem dos cabeçalhos e valores reais. A tarefa 2 deve tornar esses nomes explícitos antes de iniciar a tarefa 3.
- Estado: **plano aprovado; execução em curso pelo GPT Luna; publicação remota depende de permissão de escrita**.
