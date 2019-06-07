__all__ = ["crashlog", "heap"]
for x in __all__:
    __import__('lldb.macosx.'+x)
