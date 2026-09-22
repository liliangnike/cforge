#include <stdio.h>

#include "cf_log.h"

static cf_log_level g_level = CF_LOG_INFO;      // static global variable - only this file scope

void set_cf_log_level(cf_log_level level)
{
    g_level = level;
}

cf_log_level get_cf_log_level(void)
{
    return g_level;
}
