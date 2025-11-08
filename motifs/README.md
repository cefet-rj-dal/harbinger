---
title: "Motifs — Examples Index"
output: github_document
---

# Motifs — Examples Index

This directory contains example R Markdown notebooks for motif and discord discovery in Harbinger.

## Examples

- [hdis_mp_stamp.md](/examples/motifs/hdis_mp_stamp.md) — STOMP motif discovery: Matrix Profile-based discord discovery identifies rare subsequences whose nearest-neighbor distance is large.
- [hdis_sax.md](/examples/motifs/hdis_sax.md) — SAX motif discovery: SAX discretizes z-normalized subsequences into symbolic words; discords emerge as rare words or windows with large symbolic distance to their neighbors.
- [hmo_mp_pmp.md](/examples/motifs/hmo_mp_pmp.md) — PMP motif discovery: PMP (Pan-Matrix Profile) unifies matrix profiles across multiple dimensions or parameters to expose motifs that persist under variations.
- [hmo_mp_scrimp.md](/examples/motifs/hmo_mp_scrimp.md) — SCRIMP motif discovery: Matrix Profile methods compute nearest-neighbor distances for subsequences.
- [hmo_mp_stamp.md](/examples/motifs/hmo_mp_stamp.md) — STAMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence, enabling efficient discovery of repeated patterns (motifs).
- [hmo_mp_stomp.md](/examples/motifs/hmo_mp_stomp.md) — STOMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence.
- [hmo_mp_valmod.md](/examples/motifs/hmo_mp_valmod.md) — VALMOD motif discovery: VALMOD maintains the Matrix Profile under streaming updates, enabling motif discovery in evolving series.
- [hmo_sax.md](/examples/motifs/hmo_sax.md) — SAX motif discovery: SAX (Symbolic Aggregate approXimation) discretizes z-normalized subsequences into symbolic words using breakpoints derived from a Gaussian distribution.
- [hmo_xsax.md](/examples/motifs/hmo_xsax.md) — XSAX motif discovery: XSAX extends SAX to a larger alphanumeric alphabet, allowing finer symbolic resolution.

