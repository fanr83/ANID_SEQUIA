import pandas as pd
import numpy as np
import os
import glob
import datetime
import re

def texotNormalizado(texto):
    # texto = re.sub(pattern='^\W*|\W*$', repl='', string=texto)
    # texto = re.sub(pattern='\W{2,}', repl='', string=texto)
    texto = re.sub(pattern='^\s*|\s*$', repl='', string=texto)
    texto = re.sub(pattern='\s{1,}', repl='', string=texto)
    return(texto)


dir_raiz = os.path.join(os.environ['ONEDRIVE'],'Datos-CambioClimatico/output') #, variable)

variables = [fila for fila in os.listdir(dir_raiz) if 'ceaza' in fila]
# variable = 'velocidad_viento_ceaza'

for variable in variables:
    print(variable)

    dir_sale = os.path.join(os.environ['ONEDRIVE'], 'ANID', 'CEAZA_ordenado', variable)

    if os.path.exists(dir_sale)==False: os.mkdir(dir_sale)

    archivos = [archivo for archivo in glob.glob(dir_raiz + '/' + variable + '/*/*.csv')]

    for count, data in enumerate(archivos):
        # print(count)
        try:
            out = pd.read_csv(data
                              , sep=','
                              , parse_dates=['time']
                              , date_parser=lambda x: datetime.datetime.strptime(x, '%Y-%m-%d %H:%M:%S')
                              , dtype={'time': np.float64,
                                       'latitud': np.single,
                                       'longitud': np.single,
                                       'min': np.single,
                                       'prom': np.single,
                                       'max': np.single,
                                       's_cod': str,
                                       'nombre': str}
                              )
        except:
            print('elemento numero ' + str(count) + ' no pudo ser contado')

        if count == 0:
            df = out
        else:
            df = df.append(out)


    df['hour'] = df.time.dt.hour
    df['day'] = df.time.dt.day
    df['month'] = df.time.dt.month
    df['year'] = df.time.dt.year
    df['variable'] = variable

    # df.columns
    df = df[['time', 'year', 'month', 'day', 'hour', 'variable', 's_cod', 'nombre', 'latitud', 'longitud', 'min', 'prom', 'max']]

    df.to_csv(
        path_or_buf=os.path.join(os.environ['ONEDRIVE'],
                                 'ANID',
                                 'CEAZA_ordenado',
                                 'todo_' + variable + '.csv')
            , sep=';'
            , na_rep='NA'
            , header=True
            , index=False
            , encoding='utf-8'
            , date_format='%Y-%m-%d %H:%m'
        )

    for count, est in enumerate(set(df.nombre.unique())):
        print(est)
        asdf = df.loc[df.nombre == est, :]

        asdf.to_csv(
            path_or_buf=os.path.join(os.environ['ONEDRIVE'],
                                     'ANID',
                                     'CEAZA_ordenado',
                                     # variable, str(count).zfill(2) + '_' + est + '.csv')
                                     variable, variable + '_' + est + '.csv')
            , sep=';'
            , na_rep='NA'
            , header=True
            , index=False
            , encoding='utf-8'
            , date_format='%Y-%m-%d %H:%m'
        )





# wide_df = pd.pivot(df, index=["time"], columns=["latitud", "longitud"], values=["nombre", "min", "prom", "max"])
#
# print(df.shape)
# print(df.columns)
# print(df.info())
# print(df.head(10))
# print(set(df.nombre.unique()))
#
# # df = pd.read_csv(archivos[0])
# df = pd.read_csv(archivos[0]
#                  #, sep=''
#                  , parse_dates=['time']
#                  , date_parser=lambda x: datetime.datetime.strptime(x, '%Y-%m-%d %H:%M:%S')
#                  , dtype={'time':str, 'latitud':np.single,
#                           'longitud':np.single, 'min':np.single,
#                           'prom':np.single, 'max':np.single,
#                           's_cod':np.int16, 'nombre':str}
#                  )
#
#
# try:
#   print(x)
# except:
#   print("Exception thrown. x does not exist.")