# Motif and Discord Examples

This folder covers repeated subsequences and rare subsequences. It is best studied after the reader is already comfortable with the basic workflow, because motif methods often depend on choices such as window size and symbolic representation.

The notebooks are grouped by conceptual family so the reader can separate Matrix Profile methods from symbolic ones before comparing their outputs. This makes the material less about memorizing algorithm names and more about understanding which representation of similarity is being used.

## Matrix Profile

Start here if the goal is to learn motif discovery from a distance-based subsequence perspective.

- [01-matrix-profile-hmo_mp_stamp.md](/examples/motifs/01-matrix-profile-hmo_mp_stamp.md) - `hmo_mp("stamp", ...)`: approximate Matrix Profile motif discovery.
- [02-matrix-profile-hmo_mp_stomp.md](/examples/motifs/02-matrix-profile-hmo_mp_stomp.md) - `hmo_mp("stomp", ...)`: exact Matrix Profile motif discovery with STOMP.
- [03-matrix-profile-hmo_mp_scrimp.md](/examples/motifs/03-matrix-profile-hmo_mp_scrimp.md) - `hmo_mp("scrimp", ...)`: anytime Matrix Profile workflow.
- [04-matrix-profile-hmo_mp_pmp.md](/examples/motifs/04-matrix-profile-hmo_mp_pmp.md) - `hmo_mp("pmp", ...)`: Pan Matrix Profile for multiple window sizes.
- [05-matrix-profile-hmo_mp_valmod.md](/examples/motifs/05-matrix-profile-hmo_mp_valmod.md) - `hmo_mp("valmod", ...)`: variable-length motif discovery.

## Symbolic Methods

Then move to symbolic methods, where repeated behavior is expressed through discretized patterns instead of direct numeric distance.

- [06-symbolic-hmo_sax.md](/examples/motifs/06-symbolic-hmo_sax.md) - `hmo_sax()`: motif discovery over SAX codes.
- [07-symbolic-hmo_xsax.md](/examples/motifs/07-symbolic-hmo_xsax.md) - `hmo_xsax()`: motif discovery over XSAX codes.

## Discord Analysis

Finish with discords, because these notebooks invert the question: instead of asking what repeats, they ask which subsequences are unusually different from the rest.

- [08-discord-hdis_mp_stamp.md](/examples/motifs/08-discord-hdis_mp_stamp.md) - discord discovery with Matrix Profile.
- [09-discord-hdis_sax.md](/examples/motifs/09-discord-hdis_sax.md) - discord discovery with symbolic discretization.
