#!/usr/bin/env python
# -*- coding: utf-8 -*- #

AUTHOR = 'Adrien Faure'
SITENAME = 'Luk-2000 and the Fragments of the Past'
SITEURL = ''

PATH = 'content'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Ludum Dare', 'https://ldjam.com/'),
         ('Godot', 'https://godotengine.org/'),)


# THEME = "themes/pelican-hss"

DEFAULT_PAGINATION = False

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
SHOW_SOCIAL_SHARE_BUTTON = False

STATIC_PATHS = [ 'images', 'games/LD48-release' ]
# Otherwise pelican try to render our game
ARTICLE_EXCLUDES = [ 'games' ]
# Otherwise pelican delete sources (.html)
STATIC_EXCLUDE_SOURCES = False