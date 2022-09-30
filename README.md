# APPUiO Community Documentation Source

❗**ARCHIVED** ❗

This documentation is archived and doesn't reflect the current state anymore.
It was targetting APPUiO Public and OpenShift 3, both are deprecated since summer 2022.

The documentation for APPUiO Cloud (targetting OpenShift 4) is available under [appuio-cloud-docs]( https://github.com/appuio/appuio-cloud-docs).

---

This is the source of the [APPUiO Community Documentation](http://appuio-community-documentation.rtfd.org/)

[![Documentation Status](https://readthedocs.org/projects/appuio-community-documentation/badge/?version=latest)](http://appuio-community-documentation.readthedocs.org/en/latest/?badge=latest)

# Documentation hints

* Documentation is written in [reStructuredText](http://www.sphinx-doc.org/en/stable/rest.html) (except this README)
* Hosted by [Read the Docs](https://readthedocs.org/) - [docs](https://read-the-docs.readthedocs.io/en/latest/)

To easily test the documentation locally, install Sphinx:

```
pip install -r requirements.txt
```

Then run `sphinx-autobuild . _build_html` in the current directory and browse
to `http://127.0.0.1:8000`. The pages will be rebuilt when files change and
the browser window automatically refreshed.

# License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
