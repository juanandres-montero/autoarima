capture program drop autoarima
program define autoarima
    // Definir variables y argumentos
    args timevar var

    // Verificar si se especificaron las variables
    if "`timevar'" == "" | "`var'" == "" {
        di as error "Debe especificar una variable de tiempo y una variable para el modelo ARIMA."
        exit
    }

    // Generar variables auxiliares
    gen obs = _n
    gen AIC = .
    gen BIC = .
    gen ARIMA_ = ""

    // Configurar el formato de series de tiempo
    tsset `timevar'

    // Configurar parámetros del modelo ARIMA
    local i = 1
    local maxp 4  // p hasta 4 debido a limitaciones de Stata
    local maxd 1  // d hasta 1 debido a errores en Stata con d > 1
    local maxq 2  // q hasta 2

    // Iterar sobre combinaciones de p, d, q
    forval p = 0/`maxp' {
        forval d = 0/`maxd' {
            forval q = 0/`maxq' {
                di "Probando ARIMA(`p',`d',`q') para la variable `var'"
                qui arima `var', arima(`p',`d',`q')

                // Extraer estadísticas
                scalar log_likelihood = e(ll)
                scalar num_params = (`p' + `q' + 1)
                scalar nobs = _N

                // Calcular AIC y BIC
                scalar aic = -2 * log_likelihood + 2 * num_params
                scalar bic = -2 * log_likelihood + num_params * ln(nobs)

                // Guardar resultados
                qui replace ARIMA_ = "ARIMA(`p',`d',`q')" if obs == obs[`i']
                qui replace AIC = aic if obs == obs[`i']
                qui replace BIC = bic if obs == obs[`i']

                // Incrementar el contador
                local i = `i' + 1
            }
        }
    }

    // Identificar el modelo con el menor AIC y BIC
    egen min_aic = min(AIC)
    gen pos_aic = obs if AIC == min_aic
    egen p_aic = min(pos_aic)

    egen min_bic = min(BIC)
    gen pos_bic = obs if BIC == min_bic
    egen p_bic = min(pos_bic)

    gen arimaic = ARIMA_[p_aic]
    gen arimabic = ARIMA_[p_bic]
	list ARIMA AIC BIC in 1/30
    // Mostrar los resultados
    di "El valor mínimo de AIC es " min_aic " en el modelo: " arimaic
    di "El valor mínimo de BIC es " min_bic " en el modelo: " arimabic

    // Limpiar variables auxiliares
    drop obs min_aic min_bic pos_aic pos_bic p_aic p_bic arimabic arimaic AIC BIC ARIMA_

end
