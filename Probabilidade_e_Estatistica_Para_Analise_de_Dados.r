# ==========================================================
# ANÁLISE DE ACIDENTES DE TRÂNSITO
# Disciplina: Probabilidade e Estatística para Análise de Dados
# Aluno: Mateus Neres da Silva
# Professor: Anderson Inacio Salata de Abreu
# ==========================================================


# 1. INSTALAÇÃO E CARREGAMENTO DOS PACOTES

# Caminho da biblioteca pessoal definido pelo próprio R.
biblioteca_pessoal <- path.expand(
  Sys.getenv("R_LIBS_USER")
)

if (!nzchar(biblioteca_pessoal)) {
  stop("O R não informou o caminho da biblioteca pessoal.")
}

dir.create(
  biblioteca_pessoal,
  recursive = TRUE,
  showWarnings = FALSE
)

# Coloca a biblioteca pessoal como primeira opção.
.libPaths(
  c(biblioteca_pessoal, .libPaths())
)

pacotes <- c("dplyr", "ggplot2")

faltantes <- setdiff(
  pacotes,
  rownames(installed.packages())
)

if (length(faltantes) > 0) {
  install.packages(
    faltantes,
    lib = biblioteca_pessoal,
    repos = "https://cloud.r-project.org",
    type = "binary"
  )
}

library(dplyr)
library(ggplot2)

# 2. IMPORTAÇÃO DOS DADOS -----------------------------------
# Selecione o arquivo datatran2024.csv na janela que abrir.

caminho <- file.choose()

dados <- read.csv(
  file = caminho,
  sep = ";",
  fileEncoding = "latin1",
  stringsAsFactors = FALSE,
  check.names = FALSE,
  fill = TRUE
)

# Os resultados serão salvos ao lado do arquivo CSV.
pasta_resultados <- file.path(
  dirname(caminho),
  "resultados_analise"
)

dir.create(
  pasta_resultados,
  showWarnings = FALSE
)


# 3. EXPLORAÇÃO E VERIFICAÇÃO -------------------------------

# Quantidade de linhas e colunas
dim(dados)

# Estrutura das variáveis
str(dados)

# Resumo dos dados
summary(dados)

# Primeiros registros
head(dados)

# Nomes das colunas
names(dados)

variaveis <- c(
  "id",
  "data_inversa",
  "uf",
  "condicao_metereologica",
  "fase_dia",
  "tipo_acidente",
  "causa_acidente",
  "horario"
)

# Confere se as colunas necessárias existem.
stopifnot(all(variaveis %in% names(dados)))

# Quantidade de valores ausentes nas variáveis utilizadas
ausentes <- colSums(is.na(dados[variaveis]))
print(ausentes)

# Verificação dos identificadores
cat(
  "\nIdentificadores duplicados:",
  sum(duplicated(dados$id)),
  "\n"
)

stopifnot(
  !anyNA(dados$id),
  anyDuplicated(dados$id) == 0L
)

# Conversão da data
dados$data <- as.Date(
  dados$data_inversa,
  format = "%d/%m/%Y"
)

stopifnot(!anyNA(dados$data))

cat(
  "\nPeríodo da base:",
  format(min(dados$data), "%d/%m/%Y"),
  "até",
  format(max(dados$data), "%d/%m/%Y"),
  "\n"
)

total_acidentes <- nrow(dados)

cat(
  "\nTotal de acidentes registrados:",
  total_acidentes,
  "\n"
)


# 4. FUNÇÃO PARA CONTAGENS E PERCENTUAIS --------------------
# Todos os percentuais usam o total de registros da base.

resumir_variavel <- function(nome_coluna) {
  dados %>%
    group_by(across(all_of(nome_coluna))) %>%
    summarise(
      quantidade = n(),
      .groups = "drop"
    ) %>%
    mutate(
      percentual = 100 * quantidade / total_acidentes
    ) %>%
    arrange(desc(quantidade))
}


# 5. ESTADO COM MAIOR NÚMERO DE ACIDENTES --------------------

acidentes_estado <- resumir_variavel("uf")

print(acidentes_estado)

cat("\nEstado com maior número de registros:\n")
print(head(acidentes_estado, 1))


# 6. PROBABILIDADE DE ACIDENTE REGISTRADO SOB CÉU CLARO -------

acidentes_clima <- resumir_variavel(
  "condicao_metereologica"
)

print(acidentes_clima)

quantidade_ceu_claro <- sum(
  dados$condicao_metereologica == "Céu Claro",
  na.rm = TRUE
)

probabilidade_ceu_claro <- (
  quantidade_ceu_claro / total_acidentes
)

cat(
  "\nP(Céu Claro entre os acidentes registrados) =",
  quantidade_ceu_claro,
  "/",
  total_acidentes,
  "=",
  round(probabilidade_ceu_claro, 6),
  "\nPercentual:",
  round(100 * probabilidade_ceu_claro, 2),
  "%\n"
)

# Análise complementar:
# A base mantém Céu Claro e Sol como categorias distintas.
quantidade_claro_ou_sol <- sum(
  dados$condicao_metereologica %in% c("Céu Claro", "Sol")
)

cat(
  "\nPercentual com Céu Claro ou Sol:",
  round(
    100 * quantidade_claro_ou_sol / total_acidentes,
    2
  ),
  "%\n"
)

# Atenção:
# Esse cálculo descreve a condição meteorológica dos acidentes.
# Não estima o risco de sofrer um acidente ao dirigir com céu claro.


# 7. DISTRIBUIÇÃO DOS ACIDENTES POR FASE DO DIA --------------

acidentes_fase <- resumir_variavel("fase_dia")

print(acidentes_fase)


# 8. TIPOS DE ACIDENTES PREDOMINANTES ------------------------

acidentes_tipo <- resumir_variavel("tipo_acidente")

print(acidentes_tipo)

cat("\nCinco tipos mais frequentes:\n")
print(head(acidentes_tipo, 5))


# 9. CAUSAS DE ACIDENTES MAIS FREQUENTES ---------------------

acidentes_causa <- resumir_variavel("causa_acidente")

print(acidentes_causa)

cat("\nCinco causas mais frequentes:\n")
print(head(acidentes_causa, 5))


# 10. FILTRAGEM E CRUZAMENTO ENTRE TIPO E CAUSA --------------

colisoes_traseiras <- dados %>%
  filter(tipo_acidente == "Colisão traseira")

causas_colisoes_traseiras <- colisoes_traseiras %>%
  count(
    causa_acidente,
    name = "quantidade",
    sort = TRUE
  ) %>%
  mutate(
    percentual_no_tipo = (
      100 * quantidade / nrow(colisoes_traseiras)
    )
  )

cat("\nCausas registradas nas colisões traseiras:\n")
print(head(causas_colisoes_traseiras, 10))

cruzamento_tipo_causa <- dados %>%
  count(
    tipo_acidente,
    causa_acidente,
    name = "quantidade",
    sort = TRUE
  )

cat("\nCombinações de tipo e causa mais frequentes:\n")
print(head(cruzamento_tipo_causa, 10))


# 11. PROBABILIDADE POR FAIXA DE HORÁRIO ---------------------

dados <- dados %>%
  mutate(
    hora = as.integer(substr(horario, 1, 2))
  )

acidentes_hora <- dados %>%
  count(hora, name = "quantidade") %>%
  mutate(
    percentual = 100 * quantidade / total_acidentes
  ) %>%
  arrange(desc(quantidade))

cat("\nAcidentes por faixa de uma hora:\n")
print(
  as.data.frame(acidentes_hora),
  row.names = FALSE
)

# Exemplo: intervalo das 18h00 até antes das 19h00.
quantidade_18h <- sum(
  dados$hora == 18,
  na.rm = TRUE
)

cat(
  "\nPercentual de registros entre 18h00 e 18h59:",
  round(100 * quantidade_18h / total_acidentes, 2),
  "%\n"
)


# 12. FUNÇÃO PARA GERAR E SALVAR GRÁFICOS --------------------

gerar_grafico <- function(
    tabela,
    coluna,
    titulo,
    nome_arquivo,
    limite = 5
) {
  tabela_grafico <- head(tabela, limite)

  grafico <- ggplot(
    tabela_grafico,
    aes(
      x = reorder(.data[[coluna]], quantidade),
      y = quantidade
    )
  ) +
    geom_col(
      fill = "#326879",
      width = 0.7
    ) +
    geom_text(
      aes(
        label = format(
          quantidade,
          big.mark = ".",
          scientific = FALSE,
          trim = TRUE
        )
      ),
      hjust = -0.15,
      size = 3.5
    ) +
    coord_flip() +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.18))
    ) +
    scale_x_discrete(
      labels = function(rotulos) {
        vapply(
          rotulos,
          function(rotulo) {
            paste(
              strwrap(rotulo, width = 42),
              collapse = "\n"
            )
          },
          character(1)
        )
      }
    ) +
    labs(
      title = titulo,
      x = NULL,
      y = "Acidentes registrados",
      caption = "Fonte: datatran2024.csv indicado no roteiro."
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.major.y = element_blank(),
      plot.title = element_text(face = "bold")
    )

  print(grafico)

  ggsave(
    filename = file.path(
      pasta_resultados,
      nome_arquivo
    ),
    plot = grafico,
    width = 11,
    height = 6,
    dpi = 150,
    bg = "white"
  )

  return(grafico)
}


# 13. GERAÇÃO DOS GRÁFICOS ----------------------------------

grafico_estados <- gerar_grafico(
  acidentes_estado,
  "uf",
  "Cinco estados com mais acidentes registrados",
  "01_acidentes_por_estado.png"
)

grafico_clima <- gerar_grafico(
  acidentes_clima,
  "condicao_metereologica",
  "Acidentes por condição meteorológica",
  "02_acidentes_por_clima.png",
  limite = nrow(acidentes_clima)
)

grafico_fases <- gerar_grafico(
  acidentes_fase,
  "fase_dia",
  "Acidentes por fase do dia",
  "03_acidentes_por_fase_dia.png",
  limite = nrow(acidentes_fase)
)

grafico_tipos <- gerar_grafico(
  acidentes_tipo,
  "tipo_acidente",
  "Cinco tipos de acidentes mais frequentes",
  "04_tipos_de_acidente.png"
)

grafico_causas <- gerar_grafico(
  acidentes_causa,
  "causa_acidente",
  "Cinco causas registradas mais frequentes",
  "05_causas_de_acidente.png"
)


# 14. EXPORTAÇÃO DAS TABELAS --------------------------------

tabelas <- list(
  estados = acidentes_estado,
  clima = acidentes_clima,
  fases_do_dia = acidentes_fase,
  tipos = acidentes_tipo,
  causas = acidentes_causa,
  horarios = acidentes_hora,
  causas_colisoes_traseiras = causas_colisoes_traseiras,
  cruzamento_tipo_causa = cruzamento_tipo_causa
)

for (nome in names(tabelas)) {
  write.csv2(
    tabelas[[nome]],
    file = file.path(
      pasta_resultados,
      paste0(nome, ".csv")
    ),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
}


# 15. REGISTRO DO AMBIENTE ----------------------------------

capture.output(
  sessionInfo(),
  file = file.path(
    pasta_resultados,
    "informacoes_do_ambiente.txt"
  )
)

cat(
  "\nAnálise concluída. Resultados salvos em:\n",
  pasta_resultados,
  "\n"
)