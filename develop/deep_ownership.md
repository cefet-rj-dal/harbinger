# Propriedade dos exemplos Deep ++

Atualizado em 2026-11-28.

Os contratos genéricos `han_autoencoder()` e `hcp_waypoint()` permanecem no harbinger para
preservar a API e permitir que qualquer encoder compatível seja injetado. As implementações
PyTorch concretas pertencem à camada Deep ++:

- Python: `pydaltoolboxdp.HanAutoencoder` e `pydaltoolboxdp.HcpWaypoint`, ambos sobre
  `pyharbinger.Harbinger`;
- R: os autoencoders concretos continuam expostos por daltoolboxdp e são usados pelos
  contratos genéricos do harbinger.

Os 12 exemplos concretos (dois `hanr_ml` deep, sete autoencoders e três Waypoint), com
fontes Rmd, Markdown, scripts e figuras, foram transferidos para daltoolboxdp. Seus pares
Python executáveis vivem em pydaltoolboxdp. Os índices do harbinger deixaram de anunciá-los.

O gate R↔Python usou o mesmo backend PyTorch e confirmou resíduos a `1e-7`, eventos
idênticos e o mesmo `tau` no Waypoint. Esta migração não altera a matemática nem remove os
construtores públicos do harbinger.
