#!python

import random

lower_case = "abcdefghijklmnopqrstuvwxyz"
upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
digits = "0123456789"
special = "&$#."

all = lower_case + upper_case + digits + special

password = []
for i in range(20):

    randomchar = random.choice(all)
    password.append(randomchar)

print("".join(password))
