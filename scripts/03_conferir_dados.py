#!/usr/bin/env python3
"""Reconstrói a matriz de origem via PostgreSQL e compara cada célula."""

import argparse
import csv
import hashlib
import subprocess
import sys
from pathlib import Path

MARCADOR_NULL = "__SQL_NULL_7f3a9c__"


def ler_csv(caminho):
    with caminho.open("r", encoding="utf-8-sig", newline="") as arquivo:
        return list(csv.reader(arquivo))


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
                diferencas.append((numero, cabecalho_original[coluna], antes, depois))
    return diferencas


def sql_reconstrucao(cabecalho):
    """Gera projeção ordenada de colunas a partir do catálogo de proveniência."""
    def literal(valor):
        return "'" + valor.replace("'", "''") + "'"

    def identificador(valor):
        return '"' + valor.replace('"', '""') + '"'

    colunas = ",\n       ".join(
        f"MAX(vo.valor_original) FILTER (WHERE co.nome_original = {literal(nome)}) AS {identificador(nome)}"
        for nome in cabecalho
    )
    return f"""SELECT {colunas}
FROM registro_origem ro
JOIN valor_origem vo USING (id_registro)
JOIN campo_origem co USING (ordem_coluna)
GROUP BY ro.numero_linha
ORDER BY ro.numero_linha"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--banco", required=True, help="banco de teste carregado")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", default="5432")
    parser.add_argument(
        "--origem",
        type=Path,
        default=Path("dados/originais/ana_barragens_hidreletricas.csv"),
    )
    parser.add_argument(
        "--saida",
        type=Path,
        default=Path("dados/analise/barragens_conferidas.csv"),
    )
    args = parser.parse_args()

    linhas_fonte = ler_csv(args.origem)
    if not linhas_fonte:
        raise ValueError("CSV de origem vazio")
    if any(MARCADOR_NULL in celula for linha in linhas_fonte for celula in linha):
        raise ValueError("Marcador de NULL ocorre na fonte; escolha outro marcador")
    cabecalho, linhas_originais = linhas_fonte[0], linhas_fonte[1:]
    hash_antes = hashlib.sha256(args.origem.read_bytes()).hexdigest()

    consulta = sql_reconstrucao(cabecalho)
    comando = [
        "psql", "-X", "-h", args.host, "-p", args.port,
        "-d", args.banco, "-v", "ON_ERROR_STOP=1", "-c",
        f"COPY ({consulta}) TO STDOUT WITH (FORMAT CSV, HEADER TRUE, "
        f"ENCODING 'UTF8', NULL '{MARCADOR_NULL}')",
    ]
    resultado = subprocess.run(comando, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    args.saida.parent.mkdir(parents=True, exist_ok=True)
    args.saida.write_bytes(resultado.stdout)

    exportado = ler_csv(args.saida)
    if not exportado:
        raise ValueError("Exportação vazia")
    cabecalho_exportado, linhas_exportadas = exportado[0], exportado[1:]
    # O marcador permanece literal na leitura: assim SQL NULL nunca se confunde
    # com o texto vazio preservado pela fonte.
    diferencas = comparar(cabecalho, linhas_originais, cabecalho_exportado, linhas_exportadas)
    hash_depois = hashlib.sha256(args.origem.read_bytes()).hexdigest()
    print(f"SHA-256 original antes: {hash_antes}")
    print(f"SHA-256 original depois: {hash_depois}")
    celulas = len(linhas_originais) * len(cabecalho)
    print(
        f"Registros: {len(linhas_originais)}; colunas: {len(cabecalho)}; "
        f"células: {celulas}"
    )
    print(f"Diferenças: {len(diferencas)}")
    for numero, coluna, antes, depois in diferencas:
        print(f"Linha {numero}, coluna {coluna}: {antes!r} != {depois!r}")
    if hash_antes != hash_depois:
        raise ValueError("SHA-256 da fonte mudou durante a conferência")
    if diferencas:
        return 1
    print("APROVADO")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError, ValueError) as erro:
        print(f"ERRO: {erro}", file=sys.stderr)
        sys.exit(2)
