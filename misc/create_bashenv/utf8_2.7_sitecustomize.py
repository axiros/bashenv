import sys
reload(sys)
utf8="UTF-8"
sys.setdefaultencoding(utf8)
sys.getfilesystemencoding = lambda: utf8

