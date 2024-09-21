# Doc at:
# https://configobj.readthedocs.io/en/latest/configobj.html

from configobj import ConfigObj

print("Reading _text_0")
cfg = ConfigObj("_text_0")
print("Reading done")

print(cfg)

#def walker(section, key):
#    val = section[key]
#    print("")
#    print(f"{section = }, {key = }, {val = }")
#    print(f"{type(section) = }, {type(key) = }, {type(val) = }")
#
#cfg.walk(walker, call_on_sections=True)

#cfg["env"]["aaa"] = "xyz"

cfg.write()







