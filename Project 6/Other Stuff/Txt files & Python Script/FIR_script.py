import numpy as np
import struct 
from ctypes import *

def convert(s):
    i = int(s, 16)                   # convert from hex to a Python int
    cp = pointer(c_int(i))           # make this into a c integer
    fp = cast(cp, POINTER(c_float))  # cast the int pointer to a float pointer
    return fp.contents.value         # dereference the pointer, get the float

inputs_int = np.zeros(1000)
coef_int = np.zeros(201)

inputs_string = np.loadtxt('Inputs.txt', dtype = str, delimiter = ' ')
for i in range(1000):
	inputs_int[i] = convert(inputs_string[i])

coef_string = np.loadtxt('Coefficients.txt', dtype = str, delimiter = ' ')
for i in range(201):
	coef_int[i] = convert(coef_string[i])

# np.savetxt('Inputs_int.txt', inputs_int, delimiter = ' ')
# np.savetxt('Coef_int.txt', coef_int, delimiter = ' ')


total_sum = 0
counter = 0
for i in range(201):
	for j in range(counter):
		


