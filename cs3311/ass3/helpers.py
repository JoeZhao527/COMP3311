# COMP3311 20T3 Ass3 ... Python helper functions
# add here any functions to share between Python scripts 

def print_not_found(input, in_type):
    if in_type == 'name':
        print('No name matching ' + input)
    else:
        print('No movie matching '+ input)

def print_movie(input, movies):
    print('Movies matching '+input)
    print('===============')
    for movie in movies:
        print(movie[0], '('+str(movie[1])+')')

# construct input, pattern and year for q2,3,4 
def construct_input(argv):
    argc = len(argv)
    input = None
    year = None
    pattern = sys.argv[1]
    if argc == 2:
        input = '\''+pattern+'\''
    elif argc == 3:
        year = sys.argv[2]
        input = '\''+pattern+'\''+' '+str(year)
    return input, pattern, year

# check input validitiy for q3,4
def check_input(argv, usage):
    argc = len(argv)
    if argc == 2 or (argc == 3 and argv[2].isdigit()):
        pass
    else:
        print(usage)
        exit()