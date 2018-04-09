
EPS = 1e-8

lines = None
with open('FOCKMAT', 'r') as f:
	lines = f.readlines()

with open('FOCKMAT', 'w') as f:
	i = 1
	for line in lines:
		j = 1
		for val in line.split():
			try:
				num_val = float(val)
			except ValueError:
				num_val = complex(*map(float, val[1:-1].split(',')))
			if j!=i and abs(num_val)>EPS:
				print "WARNING: large off-diagonal Fock matrix elements"
			if j>=i:
				f.write('{}    {}    {}\n'.format(val, i, j))
			if j==len(lines):
				break
			j+=1
		i+=1
