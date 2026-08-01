# .bib Entry Templates

## @article (journal paper)

```bibtex
@article{smith2023transformers,
  author  = {Smith, Jane and Doe, John},
  title   = {A Study of Transformer Architectures},
  journal = {Journal of Machine Learning Research},
  volume  = {24},
  number  = {1},
  pages   = {1--30},
  year    = {2023},
  doi     = {10.xxxx/xxxxx}
}
```
Required: author, title, journal, year. Strongly recommended: volume, pages, doi.

## @inproceedings (conference paper)

```bibtex
@inproceedings{lee2022retrieval,
  author    = {Lee, Alex},
  title     = {Retrieval-Augmented Generation for Enterprise QA},
  booktitle = {Proceedings of the International Conference on AI},
  pages     = {200--210},
  year      = {2022},
  publisher = {ACM}
}
```
Required: author, title, booktitle, year.

## @book

```bibtex
@book{knuth1997art,
  author    = {Knuth, Donald E.},
  title     = {The Art of Computer Programming, Volume 1},
  publisher = {Addison-Wesley},
  year      = {1997},
  edition   = {3rd}
}
```
Required: author, title, publisher, year.

## @misc (websites, tech reports, informal sources)

```bibtex
@misc{anthropic2025docs,
  author       = {{Anthropic}},
  title        = {Claude Developer Documentation},
  year         = {2025},
  howpublished = {\url{https://docs.claude.com}},
  note         = {Accessed: 2026-07-31}
}
```
Always include an "Accessed" date for web sources since page content can change.

## @phdthesis / @mastersthesis

```bibtex
@mastersthesis{nguyen2024agentic,
  author = {Nguyen, Priya},
  title  = {Agentic Tool-Use in Enterprise LLM Systems},
  school = {Georgia Institute of Technology},
  year   = {2024}
}
```

## @techreport

```bibtex
@techreport{acme2021whitepaper,
  author      = {{Acme Corp}},
  title       = {Internal Benchmarking of Vector Databases},
  institution = {Acme Corp},
  year        = {2021},
  number      = {TR-2021-04}
}
```

## Organization/Corporate Author (no individual author)

Wrap in double braces to prevent BibTeX from treating it as a first/last name pair:
```bibtex
author = {{World Health Organization}},
```
