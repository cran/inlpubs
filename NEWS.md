# inlpubs 1.1.1

- Fix lost braces in `make_wordcloud` help documentation.

# inlpubs 1.1.0

- Vignettes have undergone significant revisions.
- Help documentation for the `make_wordcloud` function has been exposed.
- In the `pubs` dataset, the `key` field has been renamed to `pub_id`,
  and the `citation` field has been renamed to `bibentry`.
- The `pubs` dataset has been enhanced by incorporating additional fields such as
  `institution`, `type`, `text_ref`, `author_id`, `title`, and `annotation_src`.
- An `authors` dataset has been added, which contains contributing authors to INLPO publications.
- Additional citations have been added.
- The functionality of the **DT** package has been replaced with that of the **reactable** package.
- The raw-data format has been changed from TSV to JSON.
- A unit test for text mining (issue #3) has been added.

# inlpubs 1.0.6

- Add additional citations
- Switch Git repository name from `master` to `main`.
- Bump R version requirement from `4.0` to `4.1`.
- Add all branches to `code.json` file.

# inlpubs 1.0.4

- Add additional citations
- Remove dependency on **inlmisc** package.

# inlpubs 1.0.3

- Configure package website for GitHub deployment.

# inlpubs 1.0.2

- Remove dependency on **inlpubs** package in the CITATION file.

# inlpubs 1.0.1

- Fix invalid URLs.

# inlpubs 1.0.0

- Host repo on USGS OpenSource GitLab (code.usgs.gov).
