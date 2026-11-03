# Sphinx configuration for the PatchClampOM documentation site.
#
# Build from the repository root (the source directory is the repo root so that the
# existing Markdown links such as ../PatchClamp/Icons/*.png and ../Tutorials/ keep working):
#
#   pip install -r docs/requirements.txt
#   sphinx-build -c docs -b html . docs/_build/html
#
# Only the files listed in `include_patterns` are part of the site.

project = "PatchClampOM"
author = "G. J. Félix-Martínez"
copyright = "2026, G. J. Félix-Martínez (MIT License)"
html_title = "PatchClampOM documentation"

master_doc = "docs/index"
root_doc = "docs/index"

extensions = [
    "myst_parser",
    "sphinx_copybutton",
]

source_suffix = {".md": "markdown"}

include_patterns = [
    "docs/*.md",
    "Tutorials/*.md",
    "CONTRIBUTING.md",
    "PatchClamp/Icons/*.png",
    "docs/diagrams/*.png",
]
# reviewer-guide.md is an internal checklist for the paper review (refers to private files): not published
exclude_patterns = ["docs/_build", "docs/diagrams/*.log", "**/.DS_Store", "docs/reviewer-guide.md"]

myst_enable_extensions = ["dollarmath", "amsmath", "colon_fence", "deflist"]
myst_heading_anchors = 3
# Links to Modelica source files in the repository are not documents of this site.
myst_all_links_external = False

# Math rendered by MathJax (loaded by the theme)
mathjax3_config = {"tex": {"inlineMath": [["$", "$"], ["\\(", "\\)"]]}}

html_theme = "furo"
html_static_path = []
html_theme_options = {
    "source_repository": "https://github.com/gjfelix/PatchClampOM/",
    "source_branch": "main",
    "source_directory": "",
}
