import numpy as np
import matplotlib
import matplotlib.pyplot as plt

# Nastavme si startovaciu a cielovu poziciu
# Mapa má 20x30 (y,x)

#Start pozicia y,x
startovaciaPozicia = [10,10]
#Ciel pozicia y,x
cielovaPozicia = [11,27]


def finderFunction(x, o):
    position = np.zeros(3,dtype=np.int32)
    for i in range(20):
        for j in range(30):
            if tab[i,j] == x:
                position[0] = i
                position[1] = j
                position[2] = position[2]+1
            if position[2] == o:
                break
        if position[2] == o:
            break
    return position

tab = np.zeros((20,30),dtype=np.int32)
newTab = np.zeros((20,30),dtype=np.int32)

#Zostav mapu
for i in range(5):
    for j in range(5):
        tab[i,j+9] = 2
        tab[9+i,24] = 2
        tab[15+i,5] = 2
        tab[10,i] = 2
        tab[i+15,j+15] = 2
        newTab[i,j+9] = 2
        newTab[9+i,24] = 2
        newTab[15+i,5] = 2
        newTab[10,i] = 2
        newTab[i+15,j+15] = 2

tab[startovaciaPozicia[0],startovaciaPozicia[1]] = 1
newTab[startovaciaPozicia[0],startovaciaPozicia[1]] = 1
tab[cielovaPozicia[0],cielovaPozicia[1]] = 3
newTab[cielovaPozicia[0],cielovaPozicia[1]] = 3

start = 3
ccd = 0
number = finderFunction(start, -1)
compare = finderFunction(0,-1)
temp = 0

while compare[2]>0:
    start = start + 1

    if number[0] + 1 < 20 and tab[number[0]+1,number[1]] == 0:
        tab[number[0]+1,number[1]] = start
    if number[1] - 1 >= 0 and tab[number[0],number[1]-1] == 0:
        tab[number[0],number[1]-1] = start
    if number[1] + 1 < 30 and tab[number[0],number[1]+1] == 0:
        tab[number[0],number[1]+1] = start
    if number[0] - 1 >= 0 and tab[number[0]-1,number[1]] == 0:
        tab[number[0]-1,number[1]] = start
    if number[2]>1:
        start = start -1
    if number[2]-1 == 0:
        ccd = -1
    else:
        ccd = number[2] - 1
    
    number = finderFunction(start,ccd)
    compare = finderFunction(0,-1)
    temp = temp + 1

#Hladam cestu

Actual = finderFunction(1,-1)
step = np.array([0,0,100,0])
step2 = np.array([0,0,100,0])

temp = 0

while tab[Actual[0], Actual[1]] != 3:
    if tab[Actual[0]+1, Actual[1]] != 1 and tab[Actual[0]+1,Actual[1]] != 2 and Actual[0]+1 <20:
        step[0] = Actual[0] + 1
        step[1] = Actual[1] + 0
        step[2] = tab[Actual[0] + 1, Actual[1]]
        step[3] = 1; 

        if step[2] >= step2[2]:
            step = step2
    
    if Actual[1] -1 >= 0 and tab[Actual[0],Actual[1]-1] != 2 and tab[Actual[0], Actual[1]-1] != 1:
        step2[0] = Actual[0] + 0
        step2[1] = Actual[1] - 1
        step2[2] = tab[Actual[0], Actual[1]-1]
        step2[3] = 2

        if step[2] >= step2[2]:
            step = step2
    
    if Actual[0] -1 >= 0 and tab[Actual[0]-1, Actual[1]] != 2 and tab[Actual[0]-1, Actual[1]] != 1:
        step2[0] = Actual[0] - 1
        step2[1] = Actual[1] + 0
        step2[2] = tab[Actual[0]-1, Actual[1]]
        step2[3] = 1
        if step[2] >= step2[2]:
            step = step2

    if Actual[1] +1 < 30 and tab[Actual[0], Actual[1]+1] != 2 and tab[Actual[0], Actual[1]+1] != 1:
        step2[0] = Actual[0] + 0
        step2[1] = Actual[1] + 1
        step2[2] = tab[Actual[0], Actual[1]+1]
        step2[3] = 2
        if step[2] >= step2[2]:
            step = step2
    
    Actual = step
    Actual[2] = 0

    if newTab[Actual[0],Actual[1]] != 3:
        newTab[Actual[0],Actual[1]] = 4
    
    temp = temp +1

    step = np.array([0,0,100,0])
    step2 = np.array([0,0,100,0])

#SHOW IT
fig, ax = plt.subplots()

im = ax.imshow(tab, interpolation=None)
#Revert y
ax.set_ylim(ax.get_ylim()[::-1])
# We want to show all ticks...
ax.set_xticks(np.arange(30))
ax.set_yticks(np.arange(20))
# Rotate the tick labels and set their alignment.
plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
         rotation_mode="anchor")

# Loop over data dimensions and create text annotations.
for i in range(20):
    for j in range(30):
        text = ax.text(j, i, tab[i, j],
                       ha="center", va="center", color="w")
ax.set_title("Costmapa")
fig.tight_layout()

#SHOW IT
fig2, ax2 = plt.subplots()

im2 = ax2.imshow(newTab, interpolation=None)
#Revert y
ax2.set_ylim(ax2.get_ylim()[::-1])
# We want to show all ticks...
ax2.set_xticks(np.arange(30))
ax2.set_yticks(np.arange(20))
# Rotate the tick labels and set their alignment.
plt.setp(ax2.get_xticklabels(), rotation=45, ha="right",
         rotation_mode="anchor")

# Loop over data dimensions and create text annotations.
for i in range(20):
    for j in range(30):
        text = ax2.text(j, i, newTab[i, j],
                       ha="center", va="center", color="w")
ax2.set_title("Trasa")
fig2.tight_layout()
plt.show()