# Streaming data sources for Harbinger

The online layer of Harbinger consumes observations through source
objects. A source abstracts how new observations are collected, allowing
the online session to work with simulated vectors, data frames,
callback-based feeds, and external stream collectors.

The source API is intentionally small:

- [`next_observation()`](https://cefet-rj-dal.github.io/harbinger/reference/next_observation.md)
  requests the next observation in pull mode;

- [`source_info()`](https://cefet-rj-dal.github.io/harbinger/reference/source_info.md)
  exposes source metadata.

An observation consumed by the online layer is normalized to a list
with:

- `idx`: logical position in the stream when known;

- `value`: the payload used by the detector;

- `timestamp`: optional temporal marker;

- `payload`: original payload preserved for adapters that need it.

Kafka support in this package is intentionally limited to a stub
interface. Actual collection is expected to be delegated to Python code
integrated via `reticulate`.

## Value

Source object.
