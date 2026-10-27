# Análise de Acidentes de Trânsito com R

Projeto desenvolvido para a disciplina **Probabilidade e Estatística para Análise de Dados**, com o objetivo de aplicar técnicas de análise exploratória, estatística descritiva e probabilidade sobre dados reais de acidentes de trânsito.

A implementação utiliza R para processar a base `datatran2024.csv`, identificar padrões e gerar tabelas e gráficos que auxiliam na interpretação dos dados.

## Tecnologias utilizadas

- **R:** processamento e análise dos dados.
- **dplyr:** filtragem, agrupamento e sumarização.
- **ggplot2:** geração de gráficos estatísticos.

## Análises realizadas

- Distribuição dos acidentes por estado e condição meteorológica.
- Análise por fase do dia e faixa horária.
- Identificação dos tipos e das causas de acidentes mais frequentes.
- Cruzamento entre tipos de acidentes e causas registradas.
- Cálculo de percentuais e análise da proporção de acidentes registrados sob céu claro.

O script também realiza verificações de integridade dos dados e exporta automaticamente os resultados.

## Como executar

1. Instale o [R](https://cran.r-project.org/) e, preferencialmente, o [RStudio](https://posit.co/download/rstudio-desktop/).
2. Baixe a base de dados [`datatran2024.csv`](https://github.com/AndersonSalata/projeto-integrado-ciencia-de-dados/blob/main/datatran2024.csv).
3. Abra e execute o arquivo `Probabilidade_e_Estatistica_Para_Analise_de_Dados.r`.
4. Na janela de seleção, escolha o arquivo CSV baixado.

As bibliotecas `dplyr` e `ggplot2` serão instaladas automaticamente caso não estejam disponíveis.

## Resultados

O script cria a pasta `resultados_analise` no diretório da base selecionada, contendo:

- **Gráficos PNG:** distribuição por estado, condição meteorológica, fase do dia, tipos e causas de acidentes.
- **Tabelas CSV:** frequências, percentuais, horários e cruzamentos entre tipos e causas.
- **Informações do ambiente:** registro das versões e dos pacotes utilizados na execução.

Os resultados numéricos são gerados durante a execução do programa e podem ser consultados nos arquivos exportados.

> **Nota:** a proporção de acidentes registrados sob céu claro descreve as condições meteorológicas dos registros analisados, não o risco individual de sofrer um acidente nessas condições.

## Base de dados

Fonte: [DATATRAN 2024 — Projeto Integrado de Ciência de Dados](https://github.com/AndersonSalata/projeto-integrado-ciencia-de-dados/blob/main/datatran2024.csv).

## Autor

**Mateus Neres da Silva**

Disciplina: Probabilidade e Estatística para Análise de Dados  
Professor: Anderson Inacio Salata de Abreu
