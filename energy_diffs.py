
import sys

def get_e(line):
    # return the first valid float encountered on the given line
    for i in line.split():
        try:
            return float(i)
        except ValueError:
            pass

def get_diff(line1, line2):
    return get_e(line2)-get_e(line1)

def is_converged(line1, line2, tol):
    if abs(get_diff(line1, line2))<float(tol):
        return "true"
    else:
        return "false"

if __name__ == '__main__':
    if sys.argv[1]=='check':
        print is_converged(sys.argv[2], sys.argv[3], sys.argv[4])
    elif len(sys.argv)==2:
        print get_e(sys.argv[1])
    elif len(sys.argv)==3:
        print get_diff(sys.argv[1], sys.argv[2])

