#Permutation
P = [0,33,66,99,  96,1,34,67,  64,97,2,35, 32,65,98,3, 4,37,70,103, 100,5,38,71,68,101,6,39,36,69,102,7,8,41,74,107,104,9,42,75,72,105,10,43,40,73,106,11,12,45,78,111,108,13,46,79,76,109,14,47,44,77,110,15,16,49,82,115,112,17,50,83,80,113,18,51,48,81,114,19,20,53,86,119,116,21,54,87,84,117,22,55,52,85,118,23,24,57,90,123,120,25,58,91,88,121,26,59,56,89,122,27,28,61,94,127,124,29,62,95,92,125,30,63,60,93,126,31]

PIN = [0]*128

#Inverse of P
for i in range(128):
  PIN[P[i]] = i

#SBox of the DEFAULT LAYER
def Sbox(x0,x1,x2,x3):
  y0 =  x0 + x1 + x2
  y1 =  x0*x1 + x0*x2 + x0 + x1*x3 + x1 + x2*x3
  y2 =  x1 + x2 + x3
  y3 =  x0*x1 + x0*x2 + x1*x3 + x2*x3 + x2 + x3
  return([y0%2,y1%2,y2%2,y3%2])


#Inverse of the SBox of the DEFAULT LAYER
def Sboxin(x0,x1,x2,x3):
  y0 =  x1 + x2 + x3
  y1 = x0*x1 + x0*x3 + x0 + x1*x2 + x2*x3 + x3
  y2 = x0*x1 + x0*x3 + x1*x2 + x1 + x2*x3 + x2
  y3 = x0 + x1 + x3
  return([y0%2,y1%2,y2%2,y3%2])



K = [0]*128
S = [0]*128
S0= [0]*128

for i in range(128):
   K[i] = ZZ.random_element(2)
   
   S[i] = ZZ.random_element(2)
   S0[i] = S[i]




i = 0
while(i<128):
   A = Sbox(S[i],S[i+1],S[i+2],S[i+3])
   S[i] = A[0]
   S[i+1] = A[1]
   S[i+2] = A[2]
   S[i+3] = A[3]
   i = i+4

S1 = [0]*128
for i in range(len(S)):
        S1[P[i]] = S[i] 


#Add key  
for i in range(128):
        S[i] = (S1[i]+K[i])%2
        S1[i] = S[i]


#Try to find 16 key bits at positions (0,1,2,3, 32,33,34,35, 64,65,66,67, 96,97,98,99). This corresponds  to the first 4 values of the permutation
VAL = [0,33,66,99]

VAL.sort()

K_OP = []


FAULT1 = 2 #Corresponds to last round fault


FAULT1 = FAULT1+1

for l in range(4):

 k = []
 
 nib = floor(VAL[l]/4)

 Y = []
 Z = []
 Z0 = []

 for j in range(FAULT1):
  for i in range(128):
     S[i] = S1[i]

  if(j>0):
    X = ZZ(j).digits(base = 2, padto = 4)
    for i in range(4):
       S[i+4*nib] = (S[i+4*nib]+X[i])%2
    Y.append(X)
  
  i = 0
  while(i<128):
   A = Sbox(S[i],S[i+1],S[i+2],S[i+3])
   S[i] = A[0]
   S[i+1] = A[1]
   S[i+2] = A[2]
   S[i+3] = A[3]
   i = i+4




  #Add key  
  for i in range(128):
        S[i] = (S[i]+K[i])%2

  if(j==0):
    Z0.append(S[0+4*nib])
    Z0.append(S[1+4*nib])
    Z0.append(S[2+4*nib])
    Z0.append(S[3+4*nib]) 
  if(j>0):
    Z.append([S[0+4*nib],S[1+4*nib],S[2+4*nib],S[3+4*nib]])

  


 i = 0
 C = []
 for i in range(FAULT1-1):
  B = []
  for x in range(16):
    y = ZZ(x).digits(base = 2, padto = 4)
    a = [(Z0[0]+y[0])%2,(Z0[1]+y[1])%2,(Z0[2]+y[2])%2, (Z0[3]+y[3])%2]
    a = Sboxin(a[0],a[1],a[2],a[3])
    
    b = [(Z[i][0]+y[0])%2,(Z[i][1]+y[1])%2,(Z[i][2]+y[2])%2, (Z[i][3]+y[3])%2] 
    b = Sboxin(b[0],b[1],b[2],b[3])
    c = []
    for j in range(4):
       c.append((a[j]+b[j])%2)
    if(c==Y[i]):
       B.append(x)
  C.append(B)

 for i in range(1,FAULT1-1):
  C[0] = Set(C[0]).intersection(Set(C[i]))

 for i in range(len(C[0])):
   x = C[0][i]
   y = ZZ(x).digits(base = 2, padto = 4)
   k.append(y)
 K_OP.append(k)


K_OPTION = []


U = []
for l in range(4):
 nib = floor(VAL[l]/4)
 
 for i in range(4):
       U.append(K[i+4*nib])

print('Actual = ', U)


for i1 in range(len(K_OP[0])):
  for i2 in range(len(K_OP[1])):
     for i3 in range(len(K_OP[2])):
        for i4 in range(len(K_OP[3])):
           a = []
           for i in range(4):
             a.append(K_OP[0][i1][i]) 
           for i in range(4):
             a.append(K_OP[1][i2][i]) 
           for i in range(4):
             a.append(K_OP[2][i3][i]) 
           for i in range(4):
             a.append(K_OP[3][i4][i]) 
           K_OPTION.append(a)



print('Number of options after last round fault for 16 bits of key', len(K_OPTION))


aa = floor(VAL[0]/4)
A = []
for l in range(4):
  for i in range(4):
    A.append(P[i+4*l+16*aa])
  
A.sort()

for l in range(4):
 Y = []
 Z0 = []
 Z = []

 FAULT2 = 2

 FAULT2 = FAULT2+1
 for j in range(FAULT2):

  for i in range(128):
   S[i] = S0[i]

  if(j>0):
    X = ZZ(j).digits(base = 2, padto = 4)
    for i in range(4):
      S[i+4*l+16*aa] = (S[i+4*l+16*aa]+X[i])%2
    Y.append(X)

  i = 0
  while(i<128):
   A = Sbox(S[i],S[i+1],S[i+2],S[i+3])
   S[i] = A[0]
   S[i+1] = A[1]
   S[i+2] = A[2]
   S[i+3] = A[3]
   i=i+4

  S1 = [0]*128
  for i in range(len(S)):
        S1[P[i]] = S[i] 


  #Add key  
  for i in range(128):
        S[i] = (S1[i]+K[i])%2

 
  i=0
  while(i<128):
   A = Sbox(S[i],S[i+1],S[i+2],S[i+3])
   S[i] = A[0]
   S[i+1] = A[1]
   S[i+2] = A[2]
   S[i+3] = A[3]
   i = i+4

 
 
  for i in range(128):
        S[i] = (S[i]+K[i])%2

  if(j==0):
    for i in range(128):
       Z0.append(S[i])
 
    

  if(j>0):
    L = []
    for i in range(128):
       L.append(S[i])
    Z.append(L)






 
 A=[]
 for l1 in range(4):
  for i1 in range(4):
    A.append(P[i1+4*l1+16*aa])
 A.sort()

 KK = [0]*128
 K_OPTION_NEW = []



 for op in range(len(K_OPTION)):
  for i in range(16):
   KK[A[i]] = K_OPTION[op][i]
  match = 0
  for j in range(FAULT2-1):
   a = []
   b = []
   for i in range(128):
    a.append((Z0[i]+KK[i])%2)
    b.append((Z[j][i]+KK[i])%2)

   i = 0
   while(i<128):
    B = Sboxin(a[i],a[i+1],a[i+2],a[i+3])
    a[i] = B[0]
    a[i+1] = B[1]
    a[i+2] = B[2]
    a[i+3] = B[3]
    i = i+4


   i = 0
   while(i<128):
    B = Sboxin(b[i],b[i+1],b[i+2],b[i+3])
    b[i] = B[0]
    b[i+1] = B[1]
    b[i+2] = B[2]
    b[i+3] = B[3]
    i = i+4

   c = []
   d = []
   for i in range(128):
    c.append((a[i]+KK[i])%2)
    d.append((b[i]+KK[i])%2)

  
   for i in range(128):
        a[PIN[i]] = c[i] 
        b[PIN[i]] = d[i]

   i = 0
   while(i<128):
    B=Sboxin(a[i],a[i+1],a[i+2],a[i+3])
    a[i] = B[0]
    a[i+1] = B[1]
    a[i+2] = B[2]
    a[i+3] = B[3]
    i = i+4


   i = 0
   while(i<128):
    B = Sboxin(b[i],b[i+1],b[i+2],b[i+3])
    b[i] = B[0]
    b[i+1] = B[1]
    b[i+2] = B[2]
    b[i+3] = B[3]
    i = i+4
   c = [(a[4*l+16*aa]+b[4*l+16*aa])%2,(a[4*l+16*aa+1]+b[4*l+16*aa+1])%2, (a[4*l+16*aa+2]+b[4*l+16*aa+2])%2, (a[4*l+16*aa+3]+b[4*l+16*aa+3])%2]
   if(c==Y[j]):
    match=match+1
  
  if(match==FAULT2-1):
    
    K_OPTION_NEW.append(K_OPTION[op])

 print('Number of options',len(K_OPTION_NEW))
 K_OPTION = []
 for i in range(len(K_OPTION_NEW)):
   K_OPTION.append(K_OPTION_NEW[i])
 

for i in range(len(K_OPTION)):
   if(K_OPTION[i]==U):
      print('Yes match!', K_OPTION[i])



