#permutation
Perm = [0, 33, 66, 99, 96, 1, 34, 67, 64, 97, 2, 35, 32, 65, 98, 3, 4, 37, 70, 103, 100, 5, 38, 71, 68, 101, 6, 39, 36, 69, 102, 7, 8, 41, 74, 107, 104, 9, 42, 75, 72, 105, 10, 43, 40, 73, 106, 11, 12, 45, 78, 111, 108, 13, 46, 79, 76, 109, 14, 47, 44, 77, 110, 15, 16, 49, 82, 115, 112, 17, 50, 83, 80, 113, 18, 51, 48, 81, 114, 19, 20, 53, 86, 119, 116, 21, 54, 87, 84, 117, 22, 55, 52, 85, 118, 23, 24, 57, 90, 123, 120, 25, 58, 91, 88, 121, 26, 59, 56, 89, 122, 27, 28, 61, 94, 127, 124, 29, 62, 95, 92, 125, 30, 63, 60, 93, 126, 31]

#inverse permutation
Perm_in = [0]*128
for i in range(128):
    Perm_in[Perm[i]] = i

#SBox of the DEFAULT LAYER
def Sbox(x0,x1,x2,x3):
    y0 =  x0 + x1 + x2
    y1 =  x0*x1 + x0*x2 + x0 + x1*x3 + x1 + x2*x3
    y2 =  x1 + x2 + x3
    y3 =  x0*x1 + x0*x2 + x1*x3 + x2*x3 + x2 + x3
    return([y0%2,y1%2,y2%2,y3%2])

#inverse of the SBox of the DEFAULT LAYER
def Sbox_in(x0,x1,x2,x3):
    y0 =  x1 + x2 + x3
    y1 = x0*x1 + x0*x3 + x0 + x1*x2 + x2*x3 + x3
    y2 = x0*x1 + x0*x3 + x1*x2 + x1 + x2*x3 + x2
    y3 = x0 + x1 + x3
    return([y0%2,y1%2,y2%2,y3%2])

import random

#original key
K_org = [random.randint(0,1) for i in range(128)]

#original state
S_org = [random.randint(0,1) for i in range(128)]

#initial state
S = [0]*128
for i in range(128):
    S[i] = S_org[i]

#subcells operation
i = 0
while(i < 128):
    S_sb = Sbox(S[i],S[i+1],S[i+2],S[i+3])
    S[i] = S_sb[0]
    S[i+1] = S_sb[1]
    S[i+2] = S_sb[2]
    S[i+3] = S_sb[3]
    i = i+4
    
#permbits operation
S_new = [0]*128
for i in range(128):
    S_new[Perm[i]] = S[i] 

#addroundkey operation  
for i in range(128):
    S[i] = (S_new[i]+K_org[i])%2
    S_new[i] = S[i]

#storing the positions where the bits of the first nibble get permuted to after the permbits operation
Val = [0, 33, 66, 99]

#set to store the possible key candidates
K_op = []

for l in range(4):
    #set to store keys
    Key = []
    
    #nibble corresponding to the Val[l]-th bit
    Nib = floor(Val[l]/4)
    
    #set to store faults
    Y = []
    
    #set to store faulty nibble
    Z = []
    
    #set to store nibble without fault
    Z_0 = []
    
    #analysis for each of the faults
    for j in range(3):
        
        #initial state for the last round
        for i in range(128):
            S[i] = S_new[i]
            
        #changing faults in binary
        if(j > 0):
            X = ZZ(j).digits(base = 2, padto = 4)
            
            #adding the fault to the corresponding nibble
            for i in range(4):
                S[4*Nib+i] = (S[4*Nib+i]+X[i])%2
        
            #storing faults in binary
            Y.append(X)
        
        #subcells operation
        i = 0
        while(i < 128):
            S_sb = Sbox(S[i],S[i+1],S[i+2],S[i+3])
            S[i] = S_sb[0]
            S[i+1] = S_sb[1]
            S[i+2] = S_sb[2]
            S[i+3] = S_sb[3]
            i = i+4
            
        #addroundkey  
        for i in range(128):
            S[i] = (S[i]+K_org[i])%2
            
        #storing state without injecting fault
        if(j == 0):
            Z_0.append(S[4*Nib])
            Z_0.append(S[4*Nib+1])
            Z_0.append(S[4*Nib+2])
            Z_0.append(S[4*Nib+3])
            
        #storing faulty state
        if(j > 0):
            Z.append([S[4*Nib],S[4*Nib+1],S[4*Nib+2],S[4*Nib+3]])
    
    i = 0
    
    #possible key options at a nibble
    C = []
    
    #fault analysis at the last round
    for i in range(2):
        
        #possible key options for each fault
        B = []
        for x in range(16):
            y = ZZ(x).digits(base = 2, padto = 4)
            a = [(Z_0[0]+y[0])%2, (Z_0[1]+y[1])%2, (Z_0[2]+y[2])%2, (Z_0[3]+y[3])%2]
            a = Sbox_in(a[0], a[1], a[2], a[3])
            b = [(Z[i][0]+y[0])%2, (Z[i][1]+y[1])%2, (Z[i][2]+y[2])%2, (Z[i][3]+y[3])%2] 
            b = Sbox_in(b[0], b[1], b[2], b[3])
            c = []
            for j in range(4):
                c.append((a[j]+b[j])%2)
            if(c == Y[i]):
                B.append(x)
        C.append(B)
    
    #intersection of the possible key options corresponding to each fault
    for i in range(1,2):
        C[0] = Set(C[0]).intersection(Set(C[i]))
        
    #storing the key candidates from the intersection in binary
    for i in range(len(C[0])):
        x = C[0][i]
        y = ZZ(x).digits(base = 2, padto = 4)
        Key.append(y)
    K_op.append(Key)


K_option = []

#Original keybits at the sixteen positions corresponding to the 1st nibble of penultimate round
U = []
for l in range(4):
    nib = floor(Val[l]/4)
    for i in range(4):
        U.append(K_org[4*nib+i])
print('Original keybits at the sixteen positions corresponding to the 1st nibble of penultimate round=', U)

#options after last round fault for 16 bits of the key
for i1 in range(len(K_op[0])):
    for i2 in range(len(K_op[1])):
        for i3 in range(len(K_op[2])):
            for i4 in range(len(K_op[3])):
                a = []
                for i in range(4):
                    a.append(K_op[0][i1][i]) 
                for i in range(4):
                    a.append(K_op[1][i2][i]) 
                for i in range(4):
                    a.append(K_op[2][i3][i]) 
                for i in range(4):
                    a.append(K_op[3][i4][i]) 
                K_option.append(a)
                
print('Number of options after last round fault for 16 bits of key is', len(K_option))

aa = floor(Val[0]/4)
A = []
for l in range(4):
    for i in range(4):
        A.append(Perm[i+4*l+16*aa])
A.sort()

for l in range(4):
    Y = []
    Z_0 = []
    Z = []
    for j in range(3):
        for i in range(128):
            S[i] = S_org[i]
        if(j > 0):
            X = ZZ(j).digits(base = 2, padto = 4) #converting fault into binary
            
            #adding the fault to the corresponding nibble
            for i in range(4):
                S[i+4*l+16*aa] = (S[i+4*l+16*aa]+X[i])%2
            Y.append(X) #Storing the induced fault
            
        #subcells operation    
        i = 0
        while(i < 128):
            S_sb = Sbox(S[i],S[i+1],S[i+2],S[i+3])
            S[i] = S_sb[0]
            S[i+1] = S_sb[1]
            S[i+2] = S_sb[2]
            S[i+3] = S_sb[3]
            i = i+4
            
        #permbits operation    
        S1 = [0]*128
        for i in range(len(S)):
            S1[Perm[i]] = S[i]
            
        #addroundkey     
        for i in range(128):
            S[i] = (S1[i]+K_org[i])%2
            
        #subcells operation    
        i=0
        while(i < 128):
            S_sb = Sbox(S[i],S[i+1],S[i+2],S[i+3])
            S[i] = S_sb[0]
            S[i+1] = S_sb[1]
            S[i+2] = S_sb[2]
            S[i+3] = S_sb[3]
            i = i+4
            
        #addroundkey         
        for i in range(128):
            S[i] = (S[i]+K_org[i])%2
            
        #storing the original state    
        if(j == 0):
            for i in range(128):
                Z_0.append(S[i])
    
        #storing the faulty states  
        if(j > 0):
            L = []
            for i in range(128):
                L.append(S[i])
            Z.append(L)
    
    A = []
    for l1 in range(4):
        for i1 in range(4):
            A.append(Perm[i1+4*l1+16*aa])
    A.sort() #Set of key bit positions that have to be recovered 
    KK = [0]*128
    K_OPTION_NEW = []
    for op in range(len(K_option)):
        for i in range(16):
            KK[A[i]] = K_option[op][i]
        match = 0
        for j in range(2):
            a = []
            b = []
            for i in range(128):
                a.append((Z_0[i]+KK[i])%2)
                b.append((Z[j][i]+KK[i])%2)
            i = 0
            while(i < 128):
                B = Sbox_in(a[i],a[i+1],a[i+2],a[i+3])
                a[i] = B[0]
                a[i+1] = B[1]
                a[i+2] = B[2]
                a[i+3] = B[3]
                i = i+4
            i = 0
            while(i < 128):
                B = Sbox_in(b[i],b[i+1],b[i+2],b[i+3])
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
                a[Perm_in[i]] = c[i] 
                b[Perm_in[i]] = d[i]
            i = 0
            while(i<128):
                B = Sbox_in(a[i],a[i+1],a[i+2],a[i+3])
                a[i] = B[0]
                a[i+1] = B[1]
                a[i+2] = B[2]
                a[i+3] = B[3]
                i = i+4
            i = 0
            while(i<128):
                B = Sbox_in(b[i],b[i+1],b[i+2],b[i+3])
                b[i] = B[0]
                b[i+1] = B[1]
                b[i+2] = B[2]
                b[i+3] = B[3]
                i = i+4
            c = [(a[4*l+16*aa]+b[4*l+16*aa])%2,(a[4*l+16*aa+1]+b[4*l+16*aa+1])%2, (a[4*l+16*aa+2]+b[4*l+16*aa+2])%2, (a[4*l+16*aa+3]+b[4*l+16*aa+3])%2]
            if(c == Y[j]):
                match = match+1
        
        if(match == 2):
            K_OPTION_NEW.append(K_option[op])
    print('Number of options:',len(K_OPTION_NEW))
    K_option = []
    for i in range(len(K_OPTION_NEW)):
        K_option.append(K_OPTION_NEW[i])

for i in range(len(K_option)):
    if(K_option[i] == U):
        print('We have a match!', K_option[i])
