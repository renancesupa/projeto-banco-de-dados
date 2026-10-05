#!/usr/bin/env python3
"""Gera a carga SQL autossuficiente das barragens da ANA."""

import argparse
import csv
from datetime import date
from decimal import Decimal, InvalidOperation
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CSV_PADRAO = ROOT / "dados/originais/ana_barragens_hidreletricas.csv"
MAPA_PADRAO = ROOT / "dados/analise/mapeamento_colunas.csv"
SQL_PADRAO = ROOT / "sql/02_carga.sql"
EQUIPE = "Alexandre Arthur, Enrique Luis e Renan Gomes"


def literal_texto(valor):
    if valor is None:
        return "NULL"
    return "'" + valor.replace("'", "''") + "'"


def literal_decimal(valor):
    try:
        numero = Decimal(valor)
    except InvalidOperation as erro:
        raise ValueError(f"Número inválido: {valor!r}") from erro
    if not numero.is_finite():
        raise ValueError(f"Número não finito: {valor!r}")
    return format(numero, "f")


def literal_data(valor):
    try:
        return literal_texto(date.fromisoformat(valor).isoformat())
    except ValueError as erro:
        raise ValueError(f"Data ISO inválida: {valor!r}") from erro


def ler_entradas(caminho_csv, caminho_mapa):
    with caminho_csv.open(encoding="utf-8-sig", newline="") as arquivo:
        leitor = csv.DictReader(arquivo)
        cabecalhos = leitor.fieldnames
        linhas = list(leitor)
    with caminho_mapa.open(encoding="utf-8-sig", newline="") as arquivo:
        mapa = list(csv.DictReader(arquivo))
    if len(linhas) != 887 or len(cabecalhos or []) != 33 or len(mapa) != 33:
        raise ValueError("Esperados 887 registros e 33 colunas mapeadas")
    if [item["coluna_original"] for item in mapa] != cabecalhos:
        raise ValueError("Cabeçalhos CSV e mapa de colunas divergem")
    for numero_linha, linha in enumerate(linhas, start=2):
        faltantes = [campo for campo in cabecalhos if linha.get(campo) is None]
        extras = linha.get(None, [])
        if faltantes or extras:
            quantidade = len(cabecalhos) - len(faltantes) + len(extras)
            raise ValueError(
                f"Registro {numero_linha} tem {quantidade} colunas; "
                f"esperado {len(cabecalhos)}"
            )
    return cabecalhos, linhas, mapa


def inserir(tabela, colunas, valores):
    nomes = ", ".join(colunas)
    return f"INSERT INTO {tabela} ({nomes}) VALUES ({', '.join(valores)});"


def id_dimensao(dic, chave):
    if chave not in dic:
        dic[chave] = len(dic) + 1
    return dic[chave]


def gerar_sql(caminho_csv=CSV_PADRAO, caminho_mapa=MAPA_PADRAO):
    caminho_csv, caminho_mapa = Path(caminho_csv), Path(caminho_mapa)
    cabecalhos, linhas, mapa = ler_entradas(caminho_csv, caminho_mapa)
    assert literal_texto("D'água") == "'D''água'"
    assert literal_texto("") == "''"
    assert literal_texto(None) == "NULL"

    ufs, municipios, empreendedores = {}, {}, {}
    regioes, comites_federais, comites_estaduais, unidades = {}, {}, {}, {}
    barragens = []
    for linha in linhas:
        uf = linha["uf"]
        ufs.setdefault(uf, None)
        id_municipio = id_dimensao(municipios, (uf, linha["municipio"]))
        id_empreendedor = id_dimensao(empreendedores, linha["empreendedor"])
        id_regiao = id_dimensao(regioes, linha["regiao_hidrografica"])
        id_cf = id_dimensao(comites_federais, linha["comite_federal"]) if linha["comite_federal"] else None
        id_ce = id_dimensao(comites_estaduais, linha["comite_estadual"]) if linha["comite_estadual"] else None
        id_unidade = id_dimensao(unidades, linha["unidade_gestao"]) if linha["unidade_gestao"] else None
        barragens.append((linha, id_municipio, id_empreendedor, id_regiao, id_cf, id_ce, id_unidade))

    saida = [
        "BEGIN;",
        "SET LOCAL standard_conforming_strings = on;",
        "-- Fonte: dados.originais/ana_barragens_hidreletricas.csv (UTF-8).",
        "-- 887 registros, 33 campos e 29.271 células originais; vazios preservados como ''.",
        "-- Capacidade mantida como texto; valor padronizado NULL por ausência de unidade comprovada.",
        f"-- Equipe: {EQUIPE}.",
    ]
    saida.extend(inserir("uf", ["sigla"], [literal_texto(v)]) for v in ufs)
    saida.extend(
        inserir(
            "municipio",
            ["id_municipio", "uf_sigla", "nome"],
            [str(i), literal_texto(k[0]), literal_texto(k[1])],
        )
        for k, i in municipios.items()
    )
    saida.extend(
        inserir("empreendedor", ["id_empreendedor", "nome"], [str(i), literal_texto(k)])
        for k, i in empreendedores.items()
    )
    saida.extend(
        inserir(
            "regiao_hidrografica",
            ["id_regiao_hidrografica", "nome"],
            [str(i), literal_texto(k)],
        )
        for k, i in regioes.items()
    )
    saida.extend(
        inserir("comite_federal", ["id_comite_federal", "nome"], [str(i), literal_texto(k)])
        for k, i in comites_federais.items()
    )
    saida.extend(
        inserir("comite_estadual", ["id_comite_estadual", "nome"], [str(i), literal_texto(k)])
        for k, i in comites_estaduais.items()
    )
    saida.extend(
        inserir("unidade_gestao", ["id_unidade_gestao", "nome"], [str(i), literal_texto(k)])
        for k, i in unidades.items()
    )

    for linha, id_municipio, id_emp, id_regiao, id_cf, id_ce, id_unidade in barragens:
        ordem = [
            "cod_snisb",
            "cod_fiscalizador",
            "nome",
            "altura_fundacao_m",
            "altura_terreno_m",
            "capacidade_reservatorio_texto",
            "capacidade_reservatorio_padronizada",
            "data_cadastro",
            "tipo_material",
            "uso_principal",
            "latitude",
            "longitude",
            "regulada_pnsb",
            "id_empreendedor",
            "id_municipio",
            "fase_vida",
            "orgao_fiscalizador",
            "numero_autorizacao",
            "data_autorizacao",
            "id_regiao_hidrografica",
            "cod_trecho_curso_dagua",
            "curso_dagua",
            "dominio_curso_dagua",
            "id_comite_federal",
            "id_comite_estadual",
            "id_unidade_gestao",
            "possui_pae",
            "possui_plano_seguranca",
            "possui_revisao_periodica",
            "categoria_risco",
            "dano_potencial_associado",
            "barragem_autuada",
            "completude_cadastro",
        ]
        raw = linha
        campos_booleanos = [
            "regulada_pnsb",
            "possui_pae",
            "possui_plano_seguranca",
            "possui_revisao_periodica",
            "barragem_autuada",
        ]
        for campo in campos_booleanos:
            if raw[campo] not in ("true", "false", "") or (campo != "possui_pae" and raw[campo] == ""):
                raise ValueError(f"Booleano inválido em {campo}: {raw[campo]!r}")
        d = {
            "cod_snisb": literal_texto(raw["cod_snisb"]),
            "cod_fiscalizador": literal_texto(raw["cod_fiscalizador"]),
            "nome": literal_texto(raw["nome"]),
            "altura_fundacao_m": literal_decimal(raw["altura_fundacao_m"]),
            "altura_terreno_m": (
                literal_decimal(raw["altura_terreno_m"])
                if raw["altura_terreno_m"]
                else "NULL"
            ),
            "capacidade_reservatorio_texto": literal_texto(
                raw["capacidade_reservatorio"]
            ),
            "capacidade_reservatorio_padronizada": "NULL",
            "data_cadastro": literal_data(raw["data_cadastro"]),
            "tipo_material": (
                literal_texto(raw["tipo_material"]) if raw["tipo_material"] else "NULL"
            ),
            "uso_principal": literal_texto(raw["uso_principal"]),
            "latitude": literal_decimal(raw["latitude"]),
            "longitude": literal_decimal(raw["longitude"]),
            "regulada_pnsb": raw["regulada_pnsb"].upper(),
            "id_empreendedor": str(id_emp),
            "id_municipio": str(id_municipio),
            "fase_vida": literal_texto(raw["fase_vida"]) if raw["fase_vida"] else "NULL",
            "orgao_fiscalizador": literal_texto(raw["orgao_fiscalizador"]),
            "numero_autorizacao": literal_texto(raw["numero_autorizacao"]),
            "data_autorizacao": (
                literal_data(raw["data_autorizacao"])
                if raw["data_autorizacao"]
                else "NULL"
            ),
            "id_regiao_hidrografica": str(id_regiao),
            "cod_trecho_curso_dagua": (
                literal_texto(raw["cod_trecho_curso_dagua"])
                if raw["cod_trecho_curso_dagua"]
                else "NULL"
            ),
            "curso_dagua": literal_texto(raw["curso_dagua"]),
            "dominio_curso_dagua": (
                literal_texto(raw["dominio_curso_dagua"])
                if raw["dominio_curso_dagua"]
                else "NULL"
            ),
            "id_comite_federal": str(id_cf) if id_cf else "NULL",
            "id_comite_estadual": str(id_ce) if id_ce else "NULL",
            "id_unidade_gestao": str(id_unidade) if id_unidade else "NULL",
            "possui_pae": raw["possui_pae"].upper() if raw["possui_pae"] else "NULL",
            "possui_plano_seguranca": raw["possui_plano_seguranca"].upper(),
            "possui_revisao_periodica": raw["possui_revisao_periodica"].upper(),
            "categoria_risco": literal_texto(raw["categoria_risco"]),
            "dano_potencial_associado": literal_texto(raw["dano_potencial_associado"]),
            "barragem_autuada": raw["barragem_autuada"].upper(),
            "completude_cadastro": literal_texto(raw["completude_cadastro"]),
        }
        saida.append(inserir("barragem", ordem, [d[c] for c in ordem]))

    for n, (linha, *_resto) in enumerate(barragens, start=1):
        saida.append(
            inserir(
                "registro_origem",
                ["id_registro", "numero_linha", "cod_snisb"],
                [str(n), str(n + 1), literal_texto(linha["cod_snisb"])],
            )
        )
    saida.extend(
        inserir("campo_origem", ["ordem_coluna", "nome_original"], [str(i), literal_texto(c)])
        for i, c in enumerate(cabecalhos, start=1)
    )
    for reg, (linha, *_resto) in enumerate(barragens, start=1):
        for ordem_coluna, campo in enumerate(cabecalhos, start=1):
            saida.append(
                inserir(
                    "valor_origem",
                    ["id_registro", "ordem_coluna", "valor_original"],
                    [str(reg), str(ordem_coluna), literal_texto(linha[campo])],
                )
            )

    sequences = [
        ("municipio", "id_municipio", "municipio_id_municipio_seq"),
        ("empreendedor", "id_empreendedor", "empreendedor_id_empreendedor_seq"),
        (
            "regiao_hidrografica",
            "id_regiao_hidrografica",
            "regiao_hidrografica_id_regiao_hidrografica_seq",
        ),
        ("comite_federal", "id_comite_federal", "comite_federal_id_comite_federal_seq"),
        ("comite_estadual", "id_comite_estadual", "comite_estadual_id_comite_estadual_seq"),
        ("unidade_gestao", "id_unidade_gestao", "unidade_gestao_id_unidade_gestao_seq"),
        ("registro_origem", "id_registro", "registro_origem_id_registro_seq"),
    ]
    for tabela, coluna, nome in sequences:
        saida.append(f"SELECT setval('{nome}', (SELECT COALESCE(MAX({coluna}), 1) FROM {tabela}), true);")
    saida.append("COMMIT;")
    return "\n".join(saida) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", type=Path, default=CSV_PADRAO)
    parser.add_argument("--mapa", type=Path, default=MAPA_PADRAO)
    parser.add_argument("--saida", type=Path, default=SQL_PADRAO)
    args = parser.parse_args()
    conteudo = gerar_sql(args.csv, args.mapa)
    with args.saida.open("w", encoding="utf-8", newline="") as arquivo:
        arquivo.write(conteudo)
    print(f"Gerado {args.saida}: 887 barragens, 887 registros, 33 campos e 29.271 valores.")


if __name__ == "__main__":
    main()
