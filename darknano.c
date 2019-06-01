#define _GNU_SOURCE

#include <dlfcn.h>
#include <string.h>

int (*original_strncasecmp)(const char *, const char *, size_t);
int (*original_strcasecmp)(const char *, const char *);

__attribute__((constructor)) void darknano_init() {
	original_strncasecmp = dlsym(RTLD_NEXT, "strncasecmp");
	original_strcasecmp = dlsym(RTLD_NEXT, "strcasecmp");
}

int strncasecmp(const char *s1, const char *s2, size_t n) {
	if (n != 6 || strncmp(s2, "bright", n)) {
		return original_strncasecmp(s1, s2, n);
	} else {
		return !0;
	}
}

int strcasecmp(const char *s1, const char *s2) {
	if (!original_strncasecmp(s1, "bright", 6)) {
		s1 += 6;
	}
	return original_strcasecmp(s1, s2);
}
