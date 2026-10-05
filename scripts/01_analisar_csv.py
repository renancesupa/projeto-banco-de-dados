#!/usr/bin/env python3
"""Gera perfil descritivo do CSV da ANA sem alterar o arquivo de origem."""
import csv
import hashlib
import json
from collections import Counter
from datetime import date
from pathlib import Path

CAMINHO_CSV = Path(__file__).resolve().parents[1] / "dados/originais/ana_barragens_hidreletricas.csv"
CODIFICACAO = "utf-8-sig"
DELIMITADOR = ","


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
    return {"vazios": sum(valor == "" for valor in valores),
            "valores_distintos": sorted(set(valores))}


def analisar(caminho):
    caminho = Path(caminho)
    cabecalho, linhas = ler_csv(caminho, CODIFICACAO, DELIMITADOR)
    duplicados = {nome: [i + 1 for i, valor in enumerate(cabecalho) if valor == nome]
                  for nome in set(cabecalho) if cabecalho.count(nome) > 1}
    colunas = []
    for indice, nome in enumerate(cabecalho):
        resumo = resumir_coluna(linhas, indice)
        colunas.append({"ordem_coluna": indice + 1, "coluna_original": nome,
                        "vazios": resumo["vazios"],
                        "quantidade_valores_distintos": len(resumo["valores_distintos"]),
                        "valores_distintos": resumo["valores_distintos"]})
    id_idx = cabecalho.index("cod_snisb") if "cod_snisb" in cabecalho else None
    ids = [linha[id_idx] for linha in linhas] if id_idx is not None else []
    duplicados_id = sorted(valor for valor, qtd in Counter(ids).items() if qtd > 1)
    registros_repetidos = sum(qtd - 1 for qtd in Counter(tuple(l) for l in linhas).values() if qtd > 1)
    capacidade = linhas and [l[cabecalho.index("capacidade_reservatorio")] for l in linhas]
    capacidade = capacidade or []
    marcadores = {}
    for marcador in ("não informado", "nao informado", "não se aplica", "nao se aplica", "não", "nao", "sim", "0", "0,0", "0.0"):
        achados = [(cabecalho[i], sum(v.strip().casefold() == marcador for v in (l[i] for l in linhas)))
                   for i in range(len(cabecalho))]
        achados = {nome: qtd for nome, qtd in achados if qtd}
        if achados:
            marcadores[marcador] = achados
    campos_multivalorados = {}
    for separador in (";", "|", "\n"):
        achados = {}
        for i, nome in enumerate(cabecalho):
            ocorrencias = sum(separador in l[i] for l in linhas)
            if ocorrencias:
                achados[nome] = ocorrencias
        if achados:
            campos_multivalorados[{";": "ponto_e_virgula", "|": "barra_vertical", "\n": "quebra_de_linha"}[separador]] = achados
    constantes = [{"coluna": c["coluna_original"], "ordem_coluna": c["ordem_coluna"],
                   "valor": c["valores_distintos"][0] if c["valores_distintos"] else "",
                   "tipo": "vazia" if not c["valores_distintos"] else "constante"}
                  for c in colunas if c["quantidade_valores_distintos"] <= 1]
    conteudo = caminho.read_bytes()
    return {
        "origem_fornecida": "ana_barragens_hidreletricas.csv fornecido pelo usuário",
        "copia": "dados/originais/ana_barragens_hidreletricas.csv",
        "data_analise": date.today().isoformat(),
        "sha256": hashlib.sha256(conteudo).hexdigest(),
        "bytes": len(conteudo), "codificacao": CODIFICACAO,
        "delimitador": DELIMITADOR, "total_registros": len(linhas),
        "total_colunas": len(cabecalho), "contagem_esperada": {"registros": 887, "colunas": 33},
        "contagens_conferem": len(linhas) == 887 and len(cabecalho) == 33,
        "total_valores_origem": len(linhas) * len(cabecalho),
        "cabecalhos": cabecalho, "cabecalhos_duplicados": duplicados,
        "linhas_com_quantidade_incorreta": 0, "linhas_ignoradas": 0,
        "equipe": ["Alexandre Arthur", "Enrique Luis", "Renan Gomes"],
        "colunas": colunas, "colunas_constantes": constantes,
        "cod_snisb_vazios": sum(not x for x in ids),
        "cod_snisb_valores_distintos": len(set(ids)),
        "cod_snisb_duplicados": duplicados_id,
        "registros_repetidos_exatos_adicionais": registros_repetidos,
        "marcadores_textuais_e_zero": marcadores,
        "campos_com_separadores_multivalorados_candidatos": campos_multivalorados,
        "capacidade_reservatorio_valores_distintos": sorted(set(capacidade)),
        "decisoes_constantes": {
            c["coluna"]: ("manter na proveniência; avaliar representação analítica na tarefa 2" if c["tipo"] == "constante"
                          else "manter explicitamente vazia na proveniência") for c in constantes},
        "observacao": "A lista de valores distintos é literal; não normaliza espaços, acentos, números nem marcadores de ausência."
    }


def main():
    perfil = analisar(CAMINHO_CSV)
    destino = CAMINHO_CSV.parents[1] / "analise/perfil_csv.json"
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(json.dumps(perfil, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"CSV lido: {perfil['total_registros']} registros x {perfil['total_colunas']} colunas")
    print(f"Codificação: {perfil['codificacao']}; delimitador: {perfil['delimitador']!r}")
    print(f"SHA-256: {perfil['sha256']}")
    print(f"IDs SNISB distintos: {perfil['cod_snisb_valores_distintos']}; vazios: {perfil['cod_snisb_vazios']}; duplicados: {len(perfil['cod_snisb_duplicados'])}")
    print(f"Perfil gravado em {destino}")


if __name__ == "__main__":
    main()
