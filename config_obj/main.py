# https://configobj.readthedocs.io/en/latest/configobj.html
# https://github.com/DiffSK/configobj

from configobj import ConfigObj

cfg = ConfigObj("_text.in")


print(f"*** {cfg.comments = }")
print(f"*** {cfg.inline_comments = }")
print(f"*** {cfg.BOM = }")
print(f"*** {cfg.items = }")
print(f"*** {cfg.values = }")

cfg.filename = "_text.out"
cfg.write()







