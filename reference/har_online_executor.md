# Online execution strategies

Execution strategies tell a Harbinger online session how the underlying
detector should be invoked when a new batch is ready.

This makes the adaptation from offline detectors to streaming operation
explicit instead of implicit.

For detector authors, the incremental strategy assumes an optional
`online_update(obj, serie, ...)` function stored in the detector object.
When present, it must return the updated detector after incorporating
the current in-memory series. If absent, the incremental strategy
behaves like detect-only execution.
