#ifndef __CFORGE_LOG_H__
#define __CFORGE_LOG_H__

typedef enum cf_log_level {
    CF_LOG_TRACE = 0,
    CF_LOG_DEBUG = 1,
    CF_LOG_INFO  = 2,
    CF_LOG_WARN  = 3,
    CF_LOG_ERROR = 4,
    CF_LOG_OFF   = 5
} cf_log_level;

void set_cf_log_level(cf_log_level level);
cf_log_level get_cf_log_level(void);

#endif
