import logging
import os
import re
import sys
from collections import defaultdict
from importlib import import_module


def outputURLs():
    import django

    django.setup()

    from django.conf import settings
    from django.contrib.admindocs.views import simplify_regex
    from django.core.exceptions import ViewDoesNotExist
    from django.urls import URLPattern, URLResolver

    root_url_module_name = getattr(settings, "ROOT_URLCONF", {})
    root_url_module = import_module(root_url_module_name)
    patterns = root_url_module.urlpatterns

    def extract_views_from_urlpatterns(urlpatterns, base="", namespace=None):
        """
        Return a list of views from a list of urlpatterns.
        Each object in the returned list is a three-tuple: (view_func, regex, name)
        """
        views = []
        for p in urlpatterns:
            if isinstance(p, URLPattern):
                try:
                    if not p.name:
                        name = p.name
                    elif namespace:
                        name = "{0}:{1}".format(namespace, p.name)
                    else:
                        name = p.name
                    pattern = str(p.pattern)
                    views.append((p.callback, base + pattern, name))
                except ViewDoesNotExist:
                    continue
            elif isinstance(p, URLResolver):
                try:
                    patterns = p.url_patterns
                except ImportError:
                    continue
                if namespace and p.namespace:
                    _namespace = "{0}:{1}".format(namespace, p.namespace)
                else:
                    _namespace = p.namespace or namespace
                pattern = str(p.pattern)
                views.extend(
                    extract_views_from_urlpatterns(
                        patterns, base + pattern, namespace=_namespace
                    )
                )
            elif hasattr(p, "_get_callback"):
                try:
                    views.append((p._get_callback(), base + str(p.pattern), p.name))
                except ViewDoesNotExist:
                    continue
            elif hasattr(p, "url_patterns") or hasattr(p, "_get_url_patterns"):
                try:
                    patterns = p.url_patterns
                except ImportError:
                    continue
                views.extend(
                    extract_views_from_urlpatterns(
                        patterns, base + str(p.pattern), namespace=namespace
                    )
                )
            else:
                raise TypeError("%s does not appear to be a urlpattern object" % p)
        return views

    view_functions = extract_views_from_urlpatterns(patterns)

    # The script is meant to be called like:
    # python3 get_urls.py CommentCreate
    #
    # The view name needs to be passed as the 'second' argument with respect
    # to the python binary.
    # Actually, it is the third argument but when using the python binary, it
    # gets put at argv[1] and not argv[2]
    to_find_viewname = sys.argv[1]

    urls = defaultdict(list)
    for func, regex, url_name in view_functions:
        if hasattr(func, "__name__"):
            func_name = func.__name__
        elif hasattr(func, "__class__"):
            func_name = "%s()" % func.__class__.__name__
        else:
            func_name = re.sub(r" at 0x[0-9a-f]+", "", repr(func))

        module = "{0}.{1}".format(func.__module__, func_name)
        url_name = url_name or ""
        url = simplify_regex(regex)
        urls[func_name].append(url)

    # TODO Lua strings are single byte strings, so writing
    # utf-8 encoded strings should be avoided.
    sys.stdout.write((os.linesep).join(urls[to_find_viewname]))


if __name__ == "__main__":
    logging.basicConfig(filename="djist.log", encoding="utf8", level=logging.DEBUG)

    # The Django Project root must be in sys.path for Django to do its
    # setup correctly.
    sys.path.append(os.getcwd())

    try:
        import_module(os.environ.get("DJANGO_SETTINGS_MODULE", ""))
    except (ImportError, ModuleNotFoundError, TypeError) as e:
        logging.error(f"{e!r}")
        logging.error(
            "The DJANGO_SETTINGS_MODULE environment variable is not set correctly."
        )
        sys.exit(1)
    else:
        outputURLs()
