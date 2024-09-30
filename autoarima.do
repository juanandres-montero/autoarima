capture program drop autoarima
program define autoarima
    // Definir variables y argumentos
    args timevar var d

    // Verificar si se especificaron las variables
    if "`timevar'" == "" | "`var'" == "" | "`d'" == "" {
        di as error "Debe especificar una variable de tiempo, una variable y un d para el modelo ARIMA."
        exit
    }

    // Configurar el formato de series de tiempo
    tsset `timevar'

    // Configurar parámetros del modelo ARIMA
    local maxp 4  // p hasta 4
    local d `d'   // usar d especificado por el usuario
    local maxq 4  // q hasta 4

    // Inicializar matrices para AIC y BIC
    matrix results = J(`maxp' + 1, `maxq' + 1, .) // Matriz para almacenar AIC
    matrix bics = J(`maxp' + 1, `maxq' + 1, .)   // Matriz para almacenar BIC
    matrix results_no_const = J(`maxp' + 1, `maxq' + 1, .) // Matriz para AIC sin constante
    matrix bics_no_const = J(`maxp' + 1, `maxq' + 1, .)   // Matriz para BIC sin constante

    // Iterar sobre combinaciones de p, d, q
    forval p = 0/`maxp' {
        forval q = 0/`maxq' {
            // ARIMA con constante
            qui arima `var', arima(`p',`d',`q') iter(100)
            // Extraer estadísticas
            scalar log_likelihood = e(ll)
            scalar num_params = (`p' + `q'+2)
            scalar nobs = e(N)

            // Calcular AIC y BIC
            scalar aic = -2 * log_likelihood + 2 * num_params
            scalar bic = -2 * log_likelihood + num_params * ln(nobs)

            // Almacenar resultados en las matrices
            matrix results[`p' + 1, `q' + 1] = aic
            matrix bics[`p' + 1, `q' + 1] = bic

            // Imprimir AIC y BIC después de probar el modelo con constante
            di "ARIMA(`p',`d',`q') con constante: AIC: " aic ", BIC: " bic

            // ARIMA sin constante
            qui arima `var', arima(`p',`d',`q') noconstant iter(100)
            // Extraer estadísticas
            scalar log_likelihood = e(ll)
            scalar num_params = (`p' + `q' +1) //sin constante
            scalar nobs = e(N)

            // Calcular AIC y BIC sin constante
            scalar aic = -2 * log_likelihood + 2 * num_params
            scalar bic = -2 * log_likelihood + num_params * ln(nobs)

            // Almacenar resultados en las matrices
            matrix results_no_const[`p' + 1, `q' + 1] = aic
            matrix bics_no_const[`p' + 1, `q' + 1] = bic

            // Imprimir AIC y BIC después de probar el modelo sin constante
            di "ARIMA(`p',`d',`q') sin constante: AIC: " aic ", BIC: " bic
        }
    }

    // Encontrar los mínimos AIC y BIC para modelos con constante
    local min_aic = .
    local min_bic = .
    local p_aic = 0
    local q_aic = 0
    local p_bic = 0
    local q_bic = 0

    forval p = 0/`maxp' {
        forval q = 0/`maxq' {
            if missing(`min_aic') | results[`p' + 1, `q' + 1] < `min_aic' {
                local min_aic = results[`p' + 1, `q' + 1]
                local p_aic = `p'
                local q_aic = `q'
            }
            if missing(`min_bic') | bics[`p' + 1, `q' + 1] < `min_bic' {
                local min_bic = bics[`p' + 1, `q' + 1]
                local p_bic = `p'
                local q_bic = `q'
            }
        }
    }

    // Mostrar los resultados mínimos para modelos con constante
    di "El valor mínimo de AIC con constante es " `min_aic' " en el modelo: ARIMA(`p_aic',`d',`q_aic')"
    di "El valor mínimo de BIC con constante es " `min_bic' " en el modelo: ARIMA(`p_bic',`d',`q_bic')"

    // Encontrar los mínimos AIC y BIC para modelos sin constante
    local min_aic_no_const = .
    local min_bic_no_const = .
    local p_aic_no_const = 0
    local q_aic_no_const = 0
    local p_bic_no_const = 0
    local q_bic_no_const = 0

    forval p = 0/`maxp' {
        forval q = 0/`maxq' {
            if missing(`min_aic_no_const') | results_no_const[`p' + 1, `q' + 1] < `min_aic_no_const' {
                local min_aic_no_const = results_no_const[`p' + 1, `q' + 1]
                local p_aic_no_const = `p'
                local q_aic_no_const = `q'
            }
            if missing(`min_bic_no_const') | bics_no_const[`p' + 1, `q' + 1] < `min_bic_no_const' {
                local min_bic_no_const = bics_no_const[`p' + 1, `q' + 1]
                local p_bic_no_const = `p'
                local q_bic_no_const = `q'
            }
        }
    }

    // Mostrar los resultados mínimos para modelos sin constante
    di "El valor mínimo de AIC sin constante es " `min_aic_no_const' " en el modelo: ARIMA(`p_aic_no_const',`d',`q_aic_no_const')"
    di "El valor mínimo de BIC sin constante es " `min_bic_no_const' " en el modelo: ARIMA(`p_bic_no_const',`d',`q_bic_no_const')"
	di "Compruebe que los coeficientes sean significativos"
	di "Compruebe que todos los eigenvalores se ubiquen dentro del circulo unitario con estat aroots"

end



