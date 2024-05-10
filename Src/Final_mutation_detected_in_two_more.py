#!/usr/bin/env python

import sys

infile1 = sys.argv[1]
infile2 = sys.argv[2]
infile3 = sys.argv[3]


file1_list = []
file2_list = []
file3_list = []

file1_dic = {}
file2_dic = {}
file3_dic = {}

for line in map(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile1)):
    if line[0].startswith('#'): continue
    key = tuple(line[:5])
    data = [float(x) for x in line[5:11]]
    file1_dic[key] = data

for line2 in map(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile2)):
    if line2[0].startswith('#'): continue
    key2 = tuple(line2[:5])
    data2 = [float(x) for x in line2[5:11]]
    file2_dic[key2] = data2

for line3 in map(lambda x:x.rstrip('\n').rstrip('\r').split('\t'), open(infile3)):
    if line3[0].startswith('#'): continue
    key3 = tuple(line3[:5])
    data3 = [float(x) for x in line3[5:11]]
    file3_dic[key3] = data3

file1_keys = list(file1_dic.keys())
file2_keys = list(file2_dic.keys())
file3_keys = list(file3_dic.keys())

inter = set(file1_keys) & set(file2_keys) & set(file3_keys)
union = set(file1_keys) | set(file2_keys) | set(file3_keys)


head = ["#chrom",  "start", "end", "ref", "var", "normal_reads1", "normal_reads2", "normal_var_freq", "tumor_reads1", "tumor_reads2", "tumor_var_freq"]
print('\t'.join(head))

for ele in list(union):
    
    tc = 0


    try:
        file1_dic[ele]
    except KeyError:
        file1_data = [0, 0, 0, 0, 0, 0]
    else:
        tc = tc + 1
        file1_data = file1_dic[ele]

    try:
        file2_dic[ele]
    except KeyError:
        file2_data = [0, 0, 0, 0, 0, 0]
    else:
        tc = tc + 1
        file2_data = file2_dic[ele]

    try:
        file3_dic[ele]
    except KeyError:
        file3_data = [0, 0, 0, 0, 0, 0]
    else:
        tc = tc + 1
        file3_data = file3_dic[ele]

#   print(file1_data)
#   print(file2_data)
#   print(file3_data)
  
    tmp_varfreq = [file1_data[-1], file2_data[-1], file3_data[-1]]
    tmp_varfreq_idx = tmp_varfreq.index(max(tmp_varfreq))

#    print(tmp_varfreq)
#    print(tmp_varfreq_idx)
    tmp_data = [file1_data, file2_data, file3_data]
#    print(tmp_data)
    target = tmp_data[tmp_varfreq_idx]

    if tc >= 2:
        info = list(ele)
        data = target
        data = [str(int(data[0])), str(int(data[1])), str(round(data[2],2)), str(int(data[3])), str(int(data[4])), str(round(data[5],2))]
        

#        print(info)
#        print(data)
        new_line = info + data
        print('\t'.join(new_line))
        


