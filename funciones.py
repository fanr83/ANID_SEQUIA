# import statsmodels.api as sm

def texotNormalizado(texto):
    import numpy as np
    import re
    # texto = re.sub(pattern='^\W*|\W*$', repl='', string=texto)
    # texto = re.sub(pattern='\W{2,}', repl='', string=texto)
    texto = re.sub(pattern='^\s*|\s*$', repl='', string=texto)
    texto = re.sub(pattern='\s{1,}', repl='', string=texto)
    return(texto)


def midTexto(texto, mid=10):
    mid = int(mid)
    mid = mid-1
    return(texto[:mid])


# def limpiaLista(lista, sacar):
#     lista = list(lista)
#     sacar = list(sacar)
#     return([fila if sacar in fila else for fila in lista if sacar in fila])
