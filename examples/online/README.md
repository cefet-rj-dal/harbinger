# Online Architecture

This folder contains the source R Markdown notebooks for the online execution
layer of `harbinger`.

Its role is twofold:

- explain the architectural model of the online layer
- validate the public API through focused notebooks that exercise the installed
  package interface

## Mental model

The online layer is additive. It does not replace the existing `harbinger`
workflow of detector creation, `fit()`, `detect()`, and `evaluate()`. Instead,
it wraps that workflow with a streaming orchestration layer.

The architecture can be read as the following pipeline:

1. `source`
   A source defines where observations come from. This can be a simulated
   source, a data-frame replay source, a callback-based source, or the Kafka
   stub that marks the Python integration boundary.
2. `session`
   A session is the execution state of one online run. It owns the current
   in-memory series, warm-up progress, batching state, and the trace used for
   online evaluation.
3. `memory policy`
   A memory policy defines how much history is preserved before each detection
   cycle. This lets the same detector be studied under full or bounded-memory
   streaming conditions.
4. `execution strategy`
   An execution strategy defines how the detector is invoked at each batch:
   full refit, detect-only, or incremental when detector support exists.
5. `trace`
   The trace records how each observation behaves across batches. This is the
   basis for Detection Probability and Detection Lag.
6. `evaluation`
   `har_stream_eval()` summarizes the trace and optionally combines it with the
   final hard evaluation against a labeled reference.
7. `experiment line`
   `har_stream_experiment()` repeats this process across grids of warm-up,
   batch size, and memory configuration.

## Suggested reading order

- [01-source-family.Rmd](/Rmd/online/01-source-family.Rmd) - source constructors and the normalized observation contract.
- [02-online-session-simulated.Rmd](/Rmd/online/02-online-session-simulated.Rmd) - minimum integrated online session using an existing detector.
- [03-memory-policies.Rmd](/Rmd/online/03-memory-policies.Rmd) - how memory policies change the execution context.
- [04-execution-strategies.Rmd](/Rmd/online/04-execution-strategies.Rmd) - how the online layer invokes the detector at each batch.
- [05-stream-evaluator.Rmd](/Rmd/online/05-stream-evaluator.Rmd) - independent validation of Detection Probability and Detection Lag summaries.
- [06-stream-experiment.Rmd](/Rmd/online/06-stream-experiment.Rmd) - compact experiment line over warm-up, batch size, and memory settings.
- [07-kafka-stub.Rmd](/Rmd/online/07-kafka-stub.Rmd) - Kafka stub and the integration boundary for Python collectors via `reticulate`.
