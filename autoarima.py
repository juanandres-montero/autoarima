# Instalar pmdarima con pip install -q pmdarima
!pip install -q pmdarima statsmodels pandas

import pandas as pd
import statsmodels.api as sm
from pmdarima.arima import auto_arima

# Leer los datos desde un archivo .dta
# Ruta de acceso a la base de datos, cambiar aquí si se utiliza un archivo CSV o Excel
# Por ejemplo, para CSV usa: pd.read_csv('ruta/a/archivo.csv')
data = pd.read_stata('C:/Users/User/Downloads/cpi-entrenamiento.dta')  # Cambiar 'ruta/a/cpi.dta' por la ruta real del archivo

y = data['cpi']  # Cambiar 'cpi' por el nombre de la columna que deseas modelar

# Ajustar el modelo ARIMA automáticamente
model = auto_arima(y,
                   trace=True,
                   seasonal=False,
                   max_p=5,
                   max_q=5,
                   d=1,  # Número de diferencias para hacer la serie estacionaria
                   start_p=0,
                   start_q=0,
                   start_P=0,
                   start_Q=0,
                   D=0,
                   m=1,
                   information_criterion='aic',
                   stepwise=True)

# Imprimir el resumen del modelo
print(model.summary())
