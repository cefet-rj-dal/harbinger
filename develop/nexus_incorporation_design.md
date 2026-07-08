# Nexus no Harbinger: desenho de incorporação

## Objetivo

Incorporar ao `harbinger` o mecanismo de detecção online estudado no `nexus`, preservando:

- a interface unificada e extensível do `harbinger`
- a compatibilidade retroativa com todo o código já existente no `harbinger`
- a possibilidade de linhas de experimento reproduzíveis
- a generalização de fontes de dados distintas
- as métricas do paper: Detection Probability (DP) e Detection Lag (DL)

O objetivo não deve ser "copiar o `nexus` para dentro do `harbinger`", mas absorver seus conceitos em uma arquitetura mais coesa, testável e idiomática para o pacote.

## Requisito não negociável

Todo código previamente existente do `harbinger` deve continuar funcionando como hoje.

Isso inclui, no mínimo:

- detectores existentes
- chamadas atuais de `fit()`
- chamadas atuais de `detect()`
- chamadas atuais de `evaluate()`
- funções de visualização como `har_plot()`
- exemplos, tutoriais e linhas de uso já estabelecidas

As novas funcionalidades online devem rodar usando a base já existente, por composição e extensão, e nunca por substituição incompatível.

## Critério de compatibilidade retroativa

A incorporação do `nexus` no `harbinger` deve ser estritamente aditiva.

Em termos práticos, isso significa:

- não quebrar a API pública existente
- não alterar a semântica atual dos detectores offline
- não exigir mudanças no código dos usuários atuais
- não transformar detectores existentes em subclasses de uma nova hierarquia obrigatória
- não mover a lógica atual para dentro de um novo motor online como dependência obrigatória

O modo online deve ser opcional. O modo offline atual continua sendo cidadão de primeira classe.

## Diagnóstico

### O que o `harbinger` já faz bem

O `harbinger` já tem uma base boa para esta incorporação:

- uma classe-base `harbinger()` com convenções claras para `fit()`, `detect()` e `evaluate()`
- detectores organizados por família, com contratos relativamente consistentes
- avaliação e visualização desacopladas dos detectores
- exemplos organizados por linhas de aprendizagem e por famílias de métodos

Em particular, o padrão atual é:

- o detector conhece a lógica algorítmica
- o framework conhece o ciclo de uso
- a avaliação é um objeto independente

Esse padrão deve ser preservado.

### Onde o `nexus` prototipal falha

O protótipo do `nexus` mistura responsabilidades demais em `detect.nexus()` e em `run_nexus()`:

- ingestão de dados
- buffering e política de memória
- re-treinamento
- disparo do detector
- acumulação de resultados
- cálculo parcial de métricas
- medição de tempo

Além disso, há problemas conceituais e de engenharia:

- a política de memória está codificada por efeito colateral em vez de abstraída
- a fonte de dados simulada e a execução do stream estão acopladas
- o cálculo de `bf`, `ef`, `fdb` e `pe` depende de pós-processamento ad hoc
- não há separação entre modo pull e modo push
- não há contrato explícito para detectores online, apenas reutilização implícita de detectores offline
- não há estrutura de experimento equivalente ao padrão de documentação e extensão do `harbinger`

Conclusão: o valor do `nexus` está no modelo conceitual do paper e não na sua implementação atual.

## Princípio de desenho

O `harbinger` deve ganhar uma camada de orquestração online, não um segundo framework paralelo.

Portanto, a incorporação ideal é:

- `harbinger` continua sendo o núcleo de detectores e avaliação
- uma nova subcamada online faz ingestão, batching, memória, execução incremental e rastreamento
- DP e DL entram como avaliadores e artefatos de tracing, não como campos improvisados dentro do detector

## Arquitetura proposta

### 1. Separar quatro responsabilidades

#### 1. Fonte de dados

Representa de onde as observações vêm.

Contrato proposto:

- `next_observation(source)` para modo pull
- `push_observation(source, obs)` ou `emit(source, callback)` para modo push
- `source_info(source)` para metadados da origem

Tipos de origem:

- `har_source_simulated()`: reproduz o comportamento atual do `nexus`
- `har_source_dataframe()`: stream a partir de `data.frame` ou vetor
- `har_source_kafka()`: stub de interface para Kafka
- `har_source_callback()`: para integração com aplicações externas

Ponto importante: Kafka não deve contaminar a API central. O pacote deve depender de uma abstração de source. No `harbinger`, `har_source_kafka()` deve existir apenas como contrato e placeholder de configuração. A coleta efetiva deve ser feita fora do núcleo R, por código Python integrado via `reticulate`.

#### 2. Sessão online

É o orquestrador do ciclo de vida da detecção em stream.

Objeto sugerido:

- `har_online_session()`

Responsabilidades:

- manter estado da execução
- receber observações
- formar batches
- aplicar warm-up
- aplicar política de memória
- decidir quando chamar `fit()` e `detect()`
- registrar rastros para avaliação

Ela não implementa a lógica do detector.

#### 3. Estratégia de execução online

Nem todo detector do `harbinger` é realmente incremental. Logo, a sessão online precisa de uma política explícita de adaptação.

Estratégias sugeridas:

- `har_online_refit_full()`: refaz `fit()` com a memória corrente
- `har_online_detect_only()`: assume detector pré-ajustado e apenas chama `detect()`
- `har_online_incremental()`: usa detectores que possuam atualização incremental nativa

Isso evita mascarar diferenças metodológicas. Um método offline usado online via refit em batches continua sendo suportado, mas isso fica explícito.

#### 4. Avaliação e tracing online

As métricas do paper devem nascer de um log estruturado de execução.

Objeto sugerido:

- `har_stream_trace()`

Campos mínimos por observação:

- `idx`
- `timestamp` opcional
- `batch_id_first_seen`
- `batch_ids_present`
- `detected_in_batches`
- `first_detected_batch`
- `last_detected_batch`
- `event_type`
- `score` opcional

Derivações:

- `bf(x_i)`: tamanho de `batch_ids_present`
- `df(x_i)`: tamanho de `detected_in_batches`
- `DP(x_i) = df(x_i) / bf(x_i)`
- `DL_batch(x_i) = first_detected_batch - batch_id_first_seen`
- `DL_obs(x_i) = (first_detected_batch - batch_id_first_seen + 1) * batch_size`

Esse desenho está alinhado com o paper e remove a lógica frágil hoje embutida em `run_nexus()`.

## Interfaces sugeridas

### API de alto nível

Uma API compatível com o estilo atual do pacote pode ser:

```r
source <- har_source_simulated(data$series)

session <- har_online_session(
  source = source,
  detector = hanr_fbiad(),
  executor = har_online_refit_full(),
  warmup_size = 81,
  batch_size = 27,
  memory = har_memory_sliding(batches = 9)
)

session <- fit(session)
session <- run(session)

detection <- collect_detection(session)
trace <- collect_trace(session)
metrics <- evaluate(har_stream_eval(), trace, reference = data$event)
```

### API de baixo nível

Para integração com aplicações:

```r
session <- fit(session)

repeat {
  session <- step(session)
  if (is_finished(session)) break
}
```

Ou, no caso push:

```r
session <- fit(session)
session <- ingest(session, observation)
session <- flush(session)
```

### Compatibilidade push e pull

O ideal é não ter dois motores distintos.

Desenho:

- modo pull: `step()` pede a próxima observação à source
- modo push: `ingest()` coloca a observação numa fila interna e `step()` consome

Assim, ambos os modos convergem para a mesma máquina de estados.

## Política de memória

O paper distingue memória total e parcial. Isso deve virar abstração própria.

Objetos sugeridos:

- `har_memory_full()`
- `har_memory_sliding(batches)`
- `har_memory_last_observations(n)`

Regras:

- `full`: nunca descarta batches antigos
- `sliding(batches = m)`: preserva somente as últimas `m` janelas de batch
- `last_observations(n)`: útil para métodos cuja granularidade de memória é melhor expressa por observações, não batches

Isso também prepara o terreno para comparar experimentos com maior precisão.

## Relação com detectores existentes

### Não criar uma nova hierarquia de detectores

Seria um erro introduzir uma classe paralela como `nexus_detector` para tudo. O melhor é classificar detectores por capacidade online sem duplicar a hierarquia principal.

Metadados sugeridos no objeto do detector:

- `online_capability = "offline_refit" | "detect_only" | "incremental"`
- `supports_multivariate = TRUE/FALSE`
- `preferred_input = "vector" | "data.frame"`

Isso pode ser feito por helper leve:

```r
har_online_spec(
  mode = "offline_refit",
  retrain = "per_batch"
)
```

### Como usar detectores atuais

Casos típicos:

- `hanr_histogram()`: pode operar com `refit_full` por batch
- `hcp_page_hinkley()`: tem natureza online e pode ganhar executor incremental dedicado
- `hcp_waypoint()`: já tem warm-up e re-treinamento; precisa integração cuidadosa para não duplicar controles de regime

Regra de projeto:

- o motor online não deve reimplementar a matemática do detector
- ele só deve controlar quando e com qual memória o detector é invocado
- o detector offline continua podendo ser usado exatamente como hoje, fora do motor online

## Métricas do paper no `harbinger`

### 1. Detection Probability

O paper define:

- `bf(x_i)`: número de batches em que a observação está presente
- `df(x_i)`: número de batches em que foi marcada como evento
- `DP(x_i) = df(x_i) / bf(x_i)`

No `harbinger`, isso deve virar:

- uma tabela por observação em `collect_trace()`
- um avaliador `har_stream_eval()`
- filtros auxiliares, por exemplo `har_filter_dp(min_dp = 0.8)`

Isso permite reproduzir a análise do paper sem transformar a detecção principal em um artefato específico de experimento.

### 2. Detection Lag

O paper define:

- `DL_batch = first_detected_batch - start_batch`
- `DL_obs = (first_detected_batch - start_batch + 1) * batch_size`

No `harbinger`, isso deve ser retornado:

- por observação
- em agregados por execução
- em resumos por método e configuração experimental

Agregados úteis:

- mediana de lag
- quartis de lag
- lag máximo
- proporção de eventos detectados com lag zero

### 3. Tempo de execução

O protótipo mede tempo acumulado por batch. Isso é útil, mas deve ser formalizado.

Campos sugeridos por batch:

- `batch_id`
- `n_obs_in_memory`
- `fit_time_sec`
- `detect_time_sec`
- `total_time_sec`

Isso ajuda a explicar trade-offs entre batch, memória e acurácia.

## Linha de experimento

Esta é a parte mais importante para manter a qualidade do `harbinger`.

O `harbinger` é forte quando consegue organizar aprendizado e comparação. A incorporação do `nexus` deve respeitar isso.

### Estrutura proposta

Criar um objeto de experimento:

- `har_stream_experiment()`

Entradas:

- detector ou lista de detectores
- source factory
- grade de `warmup_size`
- grade de `batch_size`
- grade de política de memória
- referência rotulada opcional

Saídas:

- detecções
- traces
- métricas clássicas
- métricas online
- tempos
- metadados do experimento

### Por que isso importa

No protótipo, os experimentos são scripts. No `harbinger`, eles precisam ser objetos reproduzíveis, documentáveis e passíveis de virar exemplos e benchmarks.

### Generalização de fontes

O experimento não deve saber se os dados vieram de:

- vetor em memória
- `data.frame`
- replay simulado
- Kafka

Ele só recebe uma `source factory` compatível com a interface de source.

## Proposta de organização de código

Uma organização compatível com o pacote seria:

- `R/har_online_source.R`
- `R/har_online_source_simulated.R`
- `R/har_online_source_dataframe.R`
- `R/har_online_session.R`
- `R/har_online_executor.R`
- `R/har_online_memory.R`
- `R/har_stream_trace.R`
- `R/har_stream_eval.R`
- `R/har_stream_experiment.R`

Opcionalmente:

- `R/har_online_source_kafka.R`

Neste caso, `R/har_online_source_kafka.R` não implementa o consumo real. Ele apenas define:

- a estrutura do objeto source
- os parâmetros esperados para configuração
- o contrato de coleta esperado do lado Python
- erros explícitos de "not implemented" para consumo direto em R

A integração real com o broker fica delegada a um adaptador Python carregado via `reticulate`.

## Stub Kafka

### Papel do stub

O papel de `har_source_kafka()` não é consumir mensagens. Seu papel é documentar e estabilizar a interface entre:

- o motor online do `harbinger`
- a camada de coleta Python

Isso reduz acoplamento e evita embutir dependências operacionais de Kafka dentro do pacote.

### Responsabilidade no lado R

O lado R deve apenas:

- armazenar metadados de conexão e tópico
- definir o esquema esperado das observações recebidas
- expor uma interface uniforme para a sessão online
- validar se um coletor Python foi acoplado corretamente

### Responsabilidade no lado Python

O lado Python, acessado por `reticulate`, deve:

- conectar ao Kafka
- consumir mensagens
- desserializar payloads
- normalizar os dados para o esquema esperado pelo `harbinger`
- entregar observações unitárias ou minibatches ao source R

### Interface sugerida

No lado R:

```r
source <- har_source_kafka(
  topic = "sensor-events",
  bootstrap_servers = c("broker1:9092", "broker2:9092"),
  group_id = "harbinger-consumer",
  python_collector = NULL
)
```

Campos esperados no objeto:

- `topic`
- `bootstrap_servers`
- `group_id`
- `value_schema`
- `python_collector`
- `initialized`

Contrato mínimo esperado de `python_collector`:

- método para inicialização do consumidor
- método para coletar próxima observação
- método opcional para coletar lote
- método para encerrar conexão

Exemplo conceitual:

```r
obs <- next_observation(source)
```

Internamente, isso delegaria a algo conceitualmente equivalente a:

```r
source$python_collector$get_next()
```

### Comportamento do stub

Se `python_collector` não estiver configurado, `next_observation.har_source_kafka()` deve falhar com erro explícito, por exemplo:

- source Kafka configurada apenas como stub
- forneça um coletor Python via `reticulate`

Isso deixa claro que o objeto existe para compatibilidade arquitetural, não para ingestão nativa em R.

## Fluxo interno recomendado

### Inicialização

1. criar source
2. criar sessão
3. consumir warm-up
4. executar `fit()` inicial, se a estratégia exigir

### Laço principal

1. receber observação
2. anexar ao buffer
3. atualizar batch corrente
4. registrar presença da observação no trace
5. quando houver gatilho de execução:
6. aplicar política de memória
7. chamar executor
8. materializar detecções
9. atualizar trace com detecções do batch
10. registrar tempos

### Finalização

1. drenar fila pendente
2. consolidar trace
3. montar detecção final
4. expor objetos de avaliação

## Decisões de engenharia importantes

### 1. Detecção final e trace devem ser objetos diferentes

`detection` responde "o que foi detectado afinal".

`trace` responde "como a detecção evoluiu ao longo do streaming".

Misturar ambos empobrece a API.

### 2. O avaliador online não substitui `har_eval()`

`har_eval()` continua útil para comparação final de deteções binárias.

`har_stream_eval()` complementa com:

- DP
- DL
- métricas agregadas por batch
- desempenho temporal

### 3. O batch é uma política de execução, não uma propriedade do detector

O paper mostra que o batch altera desempenho e custo. Logo, ele pertence ao orquestrador experimental, não ao método em si.

### 4. O suporte a Kafka deve ser periférico

A abstração central precisa funcionar perfeitamente com dados simulados. Kafka entra como adaptador de produção, não como centro da arquitetura.

No contexto desta proposta, isso deve ser levado ao extremo: o pacote não implementa o cliente Kafka, apenas o stub da source e o ponto de integração com o coletor Python.

### 5. A incorporação deve ser incremental

Não vale reescrever o pacote inteiro em torno do online.

### 6. A camada online deve depender do `harbinger`, e não o contrário

O núcleo já estabelecido de detectores, avaliação e visualização continua sendo a base estável.

A nova camada online:

- chama `fit()` e `detect()` dos detectores existentes
- reaproveita objetos de avaliação quando fizer sentido
- acrescenta tracing, orquestração e métricas online

Ela não redefine o funcionamento normal do pacote.

## Fases de implementação

### Fase 1. Núcleo online mínimo

Entregar:

- source simulada
- sessão online pull
- memória full e sliding
- executor `refit_full`
- trace estruturado
- `har_stream_eval()` com DP e DL

Essa fase já cobre o paper e substitui o protótipo do `nexus` para dados simulados.

### Fase 2. Integração experimental

Entregar:

- `har_stream_experiment()`
- grade de execução para `warmup`, `batch_size`, `memory`
- comparação com `har_eval()`
- exemplos reprodutíveis em `examples/`

### Fase 3. Push e produção

Entregar:

- `ingest()`
- fila interna
- suporte push
- stub Kafka com contrato para `reticulate`

O consumo efetivo de Kafka continua fora do pacote, na camada Python.

### Fase 4. Detectores incrementalmente nativos

Entregar:

- otimizações específicas para métodos online reais
- por exemplo, executor incremental para `hcp_page_hinkley`

## Testes recomendados

### Unitários

- source simulada entrega observações na ordem correta
- memória full e sliding preservam o número correto de batches
- trace registra `bf`, `df` e `fdb` corretamente
- DP e DL batem com exemplos sintéticos simples

### Integração

- uma execução com `har_source_simulated()` reproduz resultados esperados
- `har_stream_experiment()` compara múltiplas configurações
- detectores offline continuam funcionando no modo online por refit
- detectores offline continuam funcionando fora do modo online sem qualquer alteração de comportamento

### Regressão metodológica

- cenários pequenos com resultados manuais verificáveis
- comparação entre `batch_size = 1` e batches maiores
- comparação entre `memory = full` e `memory = sliding(m)`
- validação de que exemplos e fluxos legados do `harbinger` continuam executando

## Riscos

### Risco 1. Acoplamento excessivo com detectores offline

Mitigação:

- manter estratégias de execução explícitas
- documentar que nem todo método é incremental

### Risco 2. Dependências de Kafka

Mitigação:

- manter Kafka fora do núcleo
- fornecer apenas stub e contrato de source
- delegar consumo efetivo a Python via `reticulate`

### Risco 3. Confusão entre resultado final e comportamento online

Mitigação:

- separar `detection`, `trace` e `evaluation`

### Risco 4. API excessivamente grande

Mitigação:

- começar com poucas abstrações centrais e nomes coesos

## Recomendação final

O melhor desenho para incorporar o `nexus` no `harbinger` é tratá-lo como uma camada de execução online orientada a:

- sources
- sessões
- políticas de memória
- estratégias de execução
- tracing e avaliação online

Isso preserva a qualidade do `harbinger`, absorve as contribuições reais do paper e evita carregar a estrutura monolítica do protótipo.

Mais importante: isso atende ao requisito de que todo o código prévio do `harbinger` continue funcionando, enquanto as novas capacidades online operam reutilizando o que o pacote já possui.

Em termos práticos, eu recomendaria começar por uma primeira entrega com:

- `har_source_simulated()`
- `har_online_session()`
- `har_memory_full()` e `har_memory_sliding()`
- `har_online_refit_full()`
- `har_stream_eval()`

Se essa base estiver correta, o restante passa a ser expansão natural e não remendo arquitetural.

Para Kafka, a primeira entrega deve conter somente:

- `har_source_kafka()` como stub
- documentação do contrato esperado do coletor Python
- pontos de extensão para `reticulate`

Não recomendo implementar consumo Kafka nativo em R dentro do `harbinger`.
