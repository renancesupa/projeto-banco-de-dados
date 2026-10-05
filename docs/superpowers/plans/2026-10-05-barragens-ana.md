# Plano de implementação do banco de barragens ANA

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Execute as tarefas em sequência com o GPT Luna, revisando cada entrega antes de seguir. Steps use checkbox (`- [ ]`) syntax for tracking.

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
- O ambiente ainda precisa ser verificado para confirmar disponibilidade do PostgreSQL e cliente SQL.

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

## Tarefa 1 — Confirmar as entradas e analisar o CSV

**Files:** criar `dados/originais/ana_barragens_hidreletricas.csv`, `scripts/01_analisar_csv.py`, `dados/analise/perfil_csv.json`, `dados/analise/mapeamento_colunas.csv` e `docs/07_checklist_avaliacao.md`.

**Interfaces:** recebe o CSV original e os nomes da equipe; produz cabeçalhos reais, número de registros, identificação da codificação e do delimitador, contagens de vazios e valores distintos. O mapeamento deve conter exatamente uma entrada por coluna original, na mesma ordem do cabeçalho.

- [ ] Obter o CSV fornecido pelo professor e os nomes dos integrantes. Procurar nos arquivos disponibilizados na sessão; se ausente, pedir o arquivo ao usuário. A ausência dos nomes não impede a análise.
- [ ] Copiar o CSV sem modificar seu conteúdo; registrar origem, data e SHA-256 no perfil. Manter a cópia original intacta.
- [ ] Identificar codificação e delimitador, testar leitura e verificar se as linhas têm a mesma quantidade de campos do cabeçalho. Falha de leitura deve interromper a carga, não ignorar linhas.
- [ ] Implementar análise com biblioteca padrão. Depois de identificar a codificação e o delimitador, usar a leitura explícita abaixo, substituindo os dois parâmetros pelos valores confirmados:

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

- [ ] Registrar 887/33 como contagens esperadas, confrontá-las com as contagens obtidas e explicar qualquer divergência. Registrar cabeçalhos duplicados se existirem; identificá-los também pela posição da coluna.
- [ ] Inspecionar identificadores repetidos, registros repetidos, campos multivalorados, coordenadas, números com vírgula/ponto e marcadores textuais de ausência. Preservar diferenças entre vazio, “não informado”, “não se aplica”, zero e “não”.
- [ ] Identificar as colunas constantes, inclusive constantes vazias. Listar o valor observado e a decisão proposta para cada uma.
- [ ] Criar a matriz de cobertura com campos `ordem_coluna`, `coluna_original`, `tabela_destino`, `coluna_destino`, `tipo`, `tratamento`, `como_reconstruir`. Completar os destinos na tarefa 2, antes de escrever DDL.
- [ ] **Aceite:** leitura completa sem linha ignorada; perfil de todas as colunas; hash registrado; entradas disponíveis. Não avançar para modelagem definitiva sem esse aceite.

## Tarefa 2 — Definir a modelagem e provar a 3FN

**Files:** criar `dados/analise/dependencias_funcionais.md`, `docs/01_modelagem.md`, `docs/02_dicionario_dados.md`, `docs/03_decisoes_dados.md`; completar `dados/analise/mapeamento_colunas.csv` e refinar este plano.

**Interfaces:** consome perfil e CSV; produz esquema definitivo, cardinalidades, PK/FK, tipos, nulidade, restrições e mapa completo de reconstrução. As tarefas 3–6 devem usar exatamente esses nomes.

- [ ] Identificar a chave de barragem na fonte. Se não for única e válida, usar uma PK artificial e manter o identificador original sem impor unicidade falsa. Preservar observações repetidas; não colapsar duas linhas só porque seus textos coincidem.
- [ ] Para cada dependência candidata `A -> B`, agrupar pelo valor de A e listar quantos valores distintos de B aparecem, sem limpar o texto original. Usar este padrão simples na análise:

```python
def conflitos_dependencia(linhas, indices_chave, indice_valor):
    grupos = {}
    for linha in linhas:
        chave = tuple(linha[i] for i in indices_chave)
        grupos.setdefault(chave, set()).add(linha[indice_valor])
    return {chave: valores for chave, valores in grupos.items()
            if len(valores) > 1}
```

- [ ] Conferir município e UF juntos: nomes de municípios podem se repetir entre estados. Só usar código de município como chave natural se existir e for confiável. Não inferir município pela grafia isolada.
- [ ] Avaliar curso d'água, região hidrográfica, comitês e unidade de gestão separadamente. Não assumir que município determina curso d'água, que nome de rio é único ou que um comitê tem uma única região. Resultado sem conflito no CSV é evidência amostral, não prova de regra universal.
- [ ] Definir entidades candidatas apenas quando sustentadas: barragem, empreendedor, UF, município, curso d'água, região hidrográfica, comitê e unidade de gestão. Manter atributos categóricos diretamente quando uma tabela só acrescentaria um ID sem benefício; justificar cada caso.
- [ ] Se houver comitês múltiplos, confirmar o delimitador real, criar relação N:N e guardar ordem/representação necessária para reconstruir a fonte. Não dividir nomes por vírgula automaticamente.
- [ ] Tratar constantes: escolher campo mantido, tabela de metadados de uma linha ou domínio adequado. Nunca eliminar silenciosamente uma coluna. Uma constante deve aparecer no mapeamento e na exportação de reconstrução.
- [ ] Tratar capacidade: manter representação original e unidade informada. Usar `NUMERIC` apenas para valores interpretáveis, com `Decimal` no apoio Python. Não assumir m³/hm³, não inferir unidade pela magnitude, não corrigir por fator 1.000.000 sem evidência. Valor convertido só se houver unidade comprovada; registrar a regra e a fonte. Preservar texto ambíguo e deixar a medida padronizada nula nesse caso.
- [ ] Aplicar a mesma preservação às outras transformações: espaços, casas decimais, coordenadas e marcadores de ausência. Guardar texto original quando necessário para reconstrução exata. Um arquivo original arquivado sozinho não comprova que o banco preserva cada informação.
- [ ] Escolher uma estratégia de rastreabilidade: número da linha em registro de origem ligado à entidade, ou chave que identifique cada observação. Evitar duplicar todo o CSV numa tabela persistente desnormalizada para afirmar 3FN. Staging pode ser temporário; o esquema final deve ser normalizado.
- [ ] Explicar 1FN (valores atômicos), 2FN (sem dependência parcial) e 3FN (sem dependência transitiva de atributos não chave). Para cada tabela, listar chave, dependências e por que os atributos pertencem a ela. Justificar textos originais como evidência da observação quando a transformação for ambígua ou não reversível.
- [ ] Criar diagrama Mermaid e dicionário. Preencher o destino e a reconstrução de todas as colunas e incorporar os nomes definitivos nos exemplos de consultas deste plano.
- [ ] **Aceite:** 33 colunas mapeadas, ou quantidade real documentada; nenhuma coluna omitida; cardinalidades justificadas; nenhuma dependência contradita ignorada; política de capacidade explícita; esquema pronto para DDL.

## Tarefa 3 — Escrever DDL claro e completo

**Files:** criar `sql/01_criacao.sql` e `sql/05_testes_restricoes.sql`; atualizar dicionário.

**Interfaces:** consome esquema definitivo; produz banco estruturalmente válido em PostgreSQL vazio. A carga depende de seus nomes e da ordem das FKs.

- [ ] Escrever primeiro os casos de rejeição esperados: PK repetida, FK inexistente, campo realmente obrigatório nulo, unicidade natural comprovada violada e valor inválido para um CHECK legítimo.
- [ ] Criar tabelas de referência antes das tabelas dependentes, dentro de `BEGIN;` e `COMMIT;`. Não usar `DROP DATABASE`, não apagar o banco do usuário e não esconder erros com `IF NOT EXISTS` generalizado.
- [ ] Usar `INTEGER GENERATED BY DEFAULT AS IDENTITY` para IDs artificiais e `TEXT`, `NUMERIC` e `BOOLEAN` quando representarem corretamente a fonte. Usar booleano somente com correspondência documentada de todos os valores.
- [ ] Nomear restrições e adicionar PK, FK, `NOT NULL`, `UNIQUE` e `CHECK` onde os dados e o domínio permitirem. Campos ausentes não recebem valores inventados para satisfazer `NOT NULL`.
- [ ] Coordenadas numéricas confirmadas admitem CHECK de latitude entre -90 e 90 e longitude entre -180 e 180. Se a fonte violar isso, preservar o original e documentar a anomalia antes de escolher uma representação compatível. Não excluir a linha.
- [ ] Indexar FKs usadas nas relações e filtros essenciais demonstrados pelas consultas. PK e UNIQUE já têm índice; não criar índice duplicado.
- [ ] Construir testes negativos em transações isoladas com `ROLLBACK`, executadas separadamente dos scripts de entrega. `BEGIN; ... INSERT inválido ... ROLLBACK;` deve produzir o erro esperado e deixar os dados válidos intactos.
- [ ] **Aceite:** DDL executa em banco vazio; dicionário corresponde ao SQL; restrições rejeitam seus casos negativos; dados legítimos da fonte são representáveis.

## Tarefa 4 — Gerar carga SQL autossuficiente

**Files:** criar `scripts/02_gerar_carga.py` e `sql/02_carga.sql`; atualizar `docs/03_decisoes_dados.md`.

**Interfaces:** recebe CSV e mapeamento aprovados; produz SQL com todos os valores incorporados, sem depender de Python, CSV externo ou caminho do computador durante a execução pelo professor.

- [ ] Usar `INSERT INTO tabela (colunas...) VALUES (...);`, com colunas explícitas. É suficiente para 887 registros e mais fácil de demonstrar que um fluxo de importação dependente de caminhos.
- [ ] Criar verificações do escape antes de gerar a carga. Usar o padrão abaixo para texto e ausência; números válidos devem ter serialização própria com `Decimal` e ponto decimal, sem conversão por `float`:

```python
def literal_texto(valor):
    if valor is None:
        return "NULL"
    return "'" + valor.replace("'", "''") + "'"

assert literal_texto("D'água") == "'D''água'"
assert literal_texto("") == "''"
assert literal_texto(None) == "NULL"
```

- [ ] Abrir o script com `BEGIN;` e `SET LOCAL standard_conforming_strings = on;`. Gerar arquivo UTF-8 e fechá-lo com `COMMIT;`. Não transformar vazio em NULL automaticamente; seguir a matriz e preservar o original quando a conversão perder distinções.
- [ ] Atribuir IDs determinísticos em ordem de aparição na fonte usando dicionários Python. Inserir entidades de referência primeiro, barragens/observações depois e relações N:N por último. Deduplicar apenas entidades conforme suas chaves definidas, nunca observações sem justificativa.
- [ ] Não usar `ON CONFLICT DO NOTHING` como forma de esconder duplicatas. Se inserir IDs explícitos em colunas identity, ajustar suas sequências ao maior ID após a carga.
- [ ] Gerar comentários curtos com fonte, contagem, codificação e tratamento de capacidade. Inserir comentário SQL com os nomes reais da equipe; ausência dos nomes bloqueia apenas a versão final de entrega.
- [ ] Executar a carga no banco de teste que recebeu o DDL. Corrigir erros na geração, não editar manualmente centenas de INSERTs que serão sobrescritos.
- [ ] Gerar novamente e comparar os dois resultados: mesmo CSV e mesmo mapeamento devem produzir o mesmo SQL.
- [ ] **Aceite:** apenas DDL e carga bastam para popular o banco; nenhuma linha ignorada; todas as relações e constantes são carregadas; geração reproduzível.

## Tarefa 5 — Verificar integralidade e reprodução

**Files:** criar `sql/03_validacao.sql`, `sql/06_exportacao_conferencia.sql`, `scripts/03_conferir_dados.py`, `docs/04_guia_execucao.md`, `docs/08_resultados_validacao.md` e `README.md`.

**Interfaces:** recebe banco carregado e matriz; produz exportação com as colunas originais, na ordem original e ordenada pela linha de origem, e relatório de diferenças. Banco vazio significa banco de teste dedicado, não reset destrutivo do banco de uso.

- [ ] Documentar a versão de PostgreSQL realmente usada e o cliente. Se PostgreSQL não estiver disponível, comunicar essa limitação e resolver o ambiente antes de afirmar aprovação dos testes.
- [ ] Executar em banco de teste novo, com interrupção ao primeiro erro:

```bash
psql -d barragens_ana_teste -v ON_ERROR_STOP=1 -f sql/01_criacao.sql
psql -d barragens_ana_teste -v ON_ERROR_STOP=1 -f sql/02_carga.sql
psql -d barragens_ana_teste -v ON_ERROR_STOP=1 -f sql/03_validacao.sql
```

- [ ] Explicar também o fluxo no pgAdmin: selecionar banco vazio, abrir Query Tool, executar integralmente `01_criacao.sql`, depois `02_carga.sql`, depois validação. Não incluir comandos específicos de psql nos dois scripts de entrega.
- [ ] Escrever validações de quantidade de observações, unicidade das chaves, ausência de referências órfãs, cobertura de relações N:N e campos vazios/constantes. Totais por tabela de domínio devem corresponder às chaves distintas do CSV, não necessariamente a 887.
- [ ] Construir uma consulta de reconstrução com os nomes definitivos da tarefa 2. Ela deve devolver as colunas originais na ordem do cabeçalho e cada observação na ordem original. Usar LEFT JOIN para preservar ausências; agregação ordenada apenas se houver campo multivalorado real.
- [ ] Exportar o resultado para CSV UTF-8, preservando texto vazio e NULL com convenção explícita que evite colisão com valores reais. Ler a exportação e a fonte com `csv.reader`. Comparar listas completas de linhas e células, não somente contagens:

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

- [ ] Conferir novamente o SHA-256 do CSV original. A comparação valida os campos decodificados; o hash comprova que a cópia original permaneceu byte a byte intacta.
- [ ] Executar testes negativos separadamente e registrar erro esperado/obtido, sem deixá-los dentro da carga. Registrar resultados reais e diferenças; não declarar sucesso se houver divergência.
- [ ] **Aceite:** zero diferenças entre células reconstruídas e originais; quantidades conferidas; DDL/carga sem erro; restrições verificadas; limitações resolvidas ou explicitamente registradas como impeditivas.

## Tarefa 6 — Preparar explicação e consultas simples

**Files:** criar `sql/04_consultas_treino.sql`, `docs/05_roteiro_apresentacao.md`, `docs/06_guia_consultas.md`, `apresentacao/01_resumo_apresentacao.md` e `apresentacao/02_perguntas_simuladas.md`.

**Interfaces:** consome o esquema e os resultados validados; produz consultas executáveis no banco real, explicadas em português, e roteiro coerente com as decisões efetivamente implementadas.

- [ ] Criar pelo menos dez exercícios: total de barragens; quantidade por UF; filtro por município/UF; altura com ordenação; risco e dano potencial; plano de segurança; PAE; empreendedor; região hidrográfica; comparação de duas categorias com JOIN e GROUP BY. Ajustar nomes e categorias aos dados reais, sem inventar valores como “alto” se a fonte usa outro texto.
- [ ] Cada exercício deve conter pergunta, SQL completo, resultado real resumido e explicação de cada cláusula. Exemplo inicial de sintaxe a adaptar ao esquema definitivo: `SELECT COUNT(*) AS total FROM barragem;` — contar observações em vez de entidades se a tarefa 2 identificar múltiplas observações por barragem.
- [ ] Nas perguntas sobre capacidade, separar medidas com unidade comprovada. Não ranquear valores de unidades desconhecidas como se fossem comparáveis. Acrescentar uma consulta que mostre os registros ambíguos e sua representação original.
- [ ] Ensinar ordem básica de construção: escolher tabelas e JOINs, filtro, agrupamento, agregação, ordenação e limite. Incluir erro comum de COUNT após relação N:N e explicar a diferença entre COUNT(*) e COUNT(DISTINCT id).
- [ ] Criar perguntas sem gabarito em `02_perguntas_simuladas.md`; deixar respostas no guia e no SQL de treino para permitir tentativa independente.
- [ ] Preparar roteiro sugerido de 6–8 minutos, ajustável ao tempo dado pelo professor: contexto, diagrama e dependências, restrições, carga/conferência, constantes/capacidade e consultas. Essa duração é recomendação, não exigência do documento.
- [ ] Distribuir a explicação entre os integrantes reais, garantindo que todos pratiquem SELECT, JOIN, filtro, agrupamento e ordenação. Simular duas perguntas escritas na hora, individualmente ou em dupla.
- [ ] **Aceite:** todas as consultas executam no banco real; resultados coerentes; explicação da 3FN por tabela; equipe entende a carga e consegue construir consultas sem copiar o gabarito.

## Tarefa 7 — Fechar a entrega e ensaiar

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
- Incertezas: CSV ausente, nomes dos integrantes e ambiente PostgreSQL ainda não confirmado. Nenhuma delas foi preenchida com informação inventada.
- Dependências: modelagem precede DDL; DDL precede carga; comparação precede entrega; consultas usam nomes definitivos da modelagem.
- Limite técnico desta versão: DDL completo e consultas definitivas dependem dos cabeçalhos e valores reais. A tarefa 2 deve tornar esses nomes explícitos antes de iniciar a tarefa 3.
- Estado: **plano aprovado; execução em curso pelo GPT Luna; publicação remota depende de permissão de escrita**.
