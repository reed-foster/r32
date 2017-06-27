import random
import math

randarray = [random.randint(0, 2 ** 16 - 1) for i in range(512)]
formattedstr = ""

for i in range(len(randarray)):
    # array <= (0 => x"abcd", 1 => x"1234", ...)
    hexval = hex(randarray[i])[2:]
    formattedstr += str(i) + ' => x"' + hexval + '", '
    formattedstr += (" " * (2 - int(math.log(i + 0.5, 10))))
    formattedstr += ("0" * (4 - len(hexval)))
    if (i % 16 == 15 and i > 0):
        formattedstr += "\n"
print formattedstr
